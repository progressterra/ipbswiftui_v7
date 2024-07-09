//
//  AuthorizationView.swift
//  IPBBonusTestSPM
//
//  Created by Artemy Volkov on 11.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// A SwiftUI view handling the authorization process.
///
/// `AuthorizationView` orchestrates the user authentication flow in a SwiftUI application, from presenting the initial authorization banner to navigating through sign-in, verification, and profile detail views as needed.
///
/// ## Overview
/// This view acts as the entry point for user authentication, directing users through a sequence of steps:
/// - Displaying a banner for initial authorization action. Provide banner image in app assets with name `authorizationBanner`.
/// - Sign-in form where users enter their phone number.
/// - Verification code input for SMS verification.
/// - Profile detail view for new users to enter additional information. Necessary fields could be configured in `StyleConfig.json`
///
/// The view dynamically presents and dismisses these components based on the user's authentication state and actions.
///
/// ## Usage
///
/// To use `AuthorizationView`, ensure you have an instance of ``AuthorizationViewModel`` and ``ProfileViewModel`` ready to be injected as environment objects. This setup allows `AuthorizationView` to observe and react to changes in the authentication state:
///
/// ```swift
/// AuthorizationView()
///     .environmentObject(AuthorizationViewModel.shared)
///     .environmentObject(ProfileViewModel())
/// ```
///
/// ## Key Components
/// - ``AuthorizationBannerView``: The initial view presenting users with the option to start the authorization process or skip it.
/// - ``SignInView``: A view for entering the phone number and initiating the sign-in process.
/// - ``VerificationCodeInputView``: A view for entering the verification code received via SMS.
/// - ``ProfileDetailView``: A view for new users to enter additional profile information.
public struct AuthorizationView: View {
    
    @EnvironmentObject var vm: AuthorizationViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State private var isSignInViewPresented: Bool = false
    @State private var isVerificationCodeViewPresented: Bool = false
    @State private var isProfileDetailViewPresented: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AuthorizationBannerView(
                    authAction: { isSignInViewPresented = true },
                    skipAction: { vm.isLoggedIn = true }
                )
                .onAppear { isSignInViewPresented = vm.isNewUser }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isSignInViewPresented) {
                SignInView(
                    phoneNumber: $vm.phoneNumber,
                    offerLink: Style.offerURL,
                    privacyPolicyLink: Style.privacyURL,
                    presentKeyboardDelay: 0.5,
                    authAction: {
                        vm.startLogin()
                        isSignInViewPresented = false
                        isVerificationCodeViewPresented = true
                    },
                    skipAction: { vm.isLoggedIn = true }
                )
                .onDisappear { vm.phoneNumber = "" }
                .toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isVerificationCodeViewPresented) {
                VerificationCodeInputView(
                    timeRemaining: $vm.secondForResendSMS,
                    codeFromSMS: $vm.codeFromSMS,
                    phoneNumber: vm.phoneNumber,
                    loginAction: vm.endLogin,
                    requestNewCodeAction: vm.startLogin
                )
                .toolbarRole(.editor)
            }
            .onReceive(vm.$isNewUser.dropFirst()) {
                if $0 {
                    isProfileDetailViewPresented = true
                } else {
                    vm.isLoggedIn = true
                }
            }
            .navigationDestination(isPresented: $isProfileDetailViewPresented) {
                ProfileDetailView(
                    mode: .constant(.custom),
                    submitAction: {
                        profileVM.patchClientData()
                        vm.isLoggedIn = true
                    },
                    skipAction: { vm.isLoggedIn = true }
                )
                .navigationBarBackButtonHidden()
            }
            .alert(isPresented: $vm.showErrorAlert) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(vm.errorMessage),
                    dismissButton: .default(Text("OK")) { 
                        vm.error = nil
                        vm.codeFromSMS = ""
                    }
                )
            }
        }
        .tint(Style.textPrimary)
    }
}
