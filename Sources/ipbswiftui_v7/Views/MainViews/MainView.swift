//
//  MainView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// The primary interface for the application showcasing various product categories and interactive elements like bonuses and promotional items.
///
/// `MainView` orchestrates several key functionalities within the app's main dashboard. It dynamically displays products sorted by categories such as "Хиты продаж" (Bestsellers), "Акции" (Promotions), and "Новинки" (New Arrivals) fetched via the `MainViewModel`. The view also integrates components for managing and viewing bonuses and withdrawal options, facilitating user interaction with financial features.
///
/// ## Functionality Includes:
/// - Displaying cards for different product categories.
/// - Navigation to detailed product views, authorization flows, withdrawal setups, and card addition via modals and sheets.
/// - Utilizing `BonusesCardView` for displaying and interacting with user's bonuses and financial transactions.
///
public struct MainView: View {
    
    @EnvironmentObject var vm: MainViewModel
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var withdrawalVM: WithdrawalViewModel
    
    @State private var showDetails = false
    @State private var isWithdrawalViewPresented = false
    @State private var isAuthViewPresented = false
    @State private var isAddCardViewPresented = false
    @State private var refreshFlag = false
    @State private var currentProduct: ProductViewDataModel?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            BonusesCardView(
                currentBonusesCount: 0,
                equivalentOfOneBonus: 1,
                availableWithdrawalAmount: withdrawalVM.clientBalanceAmount ?? 0,
                availableInstalmentAmount: 0,
                isButtonsShowing: true,
                authDescription: IPBSettings.authDescription,
                isAuthorized: !AuthStorage.shared.getRefreshToken().isEmpty,
                isCardAdded: withdrawalVM.documentList?.dataList != nil,
                addCardAction: { isAddCardViewPresented = true },
                authAction: {
                    AuthorizationViewModel.shared.isLoggedIn = false
                    AuthorizationViewModel.shared.isNewUser = true
                },
                bonusesHistoryAction: {},
                subtractAction: { isWithdrawalViewPresented = true }
            )
            //.padding(.horizontal)
            .animation(.default, value: withdrawalVM.documentList?.result.xRequestID)
            .onAppear {
                withdrawalVM.getClientBalance()
                withdrawalVM.fetchDocumentList()
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: UIScreen.main.bounds.size.height * 0.1)
            
            ScrollView {
                VStack(spacing: 40) {
                    
                    
                    Group {
                            
                        if let productList = vm.productListResults["08dc9554-12ed-4169-8b96-dcb7ef118949"]  {
                            getProductList(with: "", productList: productList, isBanner: true)
                        }
                        
                        
                        if let productList = vm.productListResults[IPBSettings.topSalesCategoryID]  {
                            getProductList(with: "Хиты продаж", productList: productList, isBanner: false)
                        } else {
                            CustomButtonView(title: "Обновить страницу", isOpaque: true) {
                                vm.setUpView()
                            }
                            .padding()
                        }
                        if let productList = vm.productListResults[IPBSettings.promoProductsCategoryID]  {
                            getProductList(with: "Акции", productList: productList, isBanner: false)
                        }
                        if let productList = vm.productListResults[IPBSettings.newProductsCategoryID]  {
                            getProductList(with: "Новинки", productList: productList, isBanner: false)
                        }
                    }
                    .id(refreshFlag)
                    .transition(.slide)
                }
            }
            .refreshable {
                vm.setUpView()
                refreshFlag.toggle()
            }
            .onAppear(perform: vm.setUpView)
            .background(Style.background)
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: vm.xRequestID)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .navigationDestination(isPresented: $showDetails) {
                if let currentProduct {
                    ItemDetailView(product: currentProduct).toolbarRole(.editor)
                }
            }
            .navigationDestination(isPresented: $isWithdrawalViewPresented) {
                WithdrawalView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isAuthViewPresented) {
                AuthorizationView().toolbarRole(.editor)
            }
            .navigationDestination(isPresented: $isAddCardViewPresented) {
                BankCardView(isNewCard: true, isPresented: $isAddCardViewPresented).toolbarRole(.editor)
            }
        }
    }
}

extension MainView {
    private func getProductList(with headerTitle: String, productList: [ProductViewDataModel], isBanner: Bool) -> some View {
        VStack(spacing: 24) {
            Text(headerTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
                .foregroundStyle(Style.textPrimary)
                .font(Style.title)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(productList, id: \.nomenclature.idUnique) { product in
                        let details = ItemCardView.Details(
                            name: product.nomenclature.name ?? "",
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
                        
                        if isBanner && details.imageBannerURL != nil
                        {
                            ItemCardView(
                                details: details,
                                format: .banner,
                                currentItemsAdded: product.countInCart,
                                actions: actions
                            )
                        }
                        else
                        {
                            ItemCardView(
                                details: details,
                                format: product.nomenclature.idrfSpecification == Style.idrfSpecificatiuonForMedicialProduct ? .medicinalProduct: .normal,
                                currentItemsAdded: product.countInCart,
                                actions: actions
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


