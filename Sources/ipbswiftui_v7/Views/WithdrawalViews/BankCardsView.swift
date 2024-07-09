//
//  BankCardsView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 14.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct BankCardsView: View {
    @EnvironmentObject var vm: WithdrawalViewModel
    
    public enum DisplayOption: DisplayOptionProtocol {
        case confirmedCards
        case allElse
        
        public var rawValue: String {
            switch self {
            case .confirmedCards: return "Подтверждённые"
            case .allElse: return "Остальные"
            }
        }
    }
    
    @Namespace private var animation
    @State private var displayOption: DisplayOption = .confirmedCards
    @State private var isCardViewPresented: Bool = false
    @State private var isNewCard: Bool = false
    @State private var cardStatus: TypeStatusDoc?
    
    private let textFieldBackground = Style.background
    private let displayOptions: [DisplayOption] = [.confirmedCards, .allElse]
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            OptionPickerView(value: $displayOption, options: displayOptions)
                .padding(.horizontal)
                .padding(.top)
                .shadow(color: Style.textSecondary.opacity(0.1), radius: 5, y: 5)
                .zIndex(10)
            
            ScrollView {
                if displayOption == .confirmedCards {
                    VStack(spacing: 8) {
                        if let cardList = vm.paymentDataList?.dataList, !cardList.isEmpty {
                            ForEach(cardList, id: \.idUnique) { card in
                                ConfirmedCardRowView(
                                    cardNumber: "\(card.paymentSystemName ?? "") \(card.preiview ?? "")",
                                    isMain: vm.idPaymentData == card.idUnique
                                )
                                .overlay(alignment: .trailing) {
                                    HStack {
                                        Spacer()
                                        Button(action: {}) { // delete action
                                            Image("trashCan", bundle: .module)
                                                .foregroundStyle(Style.iconsTertiary)
                                        }
                                        .padding(.trailing)
                                    }
                                }
                                .onAppear { vm.idPaymentData = cardList.first?.idUnique ?? "" }
                            }
                        } else {
                            Text("Подтверждённых карт пока нет")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Style.surface)
                                .cornerRadius(8)
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        )
                        .combined(with: .opacity)
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    .onAppear(perform: vm.fetchPaymentDataList)
                    .animation(.default, value: vm.paymentDataList?.result.xRequestID)
                } else {
                    VStack(spacing: 8) {
                        if let cardList = vm.documentList?.dataList?
                            .filter({ $0.statusDoc != .confirmed }) {
                            
                            ForEach(cardList, id: \.idUnique) { card in
                                if let cardData = vm.documentsData?[card.idUnique] {
                                    Button(action: { presentCardView(for: card) }) {
                                        BankCardRowView(
                                            cardNumber: cardData.first?.valueData ?? "",
                                            cardStatus: card.statusDoc,
                                            removeAction: {}
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading),
                            removal: .move(edge: .trailing)
                        )
                        .combined(with: .opacity)
                    )
                    .padding(.horizontal)
                    .padding(.top)
                    .onAppear(perform: vm.fetchDocumentList)
                    .animation(.default, value: vm.documentList?.result.xRequestID)
                }
            }
            .refreshable {
                displayOption == .confirmedCards
                ? vm.fetchPaymentDataList()
                : vm.fetchDocumentList()
            }
            .zIndex(1)
            .animation(.easeInOut, value: displayOption)
        }
        .safeAreaInset(edge: .bottom) {
            CustomButtonView(title: "Добавить карту", action: presentAddCardView)
                .padding(8)
                .background(Style.surface)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(color: Style.textSecondary.opacity(0.1), radius: 5, y: -5)
                .padding(.horizontal, 8)
        }
        .background(Style.background)
        .onAppear {
            vm.fetchFieldsData()
            vm.fetchDocumentList()
            vm.fetchPaymentDataList()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Банковские карты")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .navigationDestination(isPresented: $isCardViewPresented) {
            BankCardView(
                isNewCard: isNewCard,
                cardStatus: cardStatus,
                isPresented: $isCardViewPresented
            )
            .onDisappear(perform: vm.eraseFields)
            .toolbarRole(.editor)
        }
    }
    
    private func presentAddCardView() {
        isNewCard = true
        isCardViewPresented = true
        cardStatus = .notFill
        vm.eraseFields()
    }
    
    private func presentCardView(for card: RFCharacteristicValueViewModel) {
        guard let cardData = vm.documentsData?[card.idUnique] else { return }
        isNewCard = false
        cardStatus = card.statusDoc
        
        vm.currentDocumentID = card.idUnique
        vm.cardNumber = cardData[0].valueData ?? ""
        vm.cardHolderName = cardData[1].valueData ?? ""
        vm.expirationMonth = cardData[2].valueData ?? ""
        vm.expirationYear = cardData[3].valueData ?? ""
        vm.realCVCCode = cardData[4].valueData ?? ""
        vm.maskedCVCCode = cardData[4].valueData ?? ""
        vm.cardPhotoURL = card.listImages?.first?.urlData
        
        isCardViewPresented = true
    }
}

struct BankCardsView_Previews: PreviewProvider {
    static var previews: some View {
        BankCardsView()
            .environmentObject(WithdrawalViewModel())
    }
}
