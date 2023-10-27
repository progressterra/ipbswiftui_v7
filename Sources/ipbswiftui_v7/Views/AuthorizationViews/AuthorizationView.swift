//
//  AuthorizationView.swift
//  IPBBonusTestSPM
//
//  Created by Artemy Volkov on 11.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

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
                    offerLink: "https://progressterra.com/",
                    privacyPolicyLink: "https://progressterra.com/",
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
                    loginAction: {
                        vm.endLogin()
                        isProfileDetailViewPresented = vm.isNewUser
                    },
                    requestNewCodeAction: vm.startLogin
                )
                .toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isProfileDetailViewPresented) {
                ProfileDetailView(
                    mode: .constant(.register),
                    submitAction: {
                        profileVM.patchClientData()
                        vm.isLoggedIn = true
                    },
                    skipAction: { vm.isLoggedIn = true }
                )
                .toolbarRole(.editor)
            }
            .alert(isPresented: $vm.showErrorAlert) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(vm.errorMessage),
                    dismissButton: .default(Text("OK")) { vm.error = nil }
                )
            }
        }
        .tint(Style.textPrimary)
    }
}



struct Previews_AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
            .environmentObject(AuthorizationViewModel.shared)
            .environmentObject(ProfileViewModel())
    }
}