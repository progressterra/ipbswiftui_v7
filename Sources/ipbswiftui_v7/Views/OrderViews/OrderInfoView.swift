//
//  OrderInfoView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 09.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

struct OrderInfoView: View {
    let order: DHSaleHeadAsOrderViewModel

    init(order: DHSaleHeadAsOrderViewModel) {
        self.order = order
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Заказ от \(order.dateAdded.format(as: "d MMMM"))")
                .foregroundStyle(Style.textPrimary)
                .font(Style.title)
            Text(order.numberInt.formatted())
                .foregroundStyle(Style.textTertiary)
                .font(Style.footnoteRegular)
            Text(getStatusString(for: order.statusOrder))
                .foregroundStyle(Style.textPrimary)
                .font(Style.subheadlineBold)
            
            HStack(spacing: 5) {
                Text(getOrderQuantityString(order.listDRSale))
                    .foregroundStyle(Style.textPrimary)
                Text(getOrderEndPriceString(order.listDRSale))
                    .foregroundStyle( Style.primary)
                Spacer()
            }
            .font(Style.body)
        }
        .multilineTextAlignment(.leading)
    }
    
    private func getStatusString(for status: TypeStatusOrder?) -> String {
        switch status {
        case .oneClick:
            return "Быстрый заказ"
        case .cart:
            return "Корзина"
        case .order:
            return "Заказ"
        case .confirmFromStore:
            return "Подтверждение из магазина"
        case .confirmFromCallCenter:
            return "Ожидает подтверждения оператора"
        case .sentToWarehouse:
            return "Отправлен на склад"
        case .sentDeliveryService:
            return "Передан в службу доставки"
        case .onPickUpPoint:
            return "В пункте выдачи"
        case .delivered:
            return "Доставлен"
        case .canceled:
            return "Отменен"
        case .none:
            return ""
        }
    }
    
    private func getOrderQuantityString(_ saleItems: [DRSaleForCartAndOrder]?) -> String {
        guard let saleItems else { return "" }
        
        let quantity = saleItems.reduce(0) { $0 + $1.quantity }
        let quantityString: String
        
        if quantity > 1 {
            quantityString = "\(quantity) товара"
        } else {
            quantityString = "\(quantity) товар"
        }
        
        return "\(quantityString) на сумму "
    }
    
    private func getOrderEndPriceString(_ saleItems: [DRSaleForCartAndOrder]?) -> String {
        guard let saleItems else { return "" }
        let totalAmount = saleItems.reduce(0) { $0 + ($1.amountEndPrice * Double($1.quantity)) }
        return totalAmount.asCurrency()
    }
}
