//
//  ApplicationViewModel.swift
//  WOWLidiya
//
//  Created by Artemy Volkov on 14.03.2024.
//

import Combine
import Foundation
import ipbswiftapi_v7

public class ApplicationViewModel: ObservableObject {
    
    @Published public var idProduct: String = ""
    @Published public var clientName: String = ""
    @Published public var clientSurname: String = ""
    @Published public var phoneNumber: String = ""
    @Published public var email: String = ""
    @Published public var idTelegram: String = ""
    @Published public var idChannel: String = ""
    @Published public var nameOfChannel: String = ""
    @Published public var message: String = ""
    @Published public var model: RGApplicationViewModel?
    
    @Published public var isLoading = false
    
    private let applicationService = ApplicationService()
    private var subscriptions: Set<AnyCancellable> = []
    
    public init() {}
    
    public func createApplication() {
        guard !idProduct.isEmpty else { return }
        isLoading =  true
        
        let applicationEntity = RGApplicationEntityCore(
            idProduct: idProduct,
            nameClient: clientName,
            sonameClient: clientSurname,
            phoneNumber: phoneNumber,
            email: email,
            idTelegram: idTelegram,
            idChannel: idChannel,
            nameOfChannel: nameOfChannel,
            message: message
        )
        
        applicationService.createApplication(with: applicationEntity)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
            } receiveValue: { [weak self] value in
                self?.model = value.data
            }
            .store(in: &subscriptions)
    }
}
