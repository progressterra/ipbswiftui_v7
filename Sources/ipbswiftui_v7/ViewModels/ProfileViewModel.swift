//
//  ProfileViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 23.08.2023.
//

import Foundation
import Combine
import ipbswiftapi_v7
import SwiftUI
import PhotosUI

/// Manages user profile data, interactions with SCRM services for data patching, and handles profile media.
///
/// `ProfileViewModel` facilitates the retrieval and updating of user profile details from a SCRM service. It supports image uploading using `MediaDataService` and provides functionality for handling form inputs related to the user's profile such as name, surname, and contact information. It also manages UI state based on the progress and results of these operations.
///
/// ## Usage
/// This ViewModel is intended to be used as an environment object within SwiftUI views that present and modify user profile data.
///
/// ## Features
/// - Fetch and update user profile information.
/// - Upload and manage profile images.
/// - Provide real-time validation and error handling.
///
public class ProfileViewModel: ObservableObject {
    
    /// Currently selected photo item from the Photos app. Triggers image upload to the platform.
    @Published public var selectedPhoto: PhotosPickerItem? {
        didSet { selectPhoto(photo: selectedPhoto) }
    }
    /// Optional URL string pointing to the user's profile image web location.
    @Published public var profileImageURL: String?
    
    @Published public var name: String = ""
    @Published public var surname: String = ""
    @Published public var patronymic: String = ""
    @Published public var birthday: Date = .now
    @Published public var phoneNumber: String = ""
    @Published public var email = ""
    @Published public var typeSexStr = ""
    @Published public var typeSex: TypeSex = .male
    
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
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private let sCRMService: SCRMService
    private let mediaDataService: MediaDataService
    
    public init(clientService: SCRMService = SCRMService(), mediaDataService: MediaDataService = MediaDataService()) {
        self.sCRMService = clientService
        self.mediaDataService = mediaDataService
    }
    
    /// Initializes data loading for the user profile by fetching user data and photo.
    public func setUpView() {
        getClientData()
        getClientPhoto()
    }
    
    /// Updates client data on the SCRM service and fetches the latest user data.
    public func patchClientData() {
        
        setClientsEmail()
        
        let clientsEntity = ClientsEntity(
            name: name,
            soname: surname,
            patronymic: patronymic,
            sex: typeSex,
            dateOfBirth: birthday.ISO8601Format(),
            dateOfRegister: Date.now.ISO8601Format(),
            comment: nil
        )
        
        isLoading = true
        
        sCRMService.patсhClientData(with: clientsEntity)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.getClientData()
            }
            .store(in: &subscriptions)
    }
    
    /// Updates the email for the client on the SCRM service.
    public func setClientsEmail() {
        guard !email.isEmpty else { return }
        
        sCRMService.setEmail(email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.getClientData()
            }
            .store(in: &subscriptions)
    }
    
    /// Clears all editable fields in the profile form.
    public func clearData() {
        name = ""
        surname = ""
        patronymic = ""
        birthday = .now
        phoneNumber = ""
        typeSexStr = ""
        email = ""
        profileImageURL = nil
    }
}

extension ProfileViewModel {
    private func updateStoredData(with data: ClientsViewModel?) {
        guard let data else { return }
        name = data.name ?? ""
        surname = data.soname ?? ""
        patronymic = data.patronymic ?? ""
        birthday = data.dateOfBirth ?? .now
        phoneNumber = data.phoneGeneral ?? ""
        typeSex = data.sex ?? .male
        typeSexStr = data.sex == .male ? "Мужской" : "Женский"
        email = data.eMailGeneral ?? ""
    }
    
    private func getClientData() {
        isLoading = true
        
        sCRMService.getClientData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.updateStoredData(with: result.data)
            }
            .store(in: &subscriptions)
    }
}

extension ProfileViewModel {
    private func getClientPhoto() {
        isLoading = true
        
        let filter = FilterAndSort(
            listFields: [
                FieldForFilter(fieldName: "alias", listValue: ["Profile Image"], comparison: .equalsStrong)
            ],
            sort: SortData(fieldName: "dateAdded", variantSort: .desc),
            searchData: nil,
            skip: 0,
            take: 1
        )
        
        mediaDataService.fetchListMediaDataForClient(with: filter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.profileImageURL = result.dataList?.first?.urlData
            }
            .store(in: &subscriptions)
    }
    
    private func selectPhoto(photo: PhotosPickerItem?) {
        photo?.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async { [unowned self] in
                switch result {
                case .success(let data):
                    self.setProfilePhoto(with: data)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
        }
    }
    
    private func setProfilePhoto(with photoData: Data?) {
        guard let photoData else { return }
        let mediaModel = MediaModel(data: photoData)
        
        isLoading = true
        
        mediaDataService.addMediaDataForClient([mediaModel], typeContent: .image, alias: "Profile Image", tag: 0)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.profileImageURL = result.data?.urlData
            }
            .store(in: &subscriptions)
    }
}
