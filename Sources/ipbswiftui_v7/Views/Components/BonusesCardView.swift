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
            
            Spacer().frame(height: 30)
            
            HStack{
                Spacer()
                Image("logo", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width / 3)
                
                Spacer()
            }
            
            Spacer().frame(height: 5)
            
                //.position(x: UIScreen.main.bounds.width / 2)
            
            if isAuthorized {
                
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("Ваш баланс")
                            .font(Style.title)
                            .foregroundStyle(Style.textTertiary)
                            .bold()
                        Text("\(currentBonusesCount.clean) баллов")
                            .font(Style.title)
                            .foregroundStyle(Style.textButtonPrimary)
                    }
                    Spacer()
                    if isButtonsShowing {
                        Button(action: subtractAction) {
                            Image("avatar", bundle: .module)
                                .foregroundStyle( Style.primary)
                        }
                    }
                }
                
                
//                HStack {
//                    Text("Ваш баланс")
//                        .font(Style.title)
//                        .foregroundStyle(Style.textTertiary)
//                        .bold()
//                    
//                    Spacer()
//                    if isButtonsShowing {
//                        Button(action: subtractAction) {
//                            Image("subtractIcon", bundle: .module)
//                                .foregroundStyle( Style.primary)
//                        }
//                    }
//                }
//                
//                HStack {
//                    Text("\(currentBonusesCount.clean) баллов")
//                        .font(Style.title)
//                        .foregroundStyle(Style.textButtonPrimary)
//                    
//                    Spacer()
//                    if isButtonsShowing, isAuthorized {
//                        Button(action: bonusesHistoryAction) {
//                            Image("arrowLinkIcon", bundle: .module)
//                                .foregroundStyle(Style.primary)
//                        }
//                    }
//                }
                
                
                
                
                
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
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xFF53B8EB),
                                                               Color(hex: 0xFF27D1AE)]), startPoint: .leading, endPoint: .trailing))
        //.cornerRadius(12)
    }
}

struct BonusesCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            BonusesCardView(currentBonusesCount: 12500, equivalentOfOneBonus: 1.25, availableWithdrawalAmount: 10000, availableInstalmentAmount: 60000, isButtonsShowing: true, authDescription: "Авторизуйтесь, чтобы заказывать товары, копить бонусы и видеть доступную рассрочку.", isAuthorized: true, isCardAdded: false)
             
            Text("Lfnfdf ")
        }
    }
}




extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
