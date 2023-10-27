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
                
                Spacer()
                VStack(spacing: 8) {
                    CustomButtonView(title: "Далее", isDisabled: $isAuthButtonDisabled, action: loginAction)
                        .animation(.default, value: isAuthButtonDisabled)
                    
                    NewCodeRequestRemainingView(timeRemaining: $timeRemaining, requestNewCodeAction: requestNewCodeAction)
                }
                .padding(.bottom, 35)
                .padding(8)
                .background(Style.surface)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .padding(.horizontal)
                
            }
            .edgesIgnoringSafeArea(.bottom)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Код подтверждения")
                        .font(Style.title)
                        .foregroundColor(Style.textPrimary)
                }
            }
            .onChange(of: codeFromSMS) { isAuthButtonDisabled = $0.count != 4 }
        }
    }
}
