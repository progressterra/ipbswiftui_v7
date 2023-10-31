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
    
    public init(isFocused: Bool = false) {
        self.isFocused = isFocused
    }
    
    public var body: some View {
        ZStack {
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
                                .onAppear {
                                    if messages.last?.idUnique == message.idUnique {
                                        withAnimation(.default.speed(0.25)) {
                                            proxy.scrollTo(messages.last?.idUnique)
                                        }
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
                .id(vm.messages?.result.xRequestID)
                .animation(.default, value: vm.messages?.result.xRequestID)
                .refreshable { vm.getMessageList() }
                .frame(maxWidth: .infinity)
                .safeAreaPadding(value: 130)
                .background(Style.background)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(vm.currentDialog?.description ?? "")
                            .foregroundColor(Style.textPrimary)
                            .font(Style.title)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        CustomProgressView(isLoading: vm.isLoading)
                    }
                }
                .onTapGesture { isFocused = false }
            }
            
            VStack {
                Spacer()
                SendMessageBarView(currentMessageText: $vm.currentMessageText, sendMessageAction: vm.sendMessage)
                    .focused($isFocused)
            }
            .padding(.horizontal)
            .safeAreaPadding(value: isFocused ? 0 : 65)
        }
        .onDisappear { vm.messages = nil }
    }
}
