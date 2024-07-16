//
//  CatalogProductListView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 13.08.2023.
//

import Foundation
import SwiftUI
import ipbswiftapi_v7

/// A view that presents a list of products from a specific catalog category.
///
/// This SwiftUI view is designed to display products in a grid layout, where each product can be tapped to view more details or added to a shopping cart directly. It integrates with `CatalogViewModel` to fetch and display product details and uses `CartViewModel` to manage cart operations.
///
/// ## Usage
///
/// `CatalogProductListView` should be instantiated with a `CatalogItem`, which represents the category from which products are to be listed.
///
/// ```swift
/// CatalogProductListView(catalogItem: someCatalogItem)
///     .environmentObject(CatalogViewModel())
///     .environmentObject(CartViewModel.shared)
/// ```
public struct CatalogProductListView: View {
    @EnvironmentObject var vm: CatalogViewModel
    @EnvironmentObject var cartVM: CartViewModel
    
    let catalogItem: CatalogItem
    
    @State private var showDetails = false
    @State private var currentProduct: ProductViewDataModel?
    
    public init(catalogItem: CatalogItem) {
        self.catalogItem = catalogItem
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            //ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()], spacing: 20) {
                    ForEach(vm.productListResults[catalogItem.itemCategory.idUnique] ?? [], id: \.nomenclature.idUnique) { product in
                        let details = ItemCardView.Details(
                            name: product.nomenclature.name ?? "",
                            brandName: product.listProductCharacteristic?
                                .first(where: { $0.characteristicType.name == Style.nameFieldManufactor })?
                                .characteristicValue.viewData ?? "",
                            price: product.inventoryData.currentPrice,
                            originalPrice: product.inventoryData.beginPrice,
                            imageURL: product.nomenclature.listImages?.first?.urlData ?? "",
                            isAddToCartShowing: !AuthStorage.shared.getRefreshToken().isEmpty,
                            countMonthPayment: product.installmentPlanValue.countMonthPayment,
                            amountPaymentInMonth: product.installmentPlanValue.amountPaymentInMonth,
                            imageBannerURL: product.nomenclature.listImages?.first { $0.alias == "banner" }?.urlData
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
                            format: product.nomenclature.idrfSpecification == Style.idrfSpecificatiuonForMedicialProduct ? .medicinalProduct: .normal,
                            currentItemsAdded: product.countInCart,
                            actions: actions
                        )
                    }
                }
                .padding(.top)
                .padding(.horizontal)
            }
            .background(Style.background)
            .animation(.default, value: vm.xRequestID)
            .refreshable { vm.fetchProductList(for: catalogItem.itemCategory.idUnique) }
            .onAppear { vm.fetchProductList(for: catalogItem.itemCategory.idUnique) }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text((catalogItem.itemCategory.name ?? "").capitalized)
                        .font(Style.title)
                        .foregroundStyle(Style.textPrimary)
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
        //}
    }
}
