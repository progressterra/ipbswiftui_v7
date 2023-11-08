//
//  MessengerViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 07.08.2023.
//

import Combine
import Intents
import Foundation
import ipbswiftapi_v7
import UIKit

public class MessengerViewModel: ObservableObject {
    
    public static let shared = MessengerViewModel()
    
    @Published public var currentDialog: RGDialogsViewModel? {
        didSet {
            getMessageList()
        }
    }
    @Published public var dialogList: ResultDataList<RGDialogsViewModel>?
    @Published public var message: ResultData<RGMessagesViewModel>?
    @Published public var messages: ResultDataList<RGMessagesViewModel>?
    @Published public var currentMessageText = ""
    @Published public var totalUnreadMessages: Int?
    @Published public var dialogsNotifications: [String: DialogNotifications]?
    
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
    
    private let messengerService: MessengerService
    private var subscriptions = Set<AnyCancellable>()
    
    private init(messengerService: MessengerService = MessengerService()) {
        self.messengerService = messengerService
        
        checkDialogsNotifications()
    }
    
    public func sendMessage() {
        guard let currentDialog = currentDialog, !currentMessageText.isEmpty else { return }

        isLoading = true
        
        initializeParticipants(for: currentDialog)
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] participants -> AnyPublisher<ResultData<RGMessagesViewModel>, NetworkRequestError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                
                let intent = INSendMessageIntent(
                    recipients: participants,
                    outgoingMessageType: .outgoingMessageText,
                    content: self.currentMessageText,
                    speakableGroupName: nil,
                    conversationIdentifier: currentDialog.idUnique,
                    serviceName: nil,
                    sender: nil,
                    attachments: nil
                )
                
                let interaction = INInteraction(intent: intent, response: nil)
                interaction.direction = .outgoing
                interaction.donate()
                
                let message = RGMessagesEntityCreate(
                    idDialog: currentDialog.idUnique,
                    contentText: self.currentMessageText,
                    idQuotedMessage: nil
                )
                
                return self.messengerService.sendMessage(with: message)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.sendMessage()
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.message = result
                self?.getMessageList()
                self?.currentMessageText = ""
            }
            .store(in: &subscriptions)
    }

    public func getMessageList() {
        guard let currentDialogID = currentDialog?.idUnique else { return }
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(
                    fieldName: "idDialog",
                    listValue: [currentDialogID],
                    comparison: .equalsStrong
                )
            ],
            sort: nil,
            searchData: nil,
            skip: 0,
            take: 250
        )
        
        isLoading = true
        
        messengerService.getMessageList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getMessageList()
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.messages = result
            }
            .store(in: &subscriptions)
    }
    
    public func getDialogList(for dialogTypeID: String) {
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(
                    fieldName: "idClient",
                    listValue: [dialogTypeID],
                    comparison: .equalsStrong
                )
            ],
            sort: SortData(fieldName: "dateUpdated", variantSort: .desc),
            searchData: nil,
            skip: 0,
            take: 50
        )
        
        isLoading = true
        
        messengerService.getDialogList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getDialogList(for: dialogTypeID)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.dialogList = result
            }
            .store(in: &subscriptions)
    }
    
    public func getDialogList(with filter: FilterAndSort) {
        isLoading = true
        
        messengerService.getDialogList(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getDialogList(with: filter)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.dialogList = result
            }
            .store(in: &subscriptions)
    }
    
    /// - Parameters:
    ///   - dataSourceType: The type of data source for the dialog.
    ///   - name: The name or title for the dialog. Do not fill it if you need to use target as description.
    ///   - reasonID: Optional specific identifier for a type of message addressed to order, docset or iwantit data source.
    ///   - customID: Optional custom identifier, primarily used for custom and client data source type. By default client data source represents empty guid value.
    ///   - targetListImages: Use to provide image for target of dialog.
    ///   - additionalDataJSON: Optional JSON string for any additional data.
    public func fetchOrCreateDialog(
        for dataSourceType: TypeDataSource,
        with name: String = "",
        reasonID: String? = nil,
        customID: String? = nil,
        targetListImages: [RGEntityMediaDataViewModel] = [],
        additionalDataJSON: String = ""
    ) {
        var idClient: String {
            switch dataSourceType {
            case .custom:
                return customID ?? ""
            case .enterprise:
                return IPBSettings.techSupportID
            case .client:
                return customID ?? IPBSettings.emptyGuid
            case .order:
                return IPBSettings.ordersSupportID
            case .docset:
                return IPBSettings.documentsSupportID
            case .iwantit:
                return IPBSettings.wantThisSupportID
            }
        }
        
        var listClients: [MetaDataClientWithID] {
            if let reasonID, customID == nil {
                return [
                    MetaDataClientWithID(
                        dataSourceType: dataSourceType,
                        dataSourceName: "",
                        description: "",
                        listImages: [],
                        idClient: idClient
                    ),
                    MetaDataClientWithID(
                        dataSourceType: dataSourceType,
                        dataSourceName: "",
                        description: "",
                        listImages: targetListImages,
                        idClient: reasonID
                    )
                ]
            } else {
                return [
                    MetaDataClientWithID(
                        dataSourceType: dataSourceType,
                        dataSourceName: "",
                        description: "",
                        listImages: targetListImages,
                        idClient: idClient
                    )
                ]
            }
        }
        
        let incomeDataForCreateDialog = IncomeDataForCreateDialog(
            listClients: listClients,
            description: name,
            additionalDataJSON: additionalDataJSON
        )
        
        isLoading = true
        
        messengerService.createDialog(with: incomeDataForCreateDialog)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.fetchOrCreateDialog(for: dataSourceType, with: name, reasonID: reasonID)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.currentDialog = result.data
            }
            .store(in: &subscriptions)
    }
}

