//
//  CheckoutView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 17.08.2023.
//

import SwiftUI

public struct CheckoutView: View {
    @EnvironmentObject var vm: CartViewModel
    
    public init() {}
    
    var currentStageIndex: Int {
        vm.checkoutStage.rawValue == 0 ? 2 : vm.checkoutStage.rawValue
    }
    
    public var body: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    OrderStageView(
                        currentStageIndex: currentStageIndex,
                        stages: ["Детали", "Доставка", "Оплата"]
                    )
                    .onTapGesture(coordinateSpace: CoordinateSpace.local) {
                        if $0.y < 100, vm.checkoutStage == .payment {
                            vm.checkoutStage = .delivery
                        }
                    }
                    
                    if vm.checkoutStage == .delivery {
                        DeliveryOptionFillView()
                            .padding(.horizontal)
                            .transition(.slide)
                    } else if vm.checkoutStage == .payment || vm.checkoutStage == .paymentProvider {
                        PaymentFillView()
                            .padding(.horizontal)
                            .transition(.slide)
                    } else if vm.checkoutStage == .final {
                        CheckoutFinalView()
                            .padding(.horizontal)
                            .transition(.slide)
                    }
                }
            }
            .onTapGesture(perform: hideKeyboard)
            
            if vm.checkoutStage == .delivery {
                VStack {
                    Spacer()
                    
                    CustomButtonView(
                        title: "Далее",
                        isDisabled: $vm.isDeliveryButtonDisabled
                    ) {
                        vm.checkoutStage = .payment
                        vm.addAddress()
                        vm.addComment()
                    }
                    .padding(8)
                    .padding(.bottom)
                    .background(Style.surface)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
                .padding(.horizontal, 8)
                .transition(.slide)
            } else {
                Color.clear.transition(.slide)
            }
        }
        .animation(.default, value: vm.checkoutStage)
        .animation(.default, value: vm.cartResult?.result.xRequestID)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Оформление заказа")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .background(Style.background)
        .refreshable { vm.getCart() }
    }
}
