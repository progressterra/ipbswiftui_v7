//
//  MainView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

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
            ScrollView {
                VStack(spacing: 40) {
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
                    .padding(.horizontal)
                    .animation(.default, value: withdrawalVM.documentList?.result.xRequestID)
                    .onAppear {
                        withdrawalVM.getClientBalance()
                        withdrawalVM.fetchDocumentList()
                    }
                    
                    Group {
                        if let productList = vm.productListResults[IPBSettings.topSalesCategoryID]  {
                            getProductList(with: "Хиты продаж", productList: productList)
                        } else {
                            CustomButtonView(title: "Обновить страницу", isOpaque: true) {
                                vm.setUpView()
                            }
                            .padding()
                        }
                        if let productList = vm.productListResults[IPBSettings.promoProductsCategoryID]  {
                            getProductList(with: "Акции", productList: productList)
                        }
                        if let productList = vm.productListResults[IPBSettings.newProductsCategoryID]  {
                            getProductList(with: "Новинки", productList: productList)
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
    private func getProductList(with headerTitle: String, productList: [ProductViewDataModel]) -> some View {
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
                .padding(.horizontal)
            }
        }
    }
}
