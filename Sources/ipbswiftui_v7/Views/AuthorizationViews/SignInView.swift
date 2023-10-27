//
//  SignInView.swift
//  
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

public struct SignInView: View {
    @Binding var phoneNumber: String
    let offerLink: String
    let privacyPolicyLink: String
    let authAction: () -> ()
    let skipAction: () -> ()
    
    @State private var displayedPhoneNumber: String = ""
    @State private var isAuthButtonDisabled: Bool = true
    @FocusState private var isFocused: Bool
    
    public init(
        phoneNumber: Binding<String>,
        offerLink: String,
        privacyPolicyLink: String,
        authAction: @escaping () -> (),
        skipAction: @escaping () -> ()
    ) {
        self._phoneNumber = phoneNumber
        self.offerLink = offerLink
        self.privacyPolicyLink = privacyPolicyLink
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
                    .onChange(of: phoneNumber) { isAuthButtonDisabled = $0.count < 10 }
                    .onAppear {
                        isFocused = true
                        isAuthButtonDisabled = phoneNumber.count < 10
                    }
                    .focused($isFocused)
                    .modifier(
                        PhoneNumberFormatterModifier(
                            phoneNumber: $phoneNumber,
                            displayedPhoneNumber: $displayedPhoneNumber
                        )
                    )
                
                VStack {
                    Text("Нажимая кнопку «Авторизоваться», я соглашаюсь")
                    HStack(spacing: 5) {
                        Text("c")
                        Link("офертой", destination: URL(string: offerLink)!)
                            .overlay(alignment: .bottom) {
                                Rectangle().frame(height: 0.5)
                            }
                        Text("и")
                        Link("политикой конфиденциальности", destination: URL(string: privacyPolicyLink)!)
                            .overlay(alignment: .bottom) {
                                Rectangle().frame(height: 0.5)
                            }
                    }
                }
                .font(Style.footnoteRegular)
                .foregroundColor(Style.textDisabled)
                
                Spacer()
                
                VStack(spacing: 8) {
                    CustomButtonView(title: "Авторизоваться", isDisabled: $isAuthButtonDisabled, action: authAction)
                    
                    Button(action: skipAction) {
                        Text("Пока пропустить")
                            .foregroundColor(Style.textDisabled)
                            .font(Style.body)
                            .bold()
                            .padding(.vertical, 15)
                    }
                }
                .padding(8)
                .padding(.bottom, 30)
                .background(Style.surface)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea(.bottom)
            .onTapGesture { isFocused = false }
            .padding(.horizontal)
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Авторизация")
                        .font(Style.title)
                        .foregroundColor(Style.textPrimary)
                }
            }
        }
    }
}

struct Previews_SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(phoneNumber: .constant("79269300718"), offerLink: "f", privacyPolicyLink: "f", authAction: {}, skipAction: {})
    }
}
