//
//  BonusesCardView.swift
//  
//
//  Created by Artemy Volkov on 20.07.2023.
//

import SwiftUI

public struct BonusesCardView: View {
    let currentBonusesCount: Double
    let equivalentOfOneBonus: Double?
    let availableWithdrawalAmount: Double
    let availableInstalmentAmount: Double
    let isButtonsShowing: Bool
    let authDescription: String
    let isAuthorized: Bool
    let isCardAdded: Bool
    let addCardAction: () -> ()
    let authAction: () -> ()
    let bonusesHistoryAction: () -> ()
    let subtractAction: () -> ()
    
    public init(
        currentBonusesCount: Double,
        equivalentOfOneBonus: Double? = nil,
        availableWithdrawalAmount: Double,
        availableInstalmentAmount: Double,
        isButtonsShowing: Bool = false,
        authDescription: String,
        isAuthorized: Bool,
        isCardAdded: Bool,
        addCardAction: @escaping () -> () = {},
        authAction: @escaping () -> () = {},
        bonusesHistoryAction: @escaping () -> () = {},
        subtractAction: @escaping () -> () = {}
    ) {
        self.currentBonusesCount = currentBonusesCount
        self.equivalentOfOneBonus = equivalentOfOneBonus
        self.availableWithdrawalAmount = availableWithdrawalAmount
        self.availableInstalmentAmount = availableInstalmentAmount
        self.isButtonsShowing = isButtonsShowing
        self.isAuthorized = isAuthorized
        self.isCardAdded = isCardAdded
        self.addCardAction = addCardAction
        self.authDescription = authDescription
        self.authAction = authAction
        self.bonusesHistoryAction = bonusesHistoryAction
        self.subtractAction = subtractAction
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("У вас \(currentBonusesCount.clean) бонусов")
                    .font(Style.title)
                    .foregroundColor(Style.textButtonPrimary)
                
                Spacer()
                if isButtonsShowing, isAuthorized {
                    Button(action: bonusesHistoryAction) {
                        Image("arrowLinkIcon", bundle: .module)
                            .gradientColor(gradient: Style.primary)
                    }
                }
            }
            
            if isAuthorized {
                if let equivalentOfOneBonus, isCardAdded {
                    Text("1 бонус = \(equivalentOfOneBonus.asCurrency(fractionDigits: 2))")
                        .font(Style.subheadlineRegular)
                        .foregroundColor(Style.textSecondary)
                } else {
                    Button(action: addCardAction) {
                        Text("Добавить карту")
                            .foregroundColor(Style.textButtonPrimary)
                            .font(Style.subheadlineBold)
                            .frame(height: 18)
                    }
                }
                
                HStack {
                    Text("Можно вывести \(availableWithdrawalAmount.asCurrency())")
                        .font(Style.subheadlineItalic)
                        .foregroundColor(Style.textTertiary)
                        .bold()
                    
                    Spacer()
                    if isButtonsShowing {
                        Button(action: subtractAction) {
                            Image("subtractIcon", bundle: .module)
                                .gradientColor(gradient: Style.primary)
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    Text("Доступна рассрочка - ")
                    Text("до \(availableInstalmentAmount.asCurrency())")
                        .bold()
                }
                .font(Style.subheadlineRegular)
                .foregroundColor(Style.textButtonPrimary)
            } else {
                Text(authDescription)
                    .font(Style.subheadlineBold)
                    .foregroundColor(Style.textButtonPrimary)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical)
                
                CustomButtonView(title: "Авторизоваться", action: authAction)
            }
            
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Style.secondaryPressed)
        .cornerRadius(12)
    }
}

struct BonusesCardView_Previews: PreviewProvider {
    static var previews: some View {
        BonusesCardView(currentBonusesCount: 12500, equivalentOfOneBonus: 1.25, availableWithdrawalAmount: 10000, availableInstalmentAmount: 60000, isButtonsShowing: true, authDescription: "Авторизуйтесь, чтобы заказывать товары, копить бонусы и видеть доступную рассрочку.", isAuthorized: true, isCardAdded: false)
    }
}
