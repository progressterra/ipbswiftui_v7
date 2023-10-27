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
    
    @Published public var dialog: ResultData<RGDialogsViewModel>?
    @Published public var dialogList: ResultDataList<RGDialogsViewModel>?
    @Published public var message: ResultData<RGMessagesViewModel>?
    @Published public var messages: ResultDataList<RGMessagesViewModel>?
    @Published public var currentDialogID: String? {
        didSet {
            getMessageList()
        }
    }
    @Published public var currentDialogDescription = ""
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
        guard let currentDialogID, let dialog = dialog?.data, !currentMessageText.isEmpty else { return }
        
        
        let participants = initializeParticipants(for: dialog)
        
        // Create and donate the interaction
        let intent = INSendMessageIntent(
            recipients: participants,
            outgoingMessageType: .outgoingMessageText,
            content: currentMessageText,
            speakableGroupName: nil,
            conversationIdentifier: currentDialogID,
            serviceName: nil,
            sender: nil,
            attachments: nil
        )
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Interaction donation failed: \(error)")
            } else {
                print("Interaction successfully donated")
            }
        }
        
        let message = RGMessagesEntityCreate(
            idDialog: currentDialogID,
            contentText: currentMessageText,
            idQuotedMessage: nil
        )
        
        isLoading = true
        
        messengerService.sendMessage(with: message)
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
        guard let currentDialogID else { return }
        
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
    ///   - name: The name or title for the dialog.
    ///   - reasonID: Optional specific identifier for a type of message.
    ///   - customID: Optional custom identifier, primarily used for custom data source type.
    ///   - additionalDataJSON: Optional JSON string for any additional data.
    public func fetchOrCreateDialog(
        for dataSourceType: TypeDataSource,
        with name: String,
        reasonID: String? = nil,
        customID: String? = nil,
        additionalDataJSON: String = ""
    ) {
        var supportTypeID: String {
            switch dataSourceType {
            case .custom:
                return customID ?? ""
            case .enterprise:
                return IPBSettings.techSupportID
            case .client:
                return IPBSettings.emptyGuid
            case .order:
                return IPBSettings.ordersSupportID
            case .docset:
                return IPBSettings.documentsSupportID
            case .iwantit:
                return IPBSettings.wantThisSupportID
            }
        }
        
        var listClients: [MetaDataClientWithID] {
            if let reasonID {
                return [
                    MetaDataClientWithID(
                        dataSourceType: dataSourceType,
                        dataSourceName: dataSourceType.rawValue,
                        description: "",
                        idClient: supportTypeID
                    ),
                    MetaDataClientWithID(
                        dataSourceType: dataSourceType,
                        dataSourceName: dataSourceType.rawValue,
                        description: "",
                        idClient: reasonID
                    )
                ]
            } else {
                return [
                    MetaDataClientWithID(
                        dataSourceType: dataSourceType,
                        dataSourceName: "",
                        description: "",
                        idClient: supportTypeID
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
                self?.dialog = result
                self?.currentDialogID = result.data?.idUnique
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
    func initializeParticipants(for dialog: RGDialogsViewModel) -> [INPerson] {
        guard let clients = dialog.listMetaDataClient else { return [] }
        
        return clients.compactMap { clientViewModel in
            let metaData = clientViewModel.clientMetaData
            
            let personHandle = INPersonHandle(value: clientViewModel.idClient, type: .unknown)
            
            let imageUrl = metaData.listImages?.first?.urlData
            
            // Creating an INPerson object for the participant
            var person = INPerson(
                personHandle: personHandle,
                nameComponents: nil,
                displayName: nil,
                image: nil,
                contactIdentifier: clientViewModel.idClient,
                customIdentifier: nil
            )
            
            if let imageUrlString = imageUrl, let url = URL(string: imageUrlString), let imageData = try? Data(contentsOf: url) {
                person = INPerson(
                    personHandle: personHandle,
                    nameComponents: nil,
                    displayName: "",
                    image: INImage(imageData: imageData),
                    contactIdentifier: clientViewModel.idClient,
                    customIdentifier: nil
                )
            }
            
            
            return person
        }
    }
}
