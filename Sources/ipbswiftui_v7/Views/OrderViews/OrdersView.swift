//
//  OrdersView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 07.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct OrdersView: View {
    @EnvironmentObject var vm: OrdersViewModel
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let orders = vm.orderList?.dataList {
                    ForEach(orders, id: \.idUnique) { order in
                        NavigationLink(destination: OrderDetailView(order: order).toolbarRole(.editor)) {
                            OrderDetailView(order: order, isInList: true)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Style.background)
        .safeAreaPadding()
        .refreshable { vm.getOrderList() }
        .onAppear(perform: vm.getOrderList)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Мои заказы")
                    .foregroundColor(Style.textPrimary)
                    .font(Style.title)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
    }
}
