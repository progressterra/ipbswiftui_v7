//
//  AuthorizationBannerView.swift
//  
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

/// The `AuthorizationBannerView` displays `authorizationBanner`
/// image defined in project assets with two options:
/// "Авторизоваться" and "Пока пропустить".
/// It can be used to prompt users to log in or skip the process.
public struct AuthorizationBannerView: View {
    let authAction: () -> ()
    let skipAction: () -> ()
    
    public init(authAction: @escaping () -> (), skipAction: @escaping () -> ()) {
        self.authAction = authAction
        self.skipAction = skipAction
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            Image("authorizationBanner")
                .resizable()
                .scaledToFit()
                .padding()
            
            Spacer(minLength: 80)
            
            VStack(spacing: 8) {
                CustomButtonView(title: "Авторизоваться", action: authAction)
                
                Button(action: skipAction) {
                    Text("Пока пропустить")
                        .foregroundStyle(Style.textDisabled)
                        .font(Style.body)
                        .bold()
                        .padding(.vertical, 15)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Style.background)
    }
}
