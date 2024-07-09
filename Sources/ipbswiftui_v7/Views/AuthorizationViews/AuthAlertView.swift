//
//  AuthAlertView.swift
//  
//
//  Created by Artemy Volkov on 15.09.2023.
//

import SwiftUI

/// The `AuthAlertView` displays an alert with an "Авторизоваться" button.
/// It can be used to inform users about an action requiring authorization.
public struct AuthAlertView: View {
    @Binding var isPresented: Bool?
    let message: String
    let authAction: () -> ()
    
    public init(isPresented: Binding<Bool?> = .constant(nil), message: String, authAction: @escaping () -> Void) {
        self._isPresented = isPresented
        self.message = message
        self.authAction = authAction
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            if isPresented != nil {
                HStack {
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image("xmark", bundle: .module)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Style.iconsTertiary)
                    }
                }
            }
            
            Text(message)
                .font(Style.title)
                .foregroundStyle(Style.textPrimary)
                .multilineTextAlignment(.center)
            
            CustomButtonView(title: "Авторизоваться", action: authAction)
        }
        .padding(20)
        .background(Style.surface)
        .cornerRadius(8)
    }
}
