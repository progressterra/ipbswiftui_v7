//
//  SupportServiceView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 07.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct SupportServiceView: View {
    
    @EnvironmentObject var vm: MessengerViewModel
    
    @State private var isChatPresented: Bool = false
    @State private var isChatsPresented: Bool = false
    @State private var currentCategory: String = ""
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Button(action: {
                    vm.fetchOrCreateDialog(for: .enterprise, with: "Техническая поддержка")
                    isChatPresented = true
                }) {
                    let notifications = vm.dialogsNotifications?[IPBSettings.techSupportID]
                    
                    let imageView = Image("techSupportIcon", bundle: .module)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    
                    ChatRowView(
                        imageView: imageView,
                        title: "Техническая поддержка",
                        prompt: notifications?.lastMessage?.contentText ?? "",
                        dateLastMessages: notifications?.dateLastMessages,
                        badgeCount: notifications?.unreadMessages
                    )
                }
                Button(action: {
                    performActionFor(category: "Заказы", supportID: IPBSettings.ordersSupportID)
                }) {
                    let imageView = Image("ordersSupportIcon", bundle: .module)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    
                    ChatRowView(
                        imageView: imageView,
                        title: "Заказы",
                        prompt: "",
                        dateLastMessages: .now,
                        badgeCount: 0
                    )
                }
                Button(action: {
                    performActionFor(category: "Чеки", supportID: IPBSettings.wantThisSupportID)
                }) {
                    let imageView = Image("wantThisSupportIcon", bundle: .module)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    
                    ChatRowView(
                        imageView: imageView,
                        title: "Чеки",
                        prompt: "",
                        dateLastMessages: .now,
                        badgeCount: 0
                    )
                }
//                Button(action: {
//                    performActionFor(category: "Документы", supportID: IPBSettings.documentsSupportID)
//                }) {
//                    let imageView = Image("documentsSupportIcon", bundle: .module)
//                        .resizable()
//                        .frame(width: 64, height: 64)
//                        .clipShape(Circle())
//                    
//                    ChatRowView(
//                        imageView: imageView,
//                        title: "Документы",
//                        prompt: "",
//                        dateLastMessages: .now,
//                        badgeCount: 0
//                    )
//                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Служба поддержки")
                    .foregroundStyle(Style.textPrimary)
                    .font(Style.title)
            }
        }
        .navigationDestination(isPresented: $isChatPresented) {
            ChatView()
                .toolbarRole(.editor)
        }
        .navigationDestination(isPresented: $isChatsPresented) {
            ChatsView(category: currentCategory).toolbarRole(.editor)
        }
    }
    
    private func performActionFor(category: String, supportID: String) {
        vm.dialogList = nil
        vm.getDialogList(for: supportID)
        currentCategory = category
        isChatsPresented = true
    }
}
