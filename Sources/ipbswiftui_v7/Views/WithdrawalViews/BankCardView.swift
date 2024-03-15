//
//  CardView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 14.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct BankCardView: View {
    
    @EnvironmentObject var vm: WithdrawalViewModel
    
    let isNewCard: Bool
    var cardStatus: TypeStatusDoc?
    @Binding var isPresented: Bool
    
    @State private var displayedExpiryDate: String = ""
    @FocusState private var focusedField: Int?
    
    private var statusTitle: String {
        switch cardStatus {
        case .confirmed: return "Подтверждена"
        case .rejected: return "Отклонена"
        case .waitImage: return "Ожидает изображения"
        case .waitReview: return "Ожидает проверки"
        default: return "Не заполнена"
        }
    }
    
    private var statusColor: Color {
        switch cardStatus {
        case .confirmed: return Style.onBackground
        case .rejected: return Style.textPrimary2
        default: return Style.textTertiary
        }
    }
    
    private let textFieldBackground = Style.background
    
    public init(isNewCard: Bool, cardStatus: TypeStatusDoc? = nil, isPresented: Binding<Bool>) {
        self.isNewCard = isNewCard
        self.cardStatus = cardStatus
        self._isPresented = isPresented
    }
    
    public var body: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ScrollView {
                
                HStack {
                    Text(statusTitle)
                        .foregroundStyle(statusColor)
                        .font(Style.subheadlineBold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, -16)
                
                VStack(spacing: 12) {
                    CustomTextFieldView(
                        text: $vm.cardNumber,
                        prompt: vm.fieldsData?[0].name ?? "",
                        backgroundColor: textFieldBackground
                    )
                    .modifier(CardNumberFormatter(text: $vm.cardNumber))
                    .focused($focusedField, equals: 0)
                    .onSubmit { focusedField = 1 }
                    .submitLabel(.next)
                    
                    CustomTextFieldView(
                        text: $vm.cardHolderName,
                        prompt: vm.fieldsData?[1].name ?? "",
                        backgroundColor: textFieldBackground
                    )
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.alphabet)
                    .focused($focusedField, equals: 1)
                    .onSubmit { focusedField = 2 }
                    .submitLabel(.next)
                    
                    HStack(spacing: 12) {
                        CustomTextFieldView(
                            text: $displayedExpiryDate,
                            prompt: "Срок действия",
                            backgroundColor: textFieldBackground
                        )
                        .modifier(
                            ExpiryDateModifier(
                                month: $vm.expirationMonth,
                                year: $vm.expirationYear,
                                displayedText: $displayedExpiryDate
                            )
                        )
                        .focused($focusedField, equals: 2)
                        .onSubmit { focusedField = 3 }
                        .submitLabel(.next)
                        
                        CustomTextFieldView(
                            text: $vm.maskedCVCCode,
                            prompt: vm.fieldsData?[4].name ?? "",
                            backgroundColor: textFieldBackground
                        )
                        .modifier(
                            CVCMaskModifier(
                                realText: $vm.realCVCCode,
                                displayedText: $vm.maskedCVCCode
                            )
                        )
                        .focused($focusedField, equals: 3)
                        .onSubmit { focusedField = nil }
                        .submitLabel(.done)
                    }
                }
                .padding(12)
                .background(Style.surface)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top)
                .disabled(cardStatus == .confirmed || cardStatus == .rejected)
                .autocorrectionDisabled()
                .animation(.default, value: focusedField)
                
                if isNewCard && cardStatus != .confirmed || cardStatus != .rejected {
                    HStack(spacing: 12) {
                        Text("Фото банковской карты")
                            .font(Style.body)
                            .foregroundStyle(Style.textPrimary)
                        
                        CameraButtonView(inputImage: $vm.cardPhoto)
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    .padding(.top)
                }
                
                HStack {
                    if let cardPhoto = vm.cardPhoto {
                        Image(uiImage: cardPhoto)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 63, height: 63)
                            .cornerRadius(8)
                            .clipped()
                    } else if let cardPhotoURL = vm.cardPhotoURL {
                        AsyncImageView(
                            imageURL: cardPhotoURL,
                            width: 63,
                            height: 63,
                            cornerRadius: 8
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .refreshable { vm.fetchFieldsData() }
            .onTapGesture { focusedField = nil }
            
            VStack {
                Spacer()
                
                CustomButtonView(title: "Готово", isDisabled: $vm.isSubmitButtonDisabled) {
                    if isNewCard {
                        vm.fillDocument()
                    } else {
                        vm.editDocument()
                    }
                }
                .padding(8)
                .padding(.bottom, 35)
                .background(Style.surface)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            .padding(.horizontal, 8)
            
            
            StatusAlertView(status: $vm.status) {
                vm.eraseFields()
                vm.fetchDocumentList()
                isPresented = false
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(isNewCard ? "Добавление карты" : "Просмотр карты")
                    .font(Style.title)
                    .foregroundStyle(Style.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
            
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            
            ToolbarItem(placement: .keyboard) {
                Button(action: {
                    if let currentFocus = focusedField, currentFocus > 0 {
                        focusedField = currentFocus - 1
                    }
                }) {
                    Image(systemName: "chevron.up")
                }
                .disabled(focusedField == 0)
            }
            
            ToolbarItem(placement: .keyboard) {
                Button(action: {
                    if let currentFocus = focusedField, currentFocus < 3 {
                        focusedField = currentFocus + 1
                    } else if focusedField == 3 {
                        focusedField = nil
                    }
                }) {
                    Image(systemName: focusedField == 3 ? "keyboard.chevron.compact.down.fill" : "chevron.down")
                }
            }
        }
        .onAppear(perform: vm.fetchFieldsData)
    }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        BankCardView(isNewCard: true, isPresented: .constant(false))
            .environmentObject(WithdrawalViewModel())
    }
}
