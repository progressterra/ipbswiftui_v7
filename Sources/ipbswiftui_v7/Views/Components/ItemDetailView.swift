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
                if let imageURLs = product.nomenclature.listImages?.compactMap({ $0.urlData }) {
                    ImagesView(imageURLs: imageURLs)
                }
                
                if product.nomenclature.idrfSpecification == Style.idrfSpecificatiuonForMedicialProduct
                {
                    
                        
                        HStack{
                            
                                Text("Кэшбэк \(product.inventoryData.beginPrice.clean) баллов")
                                    .font(Style.captionBold)
                                    .foregroundStyle(Style.surface)
                                    .padding(7)
                                    .lineLimit(1) // Ограничиваем текст одной строкой
                                    .truncationMode(.tail) // Добавляем троеточие, если текст не помещается
                                    .frame(alignment: .leading)
                            
                                
                        }.frame(maxWidth: .infinity, alignment: .leading)
                                .background(LinearGradient(gradient: Gradient(colors: [Color(hex: 0xFF53B8EB),
                                                                                       Color(hex: 0xFF27D1AE)]), startPoint: .leading, endPoint: .trailing))
                        
                    
                        
                    
                }
                
                let manufactor = product.listProductCharacteristic?
                    .first(where: { $0.characteristicType.name == Style.nameFieldManufactor })?
                    .characteristicValue.viewData ?? ""
                
                ItemDescriptionView(
                    descriptionTitle: product.nomenclature.name ?? "",
                    description: product.nomenclature.commerseDescription ?? "",
                    favoriteAction: {},
                    shareItem: product.nomenclature.commerseDescription ?? "",
                    parameters: product.listProductCharacteristic?.compactMap { ($0.characteristicType.name ?? "", $0.characteristicValue.viewData ?? "") } ?? [],
                    deliveryOptions: [.express],
                    idrfSpecification: product.nomenclature.idrfSpecification,
                    brandName: manufactor
                )
                .padding(.horizontal)
                
                
                if product.nomenclature.idrfSpecification != Style.idrfSpecificatiuonForMedicialProduct
                {
                    
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
                    .padding()
                }
                
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

//struct ItemDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack{
//            let demoProduct = ProductViewDataModel(
//                        nomenclature: RFNomenclatureViewModel(
//                            idrfSpecification: "spec123",
//                            name: "Demo Product",
//                            commerseDescription: "This is a demo product description.",
//                            idUnique: "unique123",
//                            idEnterprise: "enterprise123",
//                            dateAdded: Date(),
//                            dateUpdated: "2023-01-01",
//                            dateSoftRemoved: "2023-01-01",
//                            listCatalogCategory: ["category1", "category2"],
//                            listImages: [
//                                
//                            ],
//                            popularOrder: 1,
//                            rating: 4.5
//                        ),
//                        inventoryData: RGGoodsInventoryViewModel(
//                            idrfNomenclatura: "nomenclatura123",
//                            idrfComPlace: "comPlace123",
//                            quantity: 100,
//                            idDiscountBasisForBeginPrice: "",
//                            beginPrice: 1000.0,
//                            currentPrice: 800.0,
//                            minPrice: 750.0,
//                            maxValueDiscount: 50.0,
//                            defectName: "",
//                            idExternalSystem: "",
//                            idUnique: "inventoryUnique123",
//                            idEnterprise: "enterprise123",
//                            dateAdded: "2023-01-01",
//                            dateUpdated: "2023-01-01",
//                            dateSoftRemoved: "2023-01-01"
//                        ),
//                        listProductCharacteristic: [
//                        ],
//                        installmentPlanValue: InstallmentPlan(
//                            countMonthPayment: 12,
//                            amountPaymentInMonth: 66.67
//                        ),
//                        countInCart: 2
//                    )
//                    
//            ItemDetailView(product: demoProduct)
//             
//            Text("Lfnfdf ")
//        }
//    }
//}
//
