//
//  OrderDetailView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 08.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct OrderDetailView: View {
    @EnvironmentObject var vm: OrdersViewModel
    @EnvironmentObject var supportServiceVM: MessengerViewModel
    
    let order: DHSaleHeadAsOrderViewModel
    let isInList: Bool
    let isTrackable: Bool
    let isProductCouldBePresented: Bool
    
    @State private var currentProduct: ProductViewDataModel?
    @State private var isProductDetailViewPresented = false
    @State private var isChatOrderPresented = false
    @State private var isOrderStatusInfoViewPresented = false
    @FocusState private var isFocused: Bool
    
    public init(order: DHSaleHeadAsOrderViewModel, isInList: Bool = false, isTrackable: Bool = false, isProductCouldBePresented: Bool = false, isFocused: Bool = false) {
        self.order = order
        self.isInList = isInList
        self.isTrackable = isTrackable
        self.isProductCouldBePresented = isProductCouldBePresented
        self.isFocused = isFocused
    }
    
    public var body: some View {
        ZStack {
            if isInList {
                OrderInfoView(order: order)
                    .padding(8)
                    .background(Style.surface)
                    .cornerRadius(8)
            } else {
                expandedDetailInfo
            }
        }
        .navigationDestination(isPresented: $isProductDetailViewPresented) {
            if let currentProduct {
                ItemDetailView(product: currentProduct).toolbarRole(.editor)
            }
        }
        .navigationDestination(isPresented: $isOrderStatusInfoViewPresented) {
            OrderStatusView(order: order).toolbarRole(.editor)
        }
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Заказ")
                    .foregroundStyle(Style.textPrimary)
                    .font(Style.title)
            }
        }
    }
    
    var expandedDetailInfo: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    OrderInfoView(order: order)
                        .padding(.bottom, 8)
                    
                    ForEach(order.listDRSale ?? [], id: \.idrfNomenclature) { item in
                        let product = vm.productDictionary[item.idrfNomenclature]
                        
                        let details = ItemCardView.Details(
                            name: product?.nomenclature.name ?? "",
                            price: item.amountEndPrice,
                            originalPrice: item.amountBasePrice,
                            imageURL: product?.nomenclature.listImages?.first?.urlData ?? "",
                            isAddToCartShowing: false,
                            countMonthPayment: item.numberInstallmentMonths,
                            amountPaymentInMonth: item.amountBasePrice
                        )
                        
                        let actions = ItemCardView.Actions(
                            onTapAction: {
                                currentProduct = product
                                isProductDetailViewPresented = true
                            },
                            addItemAction: {},
                            removeItemAction: {}
                        )
                        
                        ItemCardView(
                            details: details,
                            format: .inOrder,
                            currentItemsAdded: item.quantity,
                            actions: actions
                        )
                        .disabled(!isProductCouldBePresented)
                    }
                }
                .padding(8)
                .background(Style.surface)
                .cornerRadius(8)
                
                CompactChatView(isPresented: $isChatOrderPresented)
            }
            .overlay(alignment: .topTrailing) {
                orderButtons
                    .padding(8)
            }
            .padding()
            .onAppear { vm.fetchProductsInformation(for: order) }
        }
        .animation(.default, value: isChatOrderPresented)
        .onTapGesture { isFocused = false }
    }
    
    var orderButtons: some View {
        VStack(spacing: 4) {
            if isTrackable {
                Button(action: {
                    isOrderStatusInfoViewPresented = true
                }) {
                    VStack(spacing: 2) {
                        Image("orderTrackIcon", bundle: .module)
                            .foregroundStyle(Style.iconsTertiary)
                        Text("Отследить")
                            .foregroundStyle(Style.textTertiary)
                            .font(Style.captionBold)
                    }
                }
            }
            Button(action: {
                supportServiceVM.fetchOrCreateDialog(
                    for: .order,
                    with: "Заказ \(order.numberInt)",
                    reasonID: order.idUnique,
                    description: "Заказ \(order.numberInt)"
                )
                isChatOrderPresented = true
            }) {
                VStack(spacing: 2) {
                    Image("chatIcon", bundle: .module)
                        .foregroundStyle(Style.iconsTertiary)
                    Text("Чат по заказу")
                        .foregroundStyle(Style.textTertiary)
                        .font(Style.captionBold)
                }
            }
            .disabled(isChatOrderPresented)
            Spacer()
        }
    }
}
