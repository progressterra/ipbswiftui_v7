//
//  DocumentsViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 03.08.2023.
//

import Combine
import Foundation
import ipbswiftapi_v7
import SwiftUI

/// A view model for managing and updating user documents based on citizenship.
///
/// `DocumentsViewModel` handles user inputs and document updates related to various citizenships. It integrates with a backend service to fetch and submit document data, managing the state and content of user documents. It also handles image processing for documents, providing functionalities to upload and validate document images.
///
/// Designed to use with ``DocumentsView`` and ``FillDocumentView``.
public class DocumentsViewModel: ObservableObject {
    
    public enum Citizenship: String, CaseIterable {
        case ru = "Россия"
        case by = "Беларусь"
        case kz = "Казахстан"
        case kg = "Киргизия"
        case am = "Армения"
        case tg = "Таджикистан"
        case uz = "Узбекистан"
        case ua = "Украина"
        case none = ""
    }
    
    /// Stores the images input by the user, mapped by document ID.
    @Published public var inputImages: [String: UIImage?] = [:]
    
    /// Stores the data for input fields for documents, mapped by document ID.
    @Published public var inputFields: [String: [FieldData]] = [:]
    
    @Published public var inputImage: UIImage?
    @Published public var userInputs: [Int: String] = [:]
    @Published public var isButtonDisabled: Bool = true
    @Published public var currentDocumentID: String?
    @Published public var canEdit: Bool = false
    
    @Published public var document: ResultData<RFCharacteristicValueViewModel>?
    @Published public var documentSet: ResultData<DHDocSetFullData>?
    
    @Published public var citizenshipText: String = ""
    /// Tracks the citizenship selection of the user and triggers document data fetching.
    @Published public var citizenship: Citizenship = .none {
        didSet {
            citizenshipText = citizenship.rawValue
            fetchDocumentSet()
        }
    }
    
    @Published public var isLoading: Bool = false
    @Published public var status: String?
    
    @Published public var showErrorAlert: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var error: NetworkRequestError? {
        didSet {
            if let error {
                switch error {
                case let NetworkRequestError.badRequest(message),
                    let NetworkRequestError.customError(message),
                    let NetworkRequestError.serverError(message),
                    let NetworkRequestError.forbidden(message),
                    let NetworkRequestError.unknownError(message):
                    errorMessage = message
                    showErrorAlert = true
                default:
                    print("An unexpected error occurred - \(error)")
                }
            }
        }
    }
    
    private let documentService: DocumentService
    private var subscriptions = Set<AnyCancellable>()
    
    public init(documentService: DocumentService = DocumentService()) {
        self.documentService = documentService
        
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest($userInputs, $inputImages)
            .map { [unowned self] userInputs, inputImages in
                guard let currentDocumentID = self.currentDocumentID else { return true }
                let areFieldsNotEmpty = !userInputs.values.contains { $0.isEmpty }
                let isImageNotNil = inputImages[currentDocumentID] != nil
                return !(areFieldsNotEmpty && isImageNotNil && self.canEdit)
            }
            .assign(to: &$isButtonDisabled)
    }
    
    /// Fetches the document set for the current user's citizenship.
    public func fetchDocumentSet() {
        let id = idForCitizenship()
        
        guard !id.isEmpty else { return }
        
        isLoading = true
        
        documentService.fetchDocSet(for: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.documentSet = result
                
                result.data?.listProductCharacteristic?.forEach {
                    if let data = $0.characteristicValue.valueAsJSON?.data(using: .utf8) {
                        do {
                            let fieldsData = try JSONDecoder().decode([FieldData].self, from: data)
                            self?.inputFields[$0.characteristicValue.idUnique] = fieldsData.sorted { $0.order < $1.order }
                        } catch {
                            self?.inputFields[$0.characteristicValue.idUnique] = [
                                FieldData(
                                    idrfCharacteristicType: $0.characteristicValue.idrfCharacteristicType,
                                    name: $0.characteristicType.name ?? "",
                                    comment: $0.characteristicType.comment ?? "",
                                    order: $0.characteristicType.order ?? 0,
                                    typeValue: $0.characteristicType.typeValue ?? .asString,
                                    valueData: ""
                                )
                            ]
                        }
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    /// Submits the document data including filled fields and associated images.
    public func fillDocument(with idUnique: String) {
        guard let fields = inputFields[idUnique] else {
            error = NetworkRequestError.customError("Missing required data")
            return
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(fields)
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw NetworkRequestError.customError("Failed to encode JSON")
            }
            
            isLoading = true
            
            documentService.setData(for: idUnique, with: jsonString)
                .receive(on: DispatchQueue.main)
                .flatMap { [unowned self] result -> AnyPublisher<ResultData<RFCharacteristicValueViewModel>, NetworkRequestError> in
                    self.document = result
                    
                    guard let inputImage = inputImages[idUnique], let imageData = inputImage?.jpegData(compressionQuality: IPBSettings.imageCompressionQuality) else {
                        return Fail(error: NetworkRequestError.customError("Отсутствует изображение")).eraseToAnyPublisher()
                    }
                    
                    return documentService.setImage(for: idUnique, with: MediaModel(data: imageData))
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.isLoading = false
                    if case .failure(let error) = $0 {
                        self?.error = error
                    }
                } receiveValue: { [unowned self] result in
                    self.document = result
                    
                    if result.result.status == .success {
                        fetchDocumentSet()
                        self.status = "Успешно!"
                    }
                }
                .store(in: &subscriptions)
        } catch {
            self.error = NetworkRequestError.customError("Ошибка формирования запроса")
        }
    }
}

extension DocumentsViewModel {
    /// Returns a document ID specific to the user's citizenship.
    public func idForCitizenship() -> String {
        switch citizenship {
        case .ru:
            return IPBSettings.ruPassportID
        case .by, .kz, .kg, .am:
            return IPBSettings.ByKzKgAmPassportID
        case .tg, .uz, .ua:
            return IPBSettings.TgUzUaPassportID
        case .none:
            return ""
        }
    }
    
    public func displayDocStatus(_ statusDoc: TypeStatusDoc?) -> String? {
        if let statusDoc {
            switch statusDoc {
            case .confirmed:
                return "Документ подтвержден"
            case .waitReview:
                return "Ожидает подтверждения"
            case .rejected:
                return "Документ отклонен"
            case .notFill:
                return "Документ не заполнен"
            case .waitImage:
                return "Требуется добавить изображение документа"
            }
        } else {
            return nil
        }
    }
}
