//
//  WithdrawalView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

public struct WithdrawalView: View {
    @EnvironmentObject var vm: WithdrawalViewModel
    
    @State private var isNewWithdrawalViewPresented: Bool = false
    @State private var isAddCardViewPresented: Bool = false
    
    private var isHaveSubmittedCards: Bool {
        !(vm.paymentDataList?.dataList?.isEmpty ?? true)
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if isHaveSubmittedCards {
                withdrawalView
            } else {
               addNewCardPromptView
            }
        }
        .refreshable { vm.fetchPaymentList() }
        .onAppear(perform: vm.fetchPaymentList)
        .onAppear(perform: vm.fetchPaymentDataList)
        .onAppear(perform: vm.getClientBalance)
        .animation(.default, value: vm.paymentList?.result.xRequestID)
        .padding(.horizontal)
        .safeAreaPadding(value: 35)
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Вывод средств")
                    .font(Style.title)
                    .foregroundColor(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .navigationDestination(isPresented: $isNewWithdrawalViewPresented) {
            NewWithdrawalView(isPresented: $isNewWithdrawalViewPresented)
                .toolbarRole(.editor)
        }
        .navigationDestination(isPresented: $isAddCardViewPresented) {
            BankCardView(isNewCard: true, isPresented: $isAddCardViewPresented)
                .toolbarRole(.editor)
        }
    }
    
    private var withdrawalView: some View {
        VStack(spacing: 40) {
            VStack(spacing: 12) {
                if let balance = vm.clientBalanceAmount {
                    CustomTextFieldView(
                        text: .constant(balance.asCurrency()),
                        prompt: "Доступно для вывода"
                    )
                    .bold()
                    .disabled(true)
                    .padding(.top)
                }
                
                CustomButtonView(title: "Создать новый вывод") {
                    isNewWithdrawalViewPresented = true
                }
            }
            
            if let paymentsHistory = vm.paymentList?.dataList {
                VStack(spacing: 20) {
                    Text("История выводов")
                        .font(Style.title)
                        .foregroundColor(Style.textPrimary)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(paymentsHistory, id: \.idUnique) { payment in
                                WithdrawalHistoryCardView(
                                    amount: payment.amount,
                                    cardNumber: payment.previewPaymentMethod ?? "",
                                    dateString: payment.dateAdded,
                                    status: payment.status
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal, -16)
            } else {
                Text("Выводов пока нет")
                    .font(Style.title)
                    .foregroundColor(Style.textPrimary)
            }
        }
    }
    
    private var addNewCardPromptView: some View {
        VStack {
            Spacer()
            
            Text("Чтобы получать оплату и делать выгодные покупки необходимо добавить карту")
                .foregroundColor(Style.textPrimary)
                .font(Style.title)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            CustomButtonView(title: "Добавить карту") {
                isAddCardViewPresented = true
            }
            .padding(8)
            .padding(.bottom, 35)
            .background(Style.surface)
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(color: Style.textSecondary.opacity(0.1), radius: 5, y: -5)
        }
        .padding(.horizontal, -8)
    }
}



struct WithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalView()
            .environmentObject(WithdrawalViewModel())
    }
}
