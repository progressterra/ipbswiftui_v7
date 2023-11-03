//
//  VerificationCodeInputView.swift
//  
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

public struct VerificationCodeInputView: View {
    
    @Binding var timeRemaining: Int
    @Binding var codeFromSMS: String
    let phoneNumber: String
    let loginAction: () -> ()
    let requestNewCodeAction: () -> ()
    
    @FocusState private var isFocused: Bool
    @State private var isAuthButtonDisabled: Bool = true
    
    public init(
        timeRemaining: Binding<Int>,
        codeFromSMS: Binding<String>,
        phoneNumber: String,
        loginAction: @escaping () -> (),
        requestNewCodeAction: @escaping () -> ()
    ) {
        self._timeRemaining = timeRemaining
        self._codeFromSMS = codeFromSMS
        self.phoneNumber = phoneNumber
        self.loginAction = loginAction
        self.requestNewCodeAction = requestNewCodeAction
    }
    
    public var body: some View {
        ZStack {
            Style.background
                .ignoresSafeArea()
                .onTapGesture(perform: hideKeyboard)
            
            VStack {
                CodeInputFieldView(codeString: $codeFromSMS, phoneNumber: phoneNumber)
                    .padding(.horizontal)
                    .focused($isFocused)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Код подтверждения")
                        .font(Style.title)
                        .foregroundColor(Style.textPrimary)
                }
            }
            .onChange(of: codeFromSMS) { isAuthButtonDisabled = $0.count != 4 }
        }
        .overlay(alignment: .bottom) {
            VStack(spacing: 8) {
                CustomButtonView(title: "Далее", isDisabled: $isAuthButtonDisabled, action: loginAction)
                    .onChange(of: isAuthButtonDisabled) { if !$0 { loginAction() } }
                
                if !isFocused {
                    NewCodeRequestRemainingView(timeRemaining: $timeRemaining, requestNewCodeAction: requestNewCodeAction)
                        .padding(.vertical, 15)
                }
            }
            .padding(.bottom, 24)
            .padding(.horizontal)
            .animation(.default, value: isAuthButtonDisabled)
            .animation(.default, value: isFocused)
        }
    }
}
