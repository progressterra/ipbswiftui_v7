//
//  WantThisViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Combine
import ipbswiftapi_v7
import Foundation
import SwiftUI

/// Manages data and operations for "Хочу это" requests within the application.
///
/// `WantThisViewModel` coordinates activities related to creating, viewing, and editing "Хочу это" requests.
/// It provides functionalities such as loading and submitting request details, handling user inputs for request forms,
/// and managing interactions with the document service API for fetching and updating request data.
///
/// - Fetches and displays a list of all "Хочу это" requests.
/// - Submits new requests or updates existing ones based on user inputs.
/// - Handles image uploads associated with requests.
/// - Manages UI states and data validation for form submissions.
///
/// ## Example Usage
/// ```swift
/// WantThisView()
///     .environmentObject(WantThisViewModel())
///     .environmentObject(MessengerViewModel.shared)
/// ```
///
/// This class is essential for maintaining the business logic associated with "Хочу это" requests and should be used as an environment object in any SwiftUI view that requires access to this data.
public class WantThisViewModel: ObservableObject {
    
    @Published public var currentDocumentID: String?
    @Published public var fieldsData: [FieldData]?
    @Published public var document: ResultData<RFCharacteristicValueViewModel>?
    @Published public var documentList: ResultDataList<RFCharacteristicValueViewModel>?
    
    @Published public var itemURL: String = ""
    @Published public var itemName: String = ""
    @Published public var itemImageURL: String?
    @Published public var itemImage: UIImage?
    
    @Published public var checkData: String = ""{
        didSet { updateSubmitButtonState() }
    }
    @Published public var date_doc: String = ""{
        didSet { updateSubmitButtonState() }
    }
    @Published public var time_doc: String = ""{
        didSet { updateSubmitButtonState() }
    }
    @Published public var sum_doc: String = ""{
        didSet { updateSubmitButtonState() }
    }
    @Published public var FN: String = ""{
        didSet { updateSubmitButtonState() }
    }
    @Published public var FD: String = ""{
        didSet { updateSubmitButtonState() }
    }
    @Published public var FP_D: String = ""{
        didSet { updateSubmitButtonState() }
    }
    
    @Published public var isSubmitButtonDisabled: Bool = true
    @Published public var isLoading: Bool = false
    @Published public var status: String?
    