extension MessengerViewModel {
    public func checkDialogsNotifications() {
        let filter = FilterAndSort(
            listFields: nil, sort: nil, searchData: nil, skip: 0, take: 50
        )
        
        messengerService.getDialogList(with: filter)
            .flatMap { result -> AnyPublisher<[String: DialogNotifications], NetworkRequestError> in
                let dialogPublishers: [AnyPublisher<(String, DialogNotifications), NetworkRequestError>] =
                (result.dataList ?? []).map { [unowned self] dialog in
                    let filter = FilterAndSort(
                        listFields: [
                            FieldForFilter(
                                fieldName: "idDialog",
                                listValue: [dialog.idUnique],
                                comparison: .equalsStrong
                            ),
                            FieldForFilter(
                                fieldName: "dateRead",
                                listValue: [""],
                                comparison: .equalsStrong
                            )
                        ],
                        sort: SortData(fieldName: "dateAdded", variantSort: .desc),
                        searchData: nil,
                        skip: 0,
                        take: 100
                    )
                    
                    return self.messengerService.getMessageList(with: filter)
                        .map { result -> (String, DialogNotifications) in
                            let key = dialog.description == "Техническая поддержка" ?
                            IPBSettings.techSupportID : dialog.idUnique
                            
                            let notifications = DialogNotifications(
                                lastMessage: result.dataList?.first,
                                dateLastMessages: result.dataList?.first?.dateAdded,
                                unreadMessages: result.dataList?.filter { !$0.isOwnMessage }.count
                            )
                            
                            return (key, notifications)
                        }
                        .eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(dialogPublishers)
                    .collect()
                    .map { Array($0) }
                    .map(Dictionary.init)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.checkDialogsNotifications()
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.dialogsNotifications = result
                self?.totalUnreadMessages = result.values.reduce(0) {
                    $0 + ($1.unreadMessages ?? 0)
                }
            }
            .store(in: &subscriptions)
    }
}

public struct DialogNotifications {
    public let lastMessage: RGMessagesViewModel?
    public let dateLastMessages: Date?
    public let unreadMessages: Int?
}

extension MessengerViewModel {
    func initializeParticipants(for dialog: RGDialogsViewModel) -> AnyPublisher<[INPerson], Never> {
        guard let clients = dialog.listMetaDataClient else {
            return Just([]).eraseToAnyPublisher()
        }

        let participants = clients.compactMap { clientViewModel -> AnyPublisher<INPerson?, Never> in
            let personHandle = INPersonHandle(value: clientViewModel.idClient, type: .unknown)
            let metaData = clientViewModel.clientMetaData
            
            if let imageUrlString = metaData.listImages?.first?.urlData, let url = URL(string: imageUrlString) {
                return URLSession.shared.dataTaskPublisher(for: url)
                    .map { result in
                        INPerson(
                            personHandle: personHandle,
                            nameComponents: nil,
                            displayName: nil,
                            image: INImage(imageData: result.data),
                            contactIdentifier: nil,
                            customIdentifier: clientViewModel.idClient
                        )
                    }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
            } else {
                return Just(
                    INPerson(
                        personHandle: personHandle,
                        nameComponents: nil,
                        displayName: nil,
                        image: nil,
                        contactIdentifier: nil,
                        customIdentifier: clientViewModel.idClient
                    )
                )
                .eraseToAnyPublisher()
            }
        }

        return Publishers.MergeMany(participants)
            .compactMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
}
