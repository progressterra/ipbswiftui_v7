//
//  WithdrawalViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 14.08.2023.
//

import Foundation
import Combine
import ipbswiftapi_v7
import SwiftUI

public class WithdrawalViewModel: ObservableObject {
    
    @Published public var fieldsData: [FieldData]?
    @Published public var documentsData: [String: [FieldData]]?
    @Published public var document: ResultData<RFCharacteristicValueViewModel>?
    @Published public var documentList: ResultDataList<RFCharacteristicValueViewModel>?
    @Published public var paymentDataList: ResultDataList<RFPaymentDataForClientViewModel>?
    @Published public var payment: ResultData<DHPaymentClientViewModel>?
    @Published public var paymentList: ResultDataList<DHPaymentClientViewModel>?
    @Published public var currentPaymentID: String?
    
    @Published public var clientBalanceAmount: Double?
    @Published public var idPaymentData: String?
    @Published public var withdrawalAmount: String = ""
    @Published public var isWithdrawalButtonDisabled: Bool = true
    
    @Published public var cardNumber: String = ""
    @Published public var cardHolderName: String = ""
    @Published public var expirationMonth: String = ""
    @Published public var expirationYear: String = ""
    @Published public var realCVCCode: String = ""
    @Published public var maskedCVCCode: String = ""
    @Published public var cardPhoto: UIImage?
    @Published public var cardPhotoURL: String?
    @Published public var currentDocumentID: String?
    
    @Published public var isSubmitButtonDisabled = true
    @Published public var status: String?
    
    @Published public var isLoading: Bool = false
    
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
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let documentService: DocumentService
    private let paymentDataService: PaymentDataService
    private let paymentsService: PaymentsService
    private let balanceService: BalanceService
    
    public init(
        documentService: DocumentService = DocumentService(),
        paymentDataService: PaymentDataService = PaymentDataService(),
        paymentsService: PaymentsService = PaymentsService(),
        balanceService: BalanceService = BalanceService()
    ) {
        self.documentService = documentService
        self.paymentDataService = paymentDataService
        self.paymentsService = paymentsService
        self.balanceService = balanceService
        
        Publishers.CombineLatest3($cardNumber, $cardHolderName, $expirationMonth)
            .combineLatest(Publishers.CombineLatest3($expirationYear, $realCVCCode, $cardPhoto))
            .map { [unowned self] (firstGroup, secondGroup) in
                let (number, holder, month) = firstGroup
                let (year, cvc, photo) = secondGroup
                return number.isEmpty || holder.isEmpty || month.isEmpty || year.isEmpty || cvc.isEmpty || photo == nil || self.isLoading
            }
            .assign(to: &$isSubmitButtonDisabled)
        
        Publishers.CombineLatest($clientBalanceAmount, $withdrawalAmount)
            .map { ($0 ?? 0) < (Double($1) ?? 1) || (Double($1) ?? -1) <= 0 }
            .assign(to: &$isWithdrawalButtonDisabled)
    }
    
    public func eraseFields() {
        cardNumber = ""
        cardHolderName = ""
        expirationMonth = ""
        expirationYear = ""
        realCVCCode = ""
        maskedCVCCode = ""
        cardPhoto = nil
        cardPhotoURL = nil
    }
    
