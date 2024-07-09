//
//  AuthorizationViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Foundation
import ipbswiftapi_v7
import Combine

/// Manages the authorization process for users, handling login, token management, and user status checks.
///
/// The view model provides mechanisms to initiate the login process, handle SMS verification codes, manage user authentication state, and perform logout operations. It publishes properties to reflect the current authentication state, loading status, and any errors encountered during authentication.
///
/// ## Usage
/// - Use `startLogin` to initiate the login process with a phone number.
/// - Upon receiving an SMS code, call `endLogin` with the provided code to complete the authentication process.
/// - The `isLoggedIn` property indicates whether the user is currently authenticated.
/// - Use `logoutToken` or `logoutAllTokens` to log out the user.
///
/// Or use it with ``AuthorizationView``
///
/// ```swift
/// AuthorizationView()
///     .environmentObject(AuthorizationViewModel.shared)
/// ```
///
/// ## Error Handling
/// - Errors during the authentication process are published through the `error` property. This can be used to present error messages to the user.
///
/// ## New User Detection
/// - The view model checks if the authenticated user is new to the system and updates the `isNewUser` property accordingly. This can be used to trigger additional onboarding flows for new users.
public class AuthorizationViewModel: ObservableObject {
    
    public static let shared = AuthorizationViewModel()
    
    @Published public var isLoggedIn: Bool
    @Published public var isLoading: Bool = false
    @Published public var isNewUser: Bool = false
    
    @Published public var endLoginStatus: StatusResult?
    @Published public var secondForResendSMS: Int = 0
    @Published public var phoneNumber: String = ""
    @Published public var codeFromSMS: String = ""
    
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
    
    private var tempToken: String?
    private var refreshTokenPublisher: AnyPublisher<ResultData<ResultAuthAsJWT>, NetworkRequestError>?
    private let authService = AuthorizationService()
    private let sCRMService = SCRMService()
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        isLoggedIn = AuthStorage.shared.isLoggedIn
    }
    
    public func startLogin() {
        isLoading = true
        authService.startLogin(with: phoneNumber)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                self?.tempToken = result.data?.tempToken
                self?.secondForResendSMS = result.data?.secondForResendSMS ?? 0
            }
            .store(in: &subscriptions)
    }
    
    public func endLogin() {
        guard let tempToken else { return }
        
        isLoading = true
        authService.endLogin(with: codeFromSMS, tempToken: tempToken)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [unowned self] value in
                self.endLoginStatus = value.result.status
                if value.result.status == .success {
                    AuthStorage.shared.updateTokenStorage(for: value.data)
                    self.phoneNumber = ""
                    self.codeFromSMS = ""
                    self.checkForNewUser()
                }
            }
            .store(in: &subscriptions)
    }
    
    private func checkForNewUser() {
        sCRMService.getClientData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  completion in
                switch completion {
                case .failure:
                    self?.isNewUser = true
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                self?.isNewUser = result.data?.name?.isEmpty ?? true
            }
            .store(in: &subscriptions)
    }
    
    /// Logout tokens from all devices
    public func logoutAllTokens(userId: String) {
        isLoading = true
        authService
            .logoutAllTokens(
                userId: userId,
                accessToken: AuthStorage.shared.getAccessToken()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                if result.result.status == .success {
                    AuthStorage.shared.logout()
                    self?.isLoggedIn = false
                }
            }
            .store(in: &subscriptions)
    }
    
    /// Logout from current device
    public func logoutToken() {
        isLoading = true
        authService
            .logoutToken(
                refreshToken: AuthStorage.shared.getRefreshToken(),
                accessToken: AuthStorage.shared.getAccessToken()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isLoading = false
                if case .failure(let error) = $0 {
                    self?.error = error
                }
            } receiveValue: { [weak self] result in
                if result.result.status == .success {
                    AuthStorage.shared.logout()
                    self?.isLoggedIn = false
                }
            }
            .store(in: &subscriptions)
    }
}
