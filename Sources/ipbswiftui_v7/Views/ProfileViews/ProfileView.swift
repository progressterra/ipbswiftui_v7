//
//  ProfileView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 28.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct ProfileView: View {
    
    @EnvironmentObject var supportServiceVM: MessengerViewModel
    @EnvironmentObject var profileVM: ProfileViewModel
    
    @State private var isAuthViewPresented: Bool = false
    @State private var isProfileDetailViewPresented: Bool = false
    @State private var isDocumentsViewPresented: Bool = false
    @State private var isBankCardsViewPresented: Bool = false
    @State private var isWantThisRequestsViewPresented: Bool = false
    @State private var isSupportServiceViewPresented: Bool = false
    @State private var isOrdersViewPresented: Bool = false
    @State private var profileMode: ProfileDetailView.Mode = .view
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    if AuthStorage.shared.getRefreshToken().isEmpty {
                        VStack(spacing: 12) {
                            Text(IPBSettings.authDescription)
                                .font(Style.title)
                                .foregroundColor(Style.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            CustomButtonView(title: "Авторизоваться") {
                                AuthorizationViewModel.shared.isLoggedIn = false
                                AuthorizationViewModel.shared.isNewUser = true
                            }
                        }
                        .padding(12)
                        .background(Style.surface)
                        .cornerRadius(8)
                    } else {
                        ProfileLinkCardView() {
                            isProfileDetailViewPresented = true
                        }
                    }
                    NavigationButtonView(title: "Мои заказы") {
                        isOrdersViewPresented = true
                    }
                    NavigationButtonView(title: "Хочу это") {
                        isWantThisRequestsViewPresented = true
                    }
                    NavigationButtonView(title: "Документы") {
                        isDocumentsViewPresented = true
                    }
                    NavigationButtonView(title: "Банковские карты") {
                        isBankCardsViewPresented = true
                    }
                    NavigationButtonView(
                        title: "Служба поддержки",
                        badgeCount: supportServiceVM.totalUnreadMessages
                    ) {
                        isSupportServiceViewPresented = true
                    }
                    NavigationButtonView(title: "Выйти из аккаунта", isDestructive: true) {
                        AuthStorage.shared.logout()
                        AuthorizationViewModel.shared.isLoggedIn = false
                        AuthorizationViewModel.shared.logoutToken()
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .background(Style.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $isAuthViewPresented) {
                AuthorizationView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isOrdersViewPresented) {
                OrdersView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isWantThisRequestsViewPresented) {
                WantThisRequestsView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isDocumentsViewPresented) {
                DocumentsView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isBankCardsViewPresented) {
                BankCardsView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isSupportServiceViewPresented) {
                SupportServiceView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isProfileDetailViewPresented) {
                ProfileDetailView(
                    mode: $profileMode,
                    submitAction: {
                        switch profileMode {
                        case .view:
                            profileMode = .edit
                        case .edit:
                            profileMode = .view
                            profileVM.patchClientData()
                        default: ()
                        }
                    }
                )
                .toolbarRole(.editor)
            }
        }
    }
}
