//
//  CheckoutFinalView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct CheckoutFinalView: View {
    @EnvironmentObject var vm: CartViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var isOrderViewPresented: Bool = false
    
    public var body: some View {
        VStack(spacing: 12) {
            Text("Заказ успешно оплачен")
                .font(Style.title)
                .foregroundStyle(Style.onBackground)
            if let orderNumber = vm.cartResult?.data?.numberInt {
                Text("Номер заказа: \(orderNumber)")
                    .font(Style.subheadlineRegular)
                    .foregroundStyle(Style.textTertiary)
            }
            
            VStack(spacing: 4) {
                Text(getProductWord(count: vm.cartItemsCount))
                    .font(Style.subheadlineBold)
                    .foregroundStyle(Style.onBackground)
                
                if let dateTranssferToSend = vm.cartResult?.data?.dateTranssferToSend {
                    Text("Доставка ожидается:")
                        .font(Style.footnoteBold)
                        .foregroundStyle(Style.textTertiary)
                    Text(dateTranssferToSend.format(as: "dd.MM.yyyy"))
                        .font(Style.footnoteRegular)
                        .foregroundStyle(Style.textSecondary)
                    
                }
                
                if let address = vm.cartResult?.data?.adressString {
                    Text("Адрес доставки:")
                        .font(Style.footnoteBold)
                        .foregroundStyle(Style.textTertiary)
                    Text(address)
                        .font(Style.footnoteRegular)
                        .foregroundStyle(Style.textSecondary)
                }
            }
            
            CustomButtonView(title: "Перейти к заказу", isOpaque: true) {
                isOrderViewPresented = true
                vm.cartResult = nil
            }
        }
        .multilineTextAlignment(.center)
        .padding(12)
        .background(Style.surface)
        .cornerRadius(12)
        .onDisappear { vm.cartResult = nil }
        .onAppear {
            if vm.cartResult == nil {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $isOrderViewPresented) {
            if let order = vm.order {
                OrderDetailView(order: order).toolbarRole(.editor)
            }
        }
    }
    
    private func getProductWord(count: Int) -> String {
        let lastDigit = count % 10
        if count % 100 >= 11 && count % 100 <= 14 {
            return "\(count) товаров оплачено"
        } else if lastDigit == 1 {
            return "\(count) товар оплачен"
        } else if lastDigit >= 2 && lastDigit <= 4 {
            return "\(count) товара оплачено"
        } else {
            return "\(count) товаров оплачено"
        }
    }
}
