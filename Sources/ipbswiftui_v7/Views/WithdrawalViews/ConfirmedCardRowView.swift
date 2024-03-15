//
//  ConfirmedCardRowView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

public struct ConfirmedCardRowView: View {
    let cardNumber: String
    let isMain: Bool
    
    public init(cardNumber: String, isMain: Bool) {
        self.cardNumber = cardNumber
        self.isMain = isMain
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text(cardNumber)
                .font(Style.subheadlineRegular)
                .foregroundStyle(Style.textPrimary)
            if isMain {
                Text("Основная")
                    .font(Style.footnoteRegular)
                    .foregroundStyle(Style.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 50)
        .padding(.horizontal)
        .background(Style.surface)
        .cornerRadius(8)
    }
}
