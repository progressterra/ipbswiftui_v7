//
//  NewWithdrawalView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

public struct NewWithdrawalView: View {
    @EnvironmentObject var vm: WithdrawalViewModel
    
    @Binding var isPresented: Bool
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    if let balance = vm.clientBalanceAmount {
                        CustomTextFieldView(
                            text: .constant(balance.asCurrency()),
                            prompt: "Доступно для вывода"
                        )
                        .bold()
                        .disabled(true)
                        .padding(.top)
                    }
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            if let cardList = vm.paymentDataList?.dataList {
                                ForEach(cardList, id: \.idUnique) { card in
                                    ConfirmedCardRowView(
                                        cardNumber: "\(card.paymentSystemName ?? "") \(card.preiview ?? "")",
                                        isMain: vm.idPaymentData == card.idUnique
                                    )
                                    .overlay {
                                        if vm.idPaymentData ?? "" == card.idUnique {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke()
                                                .cornerRadius(8)
                                                .foregroundStyle( Style.primary)
                                                .transition(.opacity)
                                        }
                                    }
                                    .onTapGesture { vm.idPaymentData = card.idUnique }
                                    .animation(.default, value: vm.idPaymentData)
                                }
                                .onAppear { vm.idPaymentData = cardList.first?.idUnique ?? "" }
                            }
                        }
                    }.frame(height: 170)
                    
                    CustomTextFieldView(
                        text: $vm.withdrawalAmount,
                        prompt: "Введите сумму"
                    )
                    .bold()
                    .keyboardType(.decimalPad)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                vm.withdrawalAmount = vm.clientBalanceAmount?.description ?? ""
                            }
                        }) {
                            Text("Вывести всё")
                                .font(Style.subheadlineBold)
                                .foregroundStyle(Style.textTertiary)
                        }
                    }
                    .padding(.top, -8)
                }
            }
            .refreshable {
                vm.fetchPaymentDataList()
                vm.getClientBalance()
            }
            .onTapGesture(perform: hideKeyboard)
            
            VStack {
                Spacer()
                
                CustomButtonView(
                    title: "Вывести",
                    isDisabled: $vm.isWithdrawalButtonDisabled,
                    action: vm.createPayment
                )
                .padding(8)
                .padding(.bottom, 35)
                .background(Style.surface)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .padding(.horizontal, -8)
            
            StatusAlertView(status: $vm.status) {
                vm.withdrawalAmount = ""
                isPresented = false
            }
        }
        .padding(.horizontal)
        .background(Style.background)
        .onAppear {
            vm.fetchPaymentDataList()
            vm.getClientBalance()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Вывод средств")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
    }
}



struct NewWithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        NewWithdrawalView(isPresented: .constant(true))
            .environmentObject(WithdrawalViewModel())
    }
}
