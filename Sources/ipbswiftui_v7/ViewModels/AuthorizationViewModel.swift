//
//  AuthorizationViewModel.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import Foundation
import ipbswiftapi_v7
import Combine

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
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        isLoggedIn = AuthStorage.shared.isLoggedIn
    }
    
    public func startLogin() {
        isLoading = true
        authService.startLogin(with: phoneNumber)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                case .finished:
                    break
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
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                case .finished:
                    break
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
        SCRMService().getClientData()
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
    
    public func logoutAllTokens(userId: String) {
        isLoading = true
        authService
            .logoutAllTokens(
                userId: userId,
                accessToken: AuthStorage.shared.getAccessToken()
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.error = error
                    if error == .unauthorized {
                        self?.refreshTokenAnd {
                            self?.logoutAllTokens(userId: userId)
                        }
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] result in
                if result.result.status == .success {
                    AuthStorage.shared.logout()
                    self?.isLoggedIn = false
                }
            }
            .store(in: &subscriptions)
    }
    
    public func logoutToken() {
        isLoading = true
        authService
            .logoutToken(
                refreshToken: AuthStorage.shared.getRefreshToken(),
                accessToken: AuthStorage.shared.getAccessToken()
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    if error == .unauthorized {
                        self?.refreshTokenAnd {
                            self?.logoutToken()
                        }
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] result in
                if result.result.status == .success {
                    AuthStorage.shared.logout()
                    self?.isLoggedIn = false
                }
            })
            .store(in: &subscriptions)
    }
    
    public func refreshTokenAnd(_ retry: @escaping () -> Void) {
        if refreshTokenPublisher == nil {
            refreshTokenPublisher = authService.refreshToken(with: AuthStorage.shared.getRefreshToken())
                .share()
                .eraseToAnyPublisher()
        }
        
        isLoading = true
        
        refreshTokenPublisher?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    print("Refresh token error: \(error)")
                case .finished:
                    self?.refreshTokenPublisher = nil
                    break
                }
            } receiveValue: { result in
                if result.result.status == .success {
                    AuthStorage.shared.updateTokenStorage(for: result.data)
                    print("Token refreshed ✅")
                    retry()
                }
            }
            .store(in: &subscriptions)
    }
}
