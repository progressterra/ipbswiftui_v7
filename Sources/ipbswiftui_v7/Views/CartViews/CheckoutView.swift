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
    
    public var body: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    OrderStageView(
                        currentStageIndex: $vm.currentCheckoutStageIndex,
                        stages: ["Детали", "Доставка", "Оплата"]
                    )
                    .onTapGesture(coordinateSpace: CoordinateSpace.local) {
                        if $0.y < 100, vm.currentCheckoutStageIndex == 2 {
                            vm.currentCheckoutStageIndex -= 1
                        }
                    }
                    
                    if vm.currentCheckoutStageIndex == 1 {
                        DeliveryOptionFillView()
                            .padding(.horizontal)
                            .transition(.slide)
                    } else if vm.currentCheckoutStageIndex == 2 {
                        PaymentFillView()
                            .padding(.horizontal)
                            .transition(.slide)
                    } else if vm.currentCheckoutStageIndex == 3 {
                        CheckoutFinalView()
                            .padding(.horizontal)
                            .transition(.slide)
                    }
                }
            }
            .onTapGesture(perform: hideKeyboard)
            
            if vm.currentCheckoutStageIndex == 1 {
                VStack {
                    Spacer()
                    
                    CustomButtonView(
                        title: "Далее",
                        isDisabled: $vm.isDeliveryButtonDisabled
                    ) {
                        vm.currentCheckoutStageIndex += 1
                        vm.addAddress()
                        vm.addComment()
                    }
                    .padding(8)
                    .padding(.bottom, 45)
                    .background(Style.surface)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
                .padding(.horizontal, 8)
                .transition(.slide)
                .safeAreaPadding()
                .edgesIgnoringSafeArea(.bottom)
            } else {
                Color.clear.transition(.slide)
            }
        }
        .animation(.default, value: vm.currentCheckoutStageIndex)
        .animation(.default, value: vm.cartResult?.result.xRequestID)
        .safeAreaPadding(value: 50)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Оформление заказа")
                    .font(Style.title)
                    .foregroundColor(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .background(Style.background)
        .refreshable { vm.getCart() }
    }
}
