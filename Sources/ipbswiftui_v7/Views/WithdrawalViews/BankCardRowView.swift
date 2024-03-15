//
//  BankCardRowView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 14.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct BankCardRowView: View {
    
    let cardNumber: String
    var cardStatus: TypeStatusDoc?
    let removeAction: () -> ()
    
    private var statusTitle: String {
        switch cardStatus {
        case .confirmed: return "Подтверждена"
        case .rejected: return "Отклонена"
        case .waitImage: return "Ожидает изображения"
        case .waitReview: return "Ожидает проверки"
        default: return "Не заполнена"
        }
    }
    
    private var statusColor: Color {
        switch cardStatus {
        case .confirmed: return Style.onBackground
        case .rejected: return Style.textPrimary2
        default: return Style.textTertiary
        }
    }
    
    public init(cardNumber: String, cardStatus: TypeStatusDoc? = nil, removeAction: @escaping () -> Void) {
        self.cardNumber = cardNumber
        self.cardStatus = cardStatus
        self.removeAction = removeAction
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("Номер карты " + maskCreditCardNumber(cardNumber))
                    .font(Style.subheadlineRegular)
                    .foregroundStyle(Style.textPrimary)
                
                if let _ = cardStatus {
                    Text(statusTitle)
                        .font(Style.footnoteRegular)
                        .foregroundStyle(statusColor)
                }
            }
            Spacer()
            
            Button(action: removeAction) {
                Image("trashCan", bundle: .module)
                    .foregroundStyle(Style.iconsTertiary)
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(Style.surface)
        .cornerRadius(8)
    }
    
    private func maskCreditCardNumber(_ number: String) -> String {
        let sanitizedNumber = number.replacingOccurrences(of: " ", with: "")
        guard sanitizedNumber.count >= 4 else { return "****" }
        let lastFourDigits = sanitizedNumber.suffix(4)
        return "****\(lastFourDigits)"
    }
}

struct Previews_BankCardRowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            
            BankCardRowView(cardNumber: "343431421432324", cardStatus: .confirmed, removeAction: {})
        }
    }
}
