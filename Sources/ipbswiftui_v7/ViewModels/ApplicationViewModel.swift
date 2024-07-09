//
//  ApplicationViewModel.swift
//  WOWLidiya
//
//  Created by Artemy Volkov on 14.03.2024.
//

import Combine
import Foundation
import ipbswiftapi_v7

/// A view model for managing the application request process.
///
/// This view model handles the logic for submitting a new application request, including validating user input and communicating with the `ApplicationService` to submit the data. It publishes properties for user input fields such as name, surname, phone number, and more, allowing the view to bind directly to these properties for interactive data entry.
///
/// ## Usage:
/// Instantiate `ApplicationViewModel` and use it as an environment object in your SwiftUI view hierarchy. Bind the view model's published properties to your form inputs to allow for data entry and submit the application using the `createApplication` method.
///
/// ```swift
/// @StateObject private var applicationViewModel = ApplicationViewModel()
///
/// var body: some View {
///     ApplicationRequestView(idProduct: "123")
///         .environmentObject(applicationViewModel)
/// }
/// ```
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
    
    @Published public var error: NetworkRequestError?
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
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] value in
                self?.model = value.data
            }
            .store(in: &subscriptions)
    }
}
