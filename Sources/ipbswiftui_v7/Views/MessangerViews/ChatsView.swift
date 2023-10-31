//
//  ChatsView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 08.08.2023.
//

import SwiftUI

public struct ChatsView: View {
    
    @EnvironmentObject var vm: MessengerViewModel
    
    @State private var isPresented = false
    
    let category: String
    
    public init(category: String) {
        self.category = category
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let dialogs = vm.dialogList?.dataList {
                    ForEach(dialogs, id: \.idUnique) { dialog in
                        NavigationButtonView(
                            title: dialog.description ?? "Диалог",
                            badgeCount: vm.dialogsNotifications?[dialog.idUnique]?.unreadMessages
                        ) {
                            vm.messages = nil
                            vm.currentDialog = dialog
                            isPresented = true
                        }
                    }
                    .transition(.push(from: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .animation(.default, value: vm.dialogList?.result.xRequestID)
        .safeAreaPadding()
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(category)
                    .foregroundColor(Style.textPrimary)
                    .font(Style.title)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .navigationDestination(isPresented: $isPresented) {
            ChatView().toolbarRole(.editor)
        }
    }
}
