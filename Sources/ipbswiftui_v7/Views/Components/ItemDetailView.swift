//
//  ItemDetailView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct ItemDetailView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var vm: MainViewModel
    
    @State private var isAuthAlertPresented: Bool?
    
    let product: ProductViewDataModel
    
    public init(product: ProductViewDataModel) {
        self.product = product
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                let imageURLs = product.nomenclature.listImages?.compactMap { $0.urlData } ?? []
                
                ImagesView(imageURLs: imageURLs)
                
                ItemDescriptionView(
                    descriptionTitle: product.nomenclature.name ?? "",
                    description: product.nomenclature.commerseDescription ?? "",
                    favoriteAction: {},
                    shareItem: product.nomenclature.commerseDescription ?? "",
                    parameters: product.listProductCharacteristic?.compactMap { ($0.characteristicType.name ?? "", $0.characteristicValue.viewData ?? "") } ?? [],
                    deliveryOptions: [.express]
                )
                .padding(.horizontal)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.inventoryData.beginPrice.asCurrency())
                            .font(Style.title)
                            .foregroundStyle(Style.textTertiary)
                            .bold()
                            .strikethrough()
                        
                        Text("Цена для вас:")
                            .foregroundStyle(Style.textPrimary)
                            .font(Style.footnoteRegular)
                        
                        Text(product.inventoryData.currentPrice.asCurrency())
                            .font(Style.title)
                            .foregroundStyle(Style.textPrimary)
                            .bold()
                    }
                    .padding(.horizontal, 12)
                    
                    CustomButtonView(title: "Добавить в корзину") {
                        if AuthStorage.shared.getRefreshToken().isEmpty {
                            isAuthAlertPresented = true
                        } else {
                            cartVM.addCartItem(idrfNomenclature: product.nomenclature.idUnique, count: 1)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 25)
                
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(product.nomenclature.name ?? "")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
            }
        }
        .background(Style.background)
        .overlay {
            ZStack {
                if isAuthAlertPresented ?? false {
                    Rectangle()
                        .foregroundStyle(.ultraThinMaterial)
                        .transition(.opacity)
                    
                    AuthAlertView(
                        isPresented: $isAuthAlertPresented,
                        message: IPBSettings.authDescription
                    ) {
                        AuthorizationViewModel.shared.isLoggedIn = false
                        AuthorizationViewModel.shared.isNewUser = true
                    }
                    .padding()
                    .shadow(radius: 10)
                    .transition(.asymmetric(insertion: .scale, removal: .scale.combined(with: .opacity)))
                }
            }
        }
        .animation(.bouncy, value: isAuthAlertPresented)
    }
}
