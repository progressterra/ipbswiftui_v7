//
//  CatalogProductListView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 13.08.2023.
//

import Foundation
import SwiftUI
import ipbswiftapi_v7

public struct CatalogProductListView: View {
    @EnvironmentObject var vm: CatalogViewModel
    @EnvironmentObject var cartVM: CartViewModel
    
    @State private var showDetails = false
    @State private var currentProduct: ProductViewDataModel?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    ForEach(vm.productListResults[vm.currentCatalogItem?.itemCategory.idUnique ?? ""] ?? [], id: \.nomenclature.idUnique) { product in
                        let details = ItemCardView.Details(
                            name: product.nomenclature.name ?? "",
                            price: product.inventoryData.currentPrice,
                            originalPrice: product.inventoryData.beginPrice,
                            imageURL: product.nomenclature.listImages?.first?.urlData ?? "",
                            isAddToCartShowing: true,
                            countMonthPayment: product.installmentPlanValue.countMonthPayment,
                            amountPaymentInMonth: product.installmentPlanValue.amountPaymentInMonth
                        )
                        
                        let actions = ItemCardView.Actions(
                            onTapAction: {
                                currentProduct = product
                                showDetails = true
                            },
                            addItemAction: { cartVM.addCartItem(idrfNomenclature: product.nomenclature.idUnique, count: 1) },
                            removeItemAction: { cartVM.deleteCartItem(idrfNomenclature: product.nomenclature.idUnique, count: 1) }
                        )
                        
                        ItemCardView(
                            details: details,
                            format: .normal,
                            currentItemsAdded: product.countInCart,
                            actions: actions
                        )
                    }
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .safeAreaPadding()
            .background(Style.background)
            .refreshable { vm.fetchProductList(for: vm.currentCatalogItem?.itemCategory.idUnique ?? "") }
            .onAppear { vm.fetchProductList(for: vm.currentCatalogItem?.itemCategory.idUnique ?? "") }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text((vm.currentCatalogItem?.itemCategory.name ?? "").capitalized)
                        .font(Style.title)
                        .foregroundColor(Style.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .navigationDestination(isPresented: $showDetails) {
                if let currentProduct {
                    ItemDetailView(product: currentProduct).toolbarRole(.editor)
                }
            }
        }
    }
}
