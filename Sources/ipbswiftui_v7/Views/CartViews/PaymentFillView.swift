//
//  PaymentFillView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct PaymentFillView: View {
    @EnvironmentObject var vm: CartViewModel
    
    public enum PaymentOption: DisplayOptionProtocol {
        case internalPay
        case onlineByCard
        case byCardOnReceive
        case sbp
        case sberPay
        
        public var rawValue: String {
            switch self {
            case .internalPay: return "С внутреннего счёта"
            case .onlineByCard: return "Картой онлайн"
            case .byCardOnReceive: return "Картой при получении"
            case .sbp: return "SBP"
            case .sberPay: return "SberPay"
            }
        }
    }
    
    @State private var promoCode: String = ""
    @State private var isReceiveReceiptOnEmail: Bool = false
    @State private var email: String = ""
    
    public var body: some View {
        VStack(spacing: 8) {
            PaymentMethodPickerView(
                value: $vm.paymentOption,
                options: [.internalPay, .onlineByCard]
            )
            
            BonusesToggleView(
                availableBonuses: vm.availableBonuses,
                isBonusesApplied: $vm.isBonusesApplied
            )
            
            ReceiptView()
        }
    }
}
