//
//  CompactChatView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.08.2023.
//

import SwiftUI

public struct CompactChatView: View {
    @EnvironmentObject var vm: MessengerViewModel
    
    @Binding var isPresented: Bool
    
    @FocusState private var isFocused: Bool
    
    public init(isPresented: Binding<Bool>, isFocused: Bool = false) {
        self._isPresented = isPresented
        self.isFocused = isFocused
    }
    
    public var body: some View {
        if isPresented {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented = false
                            vm.getMessageList()
                        }) {
                            HStack(spacing: 4) {
                                Text("Закрыть чат")
                                    .font(Style.subheadlineRegular)
                                Image("xmark", bundle: .module)
                            }
                            .foregroundStyle(Style.iconsPrimary2)
                        }
                    }
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 8) {
                                if let messages = vm.messages?.dataList, !messages.isEmpty {
                                    ForEach(messages, id: \.idUnique) { message in
                                        MessageView(
                                            contentText: message.contentText ?? "",
                                            dateAdded: message.dateAdded,
                                            isOwnMessage: message.isOwnMessage,
                                            backgroundColor: Style.background
                                        )
                                        .id(message.idUnique)
                                    }
                                    .onAppear {
                                        withAnimation(.default.speed(0.25)) {
                                            proxy.scrollTo(messages.last?.idUnique ?? "")
                                        }
                                    }
                                } else {
                                    Text("")
                                        .font(Style.title)
                                        .padding()
                                        .opacity(vm.messages == nil ? 0 : 1)
                                        .animation(.default.delay(0.5), value: vm.messages == nil)
                                }
                            }
                            .padding()
                        }
                        .animation(.default, value: vm.messages?.result.xRequestID)
                        .refreshable { vm.getMessageList() }
                        .frame(maxWidth: .infinity)
                        .onTapGesture { isFocused = false }
                    }
                }
                .frame(height: 327)
                .padding(8)
                .background(Style.surface)
                .cornerRadius(8)
                .onAppear(perform: vm.getMessageList)
                .onDisappear { vm.messages = nil }
                
                SendMessageBarView(
                    currentMessageText: $vm.currentMessageText,
                    sendMessageAction: vm.sendMessage
                )
                .focused($isFocused)
                .onAppear { isFocused = true }
            }
            .transition(
                .asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top))
                .combined(with: .opacity)
            )
        }
    }
}
