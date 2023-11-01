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

public class ProfileViewModel: ObservableObject {
    
    @Published public var selectedPhoto: PhotosPickerItem? {
        didSet { selectPhoto(photo: selectedPhoto) }
    }
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
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let sCRMService: SCRMService
    private let mediaDataService: MediaDataService
    
    public init(clientService: SCRMService = SCRMService(), mediaDataService: MediaDataService = MediaDataService()) {
        self.sCRMService = clientService
        self.mediaDataService = mediaDataService
        
        setUpView()
    }
    
    public func setUpView() {
        getClientData()
        getClientPhoto()
    }
    
    public func patchClientData() {
        
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
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.patchClientData()
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.getClientData()
            }
            .store(in: &subscriptions)
    }
    
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
        birthday = data.dateOfBirth?.toDate() ?? .now
        phoneNumber = data.phoneGeneral ?? ""
        typeSex = data.sex
        typeSexStr = data.sex == .male ? "Мужской" : "Женский"
        email = data.eMailGeneral ?? ""
    }
    
    private func getClientData() {
        isLoading = true
        
        sCRMService.getClientData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getClientData()
                        }
                    }
                case .finished:
                    break
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
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.getClientPhoto()
                        }
                    }
                case .finished:
                    break
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
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        AuthorizationViewModel.shared.refreshTokenAnd {
                            self?.setProfilePhoto(with: photoData)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.profileImageURL = result.data?.urlData
            }
            .store(in: &subscriptions)
    }
}
