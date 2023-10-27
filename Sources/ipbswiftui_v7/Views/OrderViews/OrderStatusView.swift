//
//  OrderStatusView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 08.09.2023.
//

import SwiftUI
import ipbswiftapi_v7

struct OrderStatusView: View {
    @EnvironmentObject var vm: CartViewModel
    
    let order: DHSaleHeadAsOrderViewModel
    
    let orderStatuses: [TypeStatusOrder] = [
        .order,
        .confirmFromStore,
        .sentDeliveryService,
        .delivered
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(getOrderDescription(from: order.statusOrder))
                        .font(Style.title)
                        .foregroundColor(Style.textPrimary)
                    Text("Заказ от \(order.dateAdded.format(as: "d MMMM")) № \(order.numberInt)")
                        .font(Style.footnoteRegular)
                        .foregroundColor(Style.textTertiary)
                }
                
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(orderStatuses, id: \.self) { status in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(getOrderDescription(from: status))
                                .font(order.statusOrder == status ? Style.body : Style.subheadlineRegular)
                                .foregroundColor(order.statusOrder == status ? Style.textPrimary : Style.textSecondary)
                            
                            if let date = getOrderStatusDate(for: status) {
                                Text(date.format(as: "dd MMM yyyy, HH:mm"))
                                    .font(Style.footnoteRegular)
                                    .foregroundColor(Style.textTertiary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Style.surface)
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top)
        }
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Отслеживание")
                    .foregroundColor(Style.textPrimary)
                    .font(Style.title)
            }
        }
    }
    
    private func getOrderDescription(from statusOrder: TypeStatusOrder?) -> String {
        switch statusOrder {
        case .oneClick:
            return "Быстрый заказ"
        case .cart:
            return "В корзине"
        case .order:
            return "Заказ оформлен"
        case .confirmFromStore:
            return "Подтверждён магазином"
        case .confirmFromCallCenter:
            return "Подтверждён колл-центром"
        case .sentToWarehouse:
            return "Отправлен на склад"
        case .sentDeliveryService:
            return "Передан в службу доставки"
        case .onPickUpPoint:
            return "В пункте выдачи"
        case .delivered:
            return "Доставлен"
        case .canceled:
            return "Отменён"
        case .none:
            return ""
        }
    }
    
    private func getOrderStatusDate(for status: TypeStatusOrder) -> Date? {
        switch status {
        case .order:
            return order.dateAdded
        case .confirmFromStore:
            return order.dateConfirm
        case .sentDeliveryService:
            return order.dateStartProcessingDelivery
        case .delivered:
            return order.dateCustomerReceived
        case .canceled:
            return order.dateClose
        default:
            return nil
        }
    }
}