    public func fetchFieldsData() {
        isLoading = true
        documentService.fetchCharacteristicType(for: IPBSettings.bankCardDocumentID)
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
    
    public func fillDocument() {
        isLoading = true
        
        documentService.createDocument(for: IPBSettings.bankCardDocumentID)
            .receive(on: DispatchQueue.main)
            .flatMap { [unowned self] result -> AnyPublisher<ResultData<RFCharacteristicValueViewModel>, NetworkRequestError> in
                self.document = result
                self.currentDocumentID = result.data?.idUnique
                
                guard let currentDocumentID, let fieldsData else {
                    return Fail(error: NetworkRequestError.customError("Missing required data")).eraseToAnyPublisher()
                }
                
                var fields: [FieldData] = []
                
                for var field in fieldsData {
                    if field.name == "Номер карты" {
                        field.valueData = self.cardNumber.replacingOccurrences(of: " ", with: "")
                    } else if field.name == "Владелец" {
                        field.valueData = self.cardHolderName
                    } else if field.name == "Месяц" {
                        field.valueData = self.expirationMonth
                    } else if field.name == "Год" {
                        field.valueData = self.expirationYear
                    } else if field.name == "CVC" {
                        field.valueData = self.realCVCCode
                    }
                    fields.append(field)
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
                
                guard let currentDocumentID, let cardPhoto = cardPhoto, let imageData = cardPhoto.jpegData(compressionQuality: IPBSettings.imageCompressionQuality) else {
                    return Fail(error: NetworkRequestError.customError("Missing required photo")).eraseToAnyPublisher()
                }
                
                return documentService.setImage(for: currentDocumentID, with: MediaModel(data: imageData))
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
                    self.status = "Карта добавлена"
                }
            }
            .store(in: &subscriptions)
    }
    
    public func fetchDocumentList() {
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(
                    fieldName: "idrfCharacteristicType",
                    listValue: [IPBSettings.bankCardDocumentID],
                    comparison: .equalsStrong
                )
            ],
            sort: SortData(
                fieldName: "dateUpdated",
                variantSort: .desc
            ),
            searchData: "",
            skip: 0,
            take: 25
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
                self?.documentsData = self?.convertDocumentListToDictionary()
            }
            .store(in: &subscriptions)
    }
    
    public func fetchPaymentDataList() {
        isLoading = true
        let filter = FilterAndSort(
            listFields: nil,
            sort: SortData(fieldName: "dateAdded", variantSort: .desc),
            searchData: nil,
            skip: 0,
            take: 25
        )
        
        paymentDataService.fetchPaymentDataList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.paymentDataList = result
            }
            .store(in: &subscriptions)
    }
    
    public func createPayment() {
        guard let idPaymentData, let withdrawalAmount = Double(withdrawalAmount) else { return }
        
        isLoading = true
        
        let entity = DHPaymentEntityIncome(
            idPaymentData: idPaymentData,
            amount: withdrawalAmount
        )
        
        paymentsService.createPayment(with: entity)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.payment = result
                if result.result.status == .success {
                    switch result.data?.status {
                    case .inProgress:
                        self?.status = "Транзакция в процессе"
                    case .success:
                        self?.status = "Транзакция прошла успешно"
                    default:
                        self?.status = "Ошибка, средства остались на вашем счету"
                    }
                    self?.getClientBalance()
                }
            }
            .store(in: &subscriptions)
    }
    
    public func fetchPaymentList() {
        
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: nil,
            sort: nil,
            searchData: nil,
            skip: 0,
            take: 50
        )
        
        paymentsService.fetchPaymentList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.paymentList = result
            }
            .store(in: &subscriptions)
    }
    
    public func getClientBalance() {
        isLoading = true
        
        balanceService.getClientBalance()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.clientBalanceAmount = result.data?.amount
            }
            .store(in: &subscriptions)
    }
}

extension WithdrawalViewModel {
    private func convertDocumentListToDictionary() -> [String: [FieldData]]? {
        guard let dataList = self.documentList?.dataList else { return nil }
        
        var resultDict: [String: [FieldData]] = [:]
        
        dataList.forEach { item in
            if let viewData = item.viewData {
                do {
                    if let jsonData = viewData.data(using: .utf8) {
                        resultDict[item.idUnique] = try JSONDecoderUtility.decode([FieldData].self, from: jsonData)
                    }
                } catch {
                    print("Error decoding viewData for item \(item.idUnique): \(error)")
                }
            }
        }
        
        return resultDict
    }
}

extension WithdrawalViewModel {
    public func editDocument() {
        guard let currentDocumentID else { return }
        
        guard let fieldsData else {
            error = NetworkRequestError.customError("Missing Fields Data")
            return
        }
        
        var updatedFields: [FieldData] = []
        
        for var field in fieldsData {
            if field.name == "Номер карты" {
                field.valueData = self.cardNumber.replacingOccurrences(of: " ", with: "")
            } else if field.name == "Владелец" {
                field.valueData = self.cardHolderName
            } else if field.name == "Месяц" {
                field.valueData = self.expirationMonth
            } else if field.name == "Год" {
                field.valueData = self.expirationYear
            } else if field.name == "CVC" {
                field.valueData = self.realCVCCode
            }
            updatedFields.append(field)
        }
        
        isLoading = true
        
        do {
            guard let jsonString = try JSONEncoderUtility.encode(updatedFields) else {
                throw NetworkRequestError.customError("Failed to convert JSON Data to String")
            }
            
            documentService.setData(for: currentDocumentID, with: jsonString)
                .flatMap { [unowned self] result -> AnyPublisher<ResultData<RFCharacteristicValueViewModel>, NetworkRequestError> in
                    guard let itemImage = cardPhoto, let imageData = itemImage.jpegData(compressionQuality: IPBSettings.imageCompressionQuality) else {
                        return Fail(error: NetworkRequestError.customError("Missing Image Data")).eraseToAnyPublisher()
                    }
                    return documentService.setImage(for: currentDocumentID, with: MediaModel(data: imageData))
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
                        self.status = "Данные успешно изменены"
                        self.fetchDocumentList()
                    }
                }
                .store(in: &subscriptions)
        } catch {
            self.error = NetworkRequestError.customError("Failed to process request: \(error.localizedDescription)")
        }
    }
}
