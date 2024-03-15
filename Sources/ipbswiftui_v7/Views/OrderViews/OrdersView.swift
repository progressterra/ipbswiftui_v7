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
    
    let isTrackable: Bool
    let isProductCouldBePresented: Bool
    
    public init(isTrackable: Bool = true, isProductCouldBePresented: Bool = true) {
        self.isTrackable = isTrackable
        self.isProductCouldBePresented = isProductCouldBePresented
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let orders = vm.orderList?.dataList {
                    ForEach(orders, id: \.idUnique) { order in
                        NavigationLink(destination: OrderDetailView(order: order, isTrackable: isTrackable, isProductCouldBePresented: isProductCouldBePresented).toolbarRole(.editor)) {
                            OrderDetailView(order: order, isInList: true)
                        }
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Style.background)
        .refreshable { vm.getOrderList() }
        .onAppear(perform: vm.getOrderList)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Мои заказы")
                    .foregroundStyle(Style.textPrimary)
                    .font(Style.title)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
    }
}
