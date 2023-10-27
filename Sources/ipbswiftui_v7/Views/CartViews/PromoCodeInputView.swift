//
//  PromoCodeInputView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct PromoCodeInputView: View {
    @Binding var promoCode: String
    let description: String?
    
    public init(promoCode: Binding<String>, description: String? = nil) {
        self._promoCode = promoCode
        self.description = description
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomTextFieldView(
                text: $promoCode,
                prompt: "Промокод",
                backgroundColor: Style.background
            )
            
            if let description {
                Text(description)
                    .font(Style.subheadlineRegular)
                    .foregroundColor(Style.textSecondary)
                    .transition(.push(from: .top))
                    .animation(.default, value: description)
            }
        }
        .padding(12)
        .background(Style.surface)
        .cornerRadius(12)
    }
}
