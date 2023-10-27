//
//  ReceiptView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct ReceiptView: View {
    @EnvironmentObject var vm: CartViewModel
    
    let termsOfUseLink: String = "https://iprobonus.com"
    let iProBonusLink: String = "https://iprobonus.com"
    let sellerInfoLink: String = "https://iprobonus.com"
    
    public var body: some View {
        VStack {
            if let totalPrice = vm.cartResult?.data?.listDRSale?.reduce(0.0, { $0 + $1.amountEndPrice }), totalPrice != 0 {
                HStack {
                    Text("Итого к оплате:")
                    Spacer()
                    Text(totalPrice.asCurrency())
                }
                .font(Style.title)
                .foregroundColor(Style.textPrimary)
            }
            
            Divider()
                .padding(.horizontal, -12)
                .padding(.vertical, 12)
            
            if let cartItems = vm.cartResult?.data?.listDRSale {
                VStack(spacing: 12) {
                    ForEach(cartItems, id: \.idrfNomenclature) { item in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(item.nameGoods ?? "")
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if item.quantity > 1 {
                                    Text("x\(item.quantity)")
                                        .padding(.trailing)
                                }
                                Text(item.amountEndPrice.asCurrency())
                            }
                            .foregroundColor(Style.textSecondary)
                            
                            if item.numberInstallmentMonths > 0 {
                                Text("(в рассрочку - останется \(item.numberInstallmentMonths - 1) платежей)")
                                    .foregroundColor(Style.textTertiary)
                            }
                        }
                        .font(Style.footnoteRegular)
                    }
                    
                    Divider()
                }
                .padding(.horizontal, 12)
            }
            
            CustomButtonView(title: "Оплатить", isDisabled: $vm.isLoading) {
                vm.confirmCart()
                vm.currentCheckoutStageIndex += 1
            }
            .padding(.vertical, 20)
            
            VStack(spacing: 12) {
                VStack {
                    HStack(spacing: 5) {
                        Text("Нажимая «Оплатить» вы соглашаетесь с")
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                        Link("условиями", destination: URL(string: termsOfUseLink)!)
                            .overlay(alignment: .bottom) {
                                Rectangle().frame(height: 0.5)
                            }
                    }
                    HStack(spacing: 5) {
                        Link("использования", destination: URL(string: termsOfUseLink)!)
                            .overlay(alignment: .bottom) {
                                Rectangle().frame(height: 0.5)
                            }
                        Text("и оплаты сервиса")
                        Link("iprobonus.com", destination: URL(string: iProBonusLink)!)
                            .overlay(alignment: .bottom) {
                                Rectangle().frame(height: 0.5)
                            }
                    }
                }
                
                Link("Информация о товаре и продавце.", destination: URL(string: sellerInfoLink)!)
                    .overlay(alignment: .bottom) {
                        Rectangle().frame(height: 0.5)
                    }
            }
            .font(Style.footnoteRegular)
            .foregroundColor(Style.textSecondary)
            .padding(.bottom, 50)
        }
        .padding(12)
        .background(Style.surface)
        .cornerRadius(12, corners: [.topLeft, .topRight])
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ReceiptView()
                .environmentObject(CartViewModel.shared)
                .padding(8)
        }
    }
}
