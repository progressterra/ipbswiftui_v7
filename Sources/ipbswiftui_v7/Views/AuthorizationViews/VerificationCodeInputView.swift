//
//  VerificationCodeInputView.swift
//  
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

/// `VerificationCodeInputView` provides an interface for users to enter a verification code received via SMS.
///
/// This view includes a text field for entering the code and two primary actions: submitting the code to log in and requesting a new code if necessary. The view updates dynamically based on the code entered and the remaining time for code validity.
///
/// ## Features
/// - **Code Input:** Allows users to input the SMS verification code they received.
/// - **Dynamic Interactions:** The login button is only enabled when the correct number of digits (typically 4) are entered to reduce errors.
/// - **Automatic Progression:** Automatically attempts to log in once the correct number of digits are entered, improving user flow.
/// - **Resend Option:** Users can request a new code if the current one expires or doesn't work, with a timer showing the remaining time until a new request is allowed.
///
/// ## Usage
///
/// This view is typically presented when a user needs to verify their phone number as part of an authentication process:
///
/// ```swift
/// VerificationCodeInputView(
///     timeRemaining: $timeRemaining,
///     codeFromSMS: $codeFromSMS,
///     phoneNumber: "79999999999",
///     loginAction: {
///         print("Login action triggered")
///     },
///     requestNewCodeAction: {
///         print("Request new code action triggered")
///     }
/// )
/// ```
///
/// ## Parameters
/// - `timeRemaining`: A binding to an `Int` that tracks the remaining time to request a new code.
/// - `codeFromSMS`: A binding to a `String` that holds the code entered by the user.
/// - `phoneNumber`: A `String` representing the user's phone number, used for display or reference.
/// - `loginAction`: A closure that is called when the user presses the login button and the input code is valid.
/// - `requestNewCodeAction`: A closure that is called when the user requests a new verification code.
///
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
                        .foregroundStyle(Style.textPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    CustomProgressView(isLoading: codeFromSMS.count == 4)
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
