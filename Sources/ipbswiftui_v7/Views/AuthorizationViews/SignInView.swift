//
//  SignInView.swift
//
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

/// `SignInView` provides a user interface for phone number input and authorization with additional links to the offer and privacy policy.
///
/// This view includes a text field for entering a phone number, a button to perform authorization, and optional links to legal documents like terms of service (offer) and privacy policy. It supports navigation to different authentication flows, such as skipping the sign-in process if the user chooses.
///
/// ## Features
/// - **Phone Number Input:** Users can enter their phone number in a formatted field that validates the input based on the required number of digits.
/// - **Dynamic Authorization:** Authorization is handled through a callback function that can be customized depending on the consuming view's context.
/// - **Legal Agreements:** Provides hyperlinked text to detailed offer and privacy policy documents, ensuring compliance with legal standards.
/// - **Delayed Keyboard Presentation:** Optionally delays the keyboard presentation to enhance user experience.
/// - **Accessibility Features:** The view supports screen readers and provides adequate tap targets for users with motor disabilities.
///
/// ## Example Usage
///
///
///
/// ```swift
/// SignInView(
///     phoneNumber: $phoneNumber,
///     offerLink: "https://example.com/offer",
///     privacyPolicyLink: "https://example.com/privacy",
///     authAction: {
///         print("Authenticate")
///     },
///     skipAction: {
///         print("Skip Authentication")
///     }
/// )
/// ```
///
/// - Displayed number format +7(###)###-##-##
/// - Actual number format 7##########
///
public struct SignInView: View {
    @Binding var phoneNumber: String
    let offerLink: String
    let privacyPolicyLink: String
    let presentKeyboardDelay: Double
    let authAction: () -> ()
    let skipAction: (() -> ())?
    
    @State private var displayedPhoneNumber: String = ""
    @State private var isAuthButtonDisabled: Bool = true
    @FocusState private var isFocused: Bool
    
    public init(
        phoneNumber: Binding<String>,
        offerLink: String,
        privacyPolicyLink: String,
        presentKeyboardDelay: Double = 3,
        authAction: @escaping () -> (),
        skipAction: (() -> ())? = nil
    ) {
        self._phoneNumber = phoneNumber
        self.offerLink = offerLink
        self.privacyPolicyLink = privacyPolicyLink
        self.presentKeyboardDelay = presentKeyboardDelay
        self.authAction = authAction
        self.skipAction = skipAction
    }
    
    public var body: some View {
        ZStack {
            Style.background
                .ignoresSafeArea()
                .onTapGesture(perform: hideKeyboard)
            
            VStack(spacing: 20) {
                CustomTextFieldView(text: $displayedPhoneNumber, prompt: "Номер телефона")
                    .keyboardType(.phonePad)
                    .onChange(of: phoneNumber) { isAuthButtonDisabled = $0.count < 11 }
                    .onAppear {
                        isAuthButtonDisabled = phoneNumber.count < 11
                        DispatchQueue.main.asyncAfter(deadline: .now() + presentKeyboardDelay) {
                            isFocused = true
                        }
                    }
                    .focused($isFocused)
                    .modifier(
                        PhoneNumberFormatterModifier(
                            phoneNumber: $phoneNumber,
                            displayedPhoneNumber: $displayedPhoneNumber
                        )
                    )
                
                if let offerURL = URL(string: offerLink), let privacyPolicyURL = URL(string: privacyPolicyLink) {
                    VStack {
                        Text("Нажимая кнопку «Авторизоваться», я соглашаюсь")
                        HStack(spacing: 5) {
                            Text("c")
                            Link("офертой", destination: offerURL)
                                .overlay(alignment: .bottom) {
                                    Rectangle().frame(height: 0.5)
                                }
                            Text("и")
                            Link("политикой конфиденциальности", destination: privacyPolicyURL)
                                .overlay(alignment: .bottom) {
                                    Rectangle().frame(height: 0.5)
                                }
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(Style.textDisabled)
                }
                
                Spacer()
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 8) {
                    CustomButtonView(title: "Авторизоваться", isDisabled: $isAuthButtonDisabled, action: authAction)
                    
                    if let skipAction, !isFocused {
                        Button(action: skipAction) {
                            Text("Пока пропустить")
                                .foregroundStyle(Style.textDisabled)
                                .font(Style.body)
                                .bold()
                                .padding(.vertical, 15)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .onTapGesture { isFocused = false }
            .animation(.default, value: isFocused)
            .padding(.horizontal)
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Авторизация")
                        .font(Style.title)
                        .foregroundStyle(Style.textPrimary)
                }
            }
        }
    }
}
