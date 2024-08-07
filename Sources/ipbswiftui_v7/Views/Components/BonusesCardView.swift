//
//  BonusesCardView.swift
//  
//
//  Created by Artemy Volkov on 20.07.2023.
//

import SwiftUI

/// A view that displays the user's bonuses information including their current bonuses count, withdrawal options, and installment options.
///
/// ## Usage example
/**
```swift
 BonusesCardView(
     currentBonusesCount: 0,
     equivalentOfOneBonus: 1,
     availableWithdrawalAmount: withdrawalVM.clientBalanceAmount ?? 0,
     availableInstalmentAmount: 0,
     isButtonsShowing: true,
     authDescription: IPBSettings.authDescription,
     isAuthorized: !AuthStorage.shared.getRefreshToken().isEmpty,
     isCardAdded: withdrawalVM.documentList?.dataList != nil,
     addCardAction: { isAddCardViewPresented = true },
     authAction: {
         AuthorizationViewModel.shared.isLoggedIn = false
         AuthorizationViewModel.shared.isNewUser = true
     },
     bonusesHistoryAction: { isBonusesHistoryViewPresented = true },
     subtractAction: { isWithdrawalViewPresented = true }
 )
```
 */
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
                    .foregroundStyle(Style.textButtonPrimary)
                
                Spacer()
                if isButtonsShowing, isAuthorized {
                    Button(action: bonusesHistoryAction) {
                        Image("arrowLinkIcon", bundle: .module)
                            .foregroundStyle(Style.primary)
                    }
                }
            }
            
            if isAuthorized {
                if let equivalentOfOneBonus, isCardAdded {
                    Text("1 бонус = \(equivalentOfOneBonus.asCurrency(fractionDigits: 2))")
                        .font(Style.subheadlineRegular)
                        .foregroundStyle(Style.textSecondary)
                } else {
                    Button(action: addCardAction) {
                        Text("Добавить карту")
                            .foregroundStyle(Style.textButtonPrimary)
                            .font(Style.subheadlineBold)
                            .frame(height: 18)
                    }
                }
                
                HStack {
                    Text("Можно вывести \(availableWithdrawalAmount.asCurrency())")
                        .font(Style.subheadlineItalic)
                        .foregroundStyle(Style.textTertiary)
                        .bold()
                    
                    Spacer()
                    if isButtonsShowing {
                        Button(action: subtractAction) {
                            Image("subtractIcon", bundle: .module)
                                .foregroundStyle( Style.primary)
                        }
                    }
                }
                
                HStack(spacing: 0) {
                    Text("Доступна рассрочка - ")
                    Text("до \(availableInstalmentAmount.asCurrency())")
                        .bold()
                }
                .font(Style.subheadlineRegular)
                .foregroundStyle(Style.textButtonPrimary)
            } else {
                Text(authDescription)
                    .font(Style.subheadlineBold)
                    .foregroundStyle(Style.textButtonPrimary)
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
