//
//  SendMessageBarView.swift
//  
//
//  Created by Artemy Volkov on 10.08.2023.
//

import SwiftUI

public struct SendMessageBarView: View {
    
    @Binding var currentMessageText: String
    let sendMessageAction: () -> Void
    
    @FocusState var isFocused: Bool
    
    public init(currentMessageText: Binding<String>, sendMessageAction: @escaping () -> Void) {
        self._currentMessageText = currentMessageText
        self.sendMessageAction = sendMessageAction
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            TextField(text: $currentMessageText, axis: .vertical) {
                Text("Сообщение")
                    .foregroundStyle(Style.textDisabled)
            }
            .foregroundStyle(Style.textPrimary)
            .focused($isFocused)
            .animation(.default, value: currentMessageText)
            
            Spacer(minLength: 32)
        }
        .frame(minHeight: 46)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Style.onSurface)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 1)
                .foregroundStyle(Style.iconsTertiary)
                .clipped()
        }
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 2)
                    .foregroundStyle( Style.primary)
                    .clipped()
            }
        }
        .overlay(alignment: .trailing) {
            Button(action: sendMessageAction) {
                Image("fluentSendIcon", bundle: .module)
                    .foregroundStyle( Style.primary)
            }
            .disabled(currentMessageText.isEmpty)
            .padding(.trailing, 8)
        }
        .cornerRadius(8)
        .animation(.default, value: isFocused)
    }
}
