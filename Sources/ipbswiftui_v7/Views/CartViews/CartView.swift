//
//  CartView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct CartView: View {
    @EnvironmentObject var vm: CartViewModel
    
    @State private var isCheckoutViewPresented = false
    @State private var isItemDetailPresented = false
    @State private var currentProduct: ProductViewDataModel?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        if let cartItemsList = vm.cartResult?.data?.listDRSale?.sorted(by: { $0.idrfNomenclature < $1.idrfNomenclature }), !cartItemsList.isEmpty {
                            ForEach(cartItemsList, id: \.idrfNomenclature) { item in
                                let product = vm.productDictionary[item.idrfNomenclature]
                                
                                let details = ItemCardView.Details(
                                    name: item.nameGoods ?? "",
                                    price: item.amountEndPrice,
                                    originalPrice: item.amountBasePrice,
                                    imageURL: product?.nomenclature.listImages?.first?.urlData ?? "",
                                    countMonthPayment: item.numberInstallmentMonths,
                                    amountPaymentInMonth: item.amountBasePrice
                                )
                                
                                let actions = ItemCardView.Actions(
                                    onTapAction: {
                                        currentProduct = product
                                        isItemDetailPresented = true
                                    },
                                    addItemAction: { vm.addCartItem(idrfNomenclature: item.idrfNomenclature , count: 1) },
                                    removeItemAction: { vm.deleteCartItem(idrfNomenclature: item.idrfNomenclature, count: 1) },
                                    deleteAction: { vm.deleteCartItem(idrfNomenclature: item.idrfNomenclature, count: item.quantity) }
                                )
                                
                                ItemCardView(
                                    details: details,
                                    format: .inCart,
                                    currentItemsAdded: item.quantity,
                                    actions: actions
                                )
                                .id(item.quantity)
                                .onAppear {
                                    if product == nil {
                                        vm.getProductByID(idRFNomenclature: item.idrfNomenclature)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            Spacer(minLength: 200)
                            Text("Корзина пуста")
                                .font(.title)
                        }
                    }
                    .padding(.vertical)
                }
                
                if let totalPrice = vm.cartResult?.data?.listDRSale?.reduce(0.0, { $0 + $1.amountEndPrice }), totalPrice != 0 {
                    VStack {
                        Spacer()
                        
                        VStack {
                            HStack {
                                Text("Итого к оплате:")
                                Spacer()
                                Text(totalPrice.asCurrency())
                            }
                            .foregroundStyle(Style.textPrimary)
                            .font(Style.title)
                            .bold()
                            .padding(.vertical, 10)
                            
                            CustomButtonView(title: "Оформить заказ") {
                                isCheckoutViewPresented = true
                            }
                        }
                        .padding(12)
                        .padding(.bottom)
                        .background(Style.surface)
                        .cornerRadius(20, corners: [.topLeft, .topRight])
                    }
                    .padding(8)
                    .padding(.bottom, -16)
                }
            }
            .animation(.default, value: vm.cartResult?.result.xRequestID)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Корзина")
                        .font(Style.title)
                        .foregroundStyle(Style.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .background(Style.background)
            .refreshable { vm.getCart() }
            .onAppear(perform: vm.getCart)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $isItemDetailPresented) {
                if let currentProduct {
                    ItemDetailView(product: currentProduct).toolbarRole(.editor)
                }
            }
            .navigationDestination(isPresented: $isCheckoutViewPresented) {
                CheckoutView().toolbarRole(.editor)
            }
        }
    }
}
