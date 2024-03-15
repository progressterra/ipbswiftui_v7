//
//  GetReceiptByMailToggleView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct GetReceiptByMailToggleView: View {
    @Binding var email: String
    @Binding var isReceiveOnMail: Bool
    
    public init(email: Binding<String>, isReceiveOnMail: Binding<Bool>) {
        self._email = email
        self._isReceiveOnMail = isReceiveOnMail
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Получить чек на почту")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
                Spacer()
                
                CustomToggleView(isOn: $isReceiveOnMail)
            }
            
            CustomTextFieldView(
                text: $email,
                prompt: "Почта для чека",
                backgroundColor: Style.background
            )
        }
        .padding(12)
        .background(Style.surface)
        .cornerRadius(12)
    }
}
