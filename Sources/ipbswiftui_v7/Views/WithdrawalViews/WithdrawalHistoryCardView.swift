//
//  WithdrawalHistoryCardView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct WithdrawalHistoryCardView: View {
    let amount: Double
    let cardNumber: String
    let dateString: String
    let status: TypeResultOperationBusinessArea
    
    public init(amount: Double, cardNumber: String, dateString: String, status: TypeResultOperationBusinessArea) {
        self.amount = amount
        self.cardNumber = cardNumber
        self.dateString = dateString
        self.status = status
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(amount.asCurrency())
                    .font(Style.headline)
                    .foregroundStyle(Style.textPrimary)
                Spacer()
                Text(dateString.convertDateFormat(to: "dd.MM.yyyy"))
            }
            
            Text(cardNumber)
                .font(Style.subheadlineRegular)
                .foregroundStyle(Style.textPrimary)
            Text(statusString)
                .font(Style.footnoteRegular)
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Style.surface)
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .inProgress: return Style.textTertiary
        case .success: return Style.onBackground
        case .withError: return Style.textPrimary2
        }
    }
    
    private var statusString: String {
        switch status {
        case .inProgress: return "Транзакция в процессе"
        case .success: return "Транзакция прошла успешно"
        case .withError: return "Ошибка, средства остались на вашем счету"
        }
    }
}