    @Published public var showErrorAlert: Bool = false
    @Published public var errorMessage: String = ""
    @Published public var error: NetworkRequestError? {
        didSet {
            if let error {
                print(error)
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
    
    
    private func updateSubmitButtonState() {
            isSubmitButtonDisabled = checkData.isEmpty && (date_doc.isEmpty || time_doc.isEmpty || sum_doc.isEmpty || FN.isEmpty || FD.isEmpty || FP_D.isEmpty)
        }
    
    public init(documentService: DocumentService = DocumentService()) {
        self.documentService = documentService
        
        
//        //Publishers.CombineLatest($date_doc, $time_doc, $sum_doc, $FN, $FD, $FP_D)
//        let combinedFields = $checkData.combineLatest($date_doc, $time_doc, $sum_doc)
//        combinedFields.combineLatest($FN, $FD, $FP_D)
//            .map { $0.isEmpty || ($1.isEmpty || $2.isEmpty || $3.isEmpty)}
//            .assign(to: &$isSubmitButtonDisabled)
            
        
//        $itemURL
//            .combineLatest($itemName, $itemImage)
//            .map { $0.isEmpty && $1.isEmpty && $2 == nil }
//            .assign(to: &$isSubmitButtonDisabled)
    }
    
    /// Clears all user inputs and temporary data.
    public func eraseDocumentData() {
        itemImageURL = nil
        itemImage = nil
        itemName = ""
        itemURL = ""
    }
    
    /// Loads the form structure necessary for creating or editing requests.
    public func fetchFieldsData() {
        isLoading = true
        
        documentService.fetchCharacteristicType(for: IPBSettings.wantThisDocumentID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                do {
                    if let data = result.data?.dataInJSON?.data(using: .utf8) {
                        self?.fieldsData = try JSONDecoderUtility.decode([FieldData].self, from: data)
                    }
                } catch {
                    print("Fields Data decoding error")
                }
            }
            .store(in: &subscriptions)
    }
    
    /// Submits a new "Хочу это" request or updates an existing one based on the form data.
    public func fillDocument() {
        isLoading = true
        
        documentService.createDocument(for: IPBSettings.wantThisDocumentID)
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] result -> AnyPublisher<ResultData<RFCharacteristicValueViewModel>, NetworkRequestError> in
                self.document = result
                self.currentDocumentID = result.data?.idUnique
                
                guard let currentDocumentID, let fieldsData else {
                    return Fail(error: NetworkRequestError.customError("Missing required data")).eraseToAnyPublisher()
                }
                
                var fields: [FieldData] = []
                
                for var field in fieldsData {
//                    switch field.name {
//                    case "Наименование" where !itemName.isEmpty:
//                        field.valueData = itemName
//                    case "Ссылка" where !itemURL.isEmpty:
//                        field.valueData = itemURL
//                    default:
//                        break
//                    }
                    
                    switch field.name {
                    case "checkData" where !checkData.isEmpty:
                        field.valueData = checkData
                    case "date_doc" where !date_doc.isEmpty:
                        field.valueData = date_doc
                    case "time_doc" where !time_doc.isEmpty:
                        field.valueData = time_doc
                    case "sum_doc" where !sum_doc.isEmpty:
                        field.valueData = sum_doc
                    case "FN" where !FN.isEmpty:
                        field.valueData = FN
                    case "FD" where !FD.isEmpty:
                        field.valueData = FD
                    case "FP_D" where !FP_D.isEmpty:
                        field.valueData = FP_D
                    default:
                        break
                    }
                    
                    
                    if field.valueData != nil {
                        fields.append(field)
                    }
                }
                
                do {
                    if let jsonString = try JSONEncoderUtility.encode(fields) {
                        return documentService.setData(for: currentDocumentID, with: jsonString)
                    }
                } catch {
                    print("Failed to encode JSON: \(error)")
                }
                
                return Fail(error: NetworkRequestError.customError("Failed to encode JSON")).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] result -> AnyPublisher<ResultData<RFCharacteristicValueViewModel>, NetworkRequestError> in
                self.document = result
                
                guard let currentDocumentID = self.currentDocumentID else {
                    return Fail(error: NetworkRequestError.customError("Missing document ID")).eraseToAnyPublisher()
                }
                
                if let itemImage = self.itemImage, let imageData = itemImage.jpegData(compressionQuality: IPBSettings.imageCompressionQuality) {
                    return documentService.setImage(for: currentDocumentID, with: MediaModel(data: imageData))
                } else {
                    return Just(result)
                        .setFailureType(to: NetworkRequestError.self)
                        .eraseToAnyPublisher()
                }
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
                    self.status = "Запрос успешно отправлен"
                    checkData = ""
                }
            }
            .store(in: &subscriptions)
    }
    
    /// Retrieves a list of all existing "Хочу это" requests.
    public func fetchDocumentList() {
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(
                    fieldName: "idrfCharacteristicType",
                    listValue: [IPBSettings.wantThisDocumentID],
                    comparison: .equalsStrong
                )
            ],
            sort: SortData(
                fieldName: "dateUpdated",
                variantSort: .desc
            ),
            searchData: "",
            skip: 0,
            take: 10
        )
        
        documentService.fetchDocumentList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.documentList = result
            }
            .store(in: &subscriptions)
    }
}

extension WantThisViewModel {
    /// Updates an existing request with new data from the user.
    public func editDocument() {
        guard let currentDocumentID else {
            error = NetworkRequestError.customError("Missing Document ID")
            return
        }
        
        guard let fieldsData else {
            error = NetworkRequestError.customError("Missing Fields Data")
            return
        }
        
        var updatedFields: [FieldData] = []
        
        for var field in fieldsData {
            if field.name == "Наименование" && !itemName.isEmpty {
                field.valueData = itemName
            } else if field.name == "Ссылка" && !itemURL.isEmpty {
                field.valueData = itemURL
            }
            updatedFields.append(field)
        }
        
        isLoading = true
        
        do {
            guard let jsonString = try JSONEncoderUtility.encode(updatedFields) else {
                throw NetworkRequestError.customError("Failed to convert JSON Data to String")
            }
            
            documentService.setData(for: currentDocumentID, with: jsonString)
                .receive(on: DispatchQueue.main)
                .flatMap { [unowned self] result -> AnyPublisher<ResultData<RFCharacteristicValueViewModel>, NetworkRequestError> in
                    self.document = result
                    
                    if let itemImage = self.itemImage, let imageData = itemImage.jpegData(compressionQuality: IPBSettings.imageCompressionQuality) {
                        return documentService.setImage(for: currentDocumentID, with: MediaModel(data: imageData))
                    } else {
                        return Just(result)
                            .setFailureType(to: NetworkRequestError.self)
                            .eraseToAnyPublisher()
                    }
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
                        self.status = "Запрос успешно изменён"
                        self.fetchDocumentList()
                    }
                }
                .store(in: &subscriptions)
        } catch {
            self.error = NetworkRequestError.customError("Failed to process request: \(error.localizedDescription)")
        }
    }
}
