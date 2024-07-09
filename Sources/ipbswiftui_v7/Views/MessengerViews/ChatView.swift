//
//  ChatView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 07.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct ChatView: View {
    
    @EnvironmentObject var vm: MessengerViewModel
    
    @FocusState private var isFocused: Bool
    
    public init() {}
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 8) {
                    if let messages = vm.messages?.dataList, !messages.isEmpty {
                        ForEach(messages, id: \.idUnique) { message in
                            MessageView(
                                contentText: message.contentText ?? "",
                                dateAdded: message.dateAdded,
                                isOwnMessage: message.isOwnMessage,
                                backgroundColor: Style.surface
                            )
                            .id(message.idUnique)
                            .contextMenu {
                                Button("Изменить") {
                                    vm.currentMessageText = message.contentText ?? ""
                                    vm.messageToUpdate = message
                                    isFocused = true
                                }
                            }
                        }
                    } else {
                        Text("Сообщений пока нет")
                            .font(Style.title)
                            .padding()
                            .opacity(vm.messages == nil ? 0 : 1)
                            .animation(.default.delay(0.5), value: vm.messages == nil)
                    }
                }
                .padding()
            }
            .animation(.default, value: vm.messages?.dataList?.count)
            .onReceive(vm.$messages) { proxy.scrollTo($0?.dataList?.last?.idUnique) }
            .id(vm.messages?.result.xRequestID)
            .refreshable { vm.getMessageList() }
            .frame(maxWidth: .infinity)
            .background(Style.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(vm.currentDialog?.description ?? "")
                        .foregroundStyle(Style.textPrimary)
                        .font(Style.title)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .onTapGesture { isFocused = false }
            .safeAreaInset(edge: .bottom) {
                SendMessageBarView(currentMessageText: $vm.currentMessageText) {
                    if let messageToUpdate = vm.messageToUpdate {
                        vm.updateMessage(messageToUpdate)
                    } else {
                        vm.sendMessage()
                    }
                }
                .focused($isFocused)
                .padding(.horizontal)
            }
        }
        .onDisappear {
            vm.messages = nil
            vm.messageToUpdate = nil
            vm.currentDialog = nil
            vm.currentMessageText = ""
        }
    }
}
