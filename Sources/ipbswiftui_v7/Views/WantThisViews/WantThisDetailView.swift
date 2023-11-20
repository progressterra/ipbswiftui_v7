//
//  WantThisDetailView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 25.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct WantThisDetailView: View {
    @EnvironmentObject var vm: WantThisViewModel
    @EnvironmentObject var supportServiceVM: MessengerViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: Field?
    @State private var isChatPresented: Bool = false
    
    var canEdit: Bool {
        document.statusDoc == .waitReview || document.statusDoc == .waitImage
    }
    
    enum Field {
        case itemURL
        case itemName
    }
    
    let document: RFCharacteristicValueViewModel
    let fields: [FieldData]
    
    public init(document: RFCharacteristicValueViewModel, fields: [FieldData]) {
        self.document = document
        self.fields = fields
    }
    
    public var body: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Запрос от " + document.dateAdded.convertDateFormat(to: "d MMMM"))
                                .font(Style.title)
                                .foregroundColor(Style.textPrimary)
                            displayDocStatus(document.statusDoc ?? .notFill)
                                .font(Style.subheadlineBold)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            supportServiceVM.fetchOrCreateDialog(
                                for: .iwantit,
                                with: "Запрос от " + document.dateAdded.convertDateFormat(to: "d MMMM"),
                                reasonID: document.idUnique
                            )
                            isChatPresented = true
                        }) {
                            VStack(spacing: 2) {
                                Image("chatIcon", bundle: .module)
                                    .foregroundColor(Style.iconsTertiary)
                                Text("Чат по запросу")
                                    .foregroundColor(Style.textTertiary)
                                    .font(Style.footnoteRegular)
                            }
                        }
                    }
                    
                    if let fieldsData = vm.fieldsData {
                        CustomTextFieldView(text: $vm.itemName, prompt: fieldsData.first?.comment ?? "")
                            .focused($focusedField, equals: .itemName)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .itemURL }
                            .autocorrectionDisabled()
                        
                        CustomTextFieldView(text: $vm.itemURL, prompt: fieldsData.last?.comment ?? "")
                            .focused($focusedField, equals: .itemURL)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                    }
                    
                    HStack(spacing: 12) {
                        Text("Добавить фото")
                            .foregroundColor(Style.textPrimary)
                            .font(Style.body)
                        CameraButtonView(inputImage: $vm.itemImage)
                        Spacer()
                    }
                    
                    HStack {
                        if let itemImage = vm.itemImage {
                            Image(uiImage: itemImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 157, height: 157)
                                .cornerRadius(8)
                                .overlay(alignment: .topTrailing) {
                                    Button(action: { vm.itemImage = nil }) {
                                        Image("xmark", bundle: .module)
                                            .foregroundColor(Style.error)
                                            .font(.title)
                                    }
                                    .padding(8)
                                }
                        } else if let itemImageURL = vm.itemImageURL {
                            AsyncImageView(
                                imageURL: itemImageURL,
                                width: 157,
                                height: 157,
                                cornerRadius: 8
                            )
                            .overlay(alignment: .topTrailing) {
                                Button(action: {
                                    vm.itemImage = nil
                                    vm.itemImageURL = nil
                                }) {
                                    Image("xmark", bundle: .module)
                                        .foregroundColor(Style.error)
                                        .font(.title)
                                }
                                .padding(8)
                            }
                        }
                        
                        Spacer().frame(height: 157)
                    }
                    .animation(.default, value: vm.itemImage)
                    
                    CompactChatView(isPresented: $isChatPresented)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .safeAreaPadding()
            .disabled(!canEdit)
            
            VStack {
                Spacer()
                
                if canEdit, focusedField == nil {
                    CustomButtonView(title: "Готово", isDisabled: $vm.isSubmitButtonDisabled) {
                        vm.editDocument()
                    }
                    .padding(8)
                    .background(
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Style.surface)
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                            .edgesIgnoringSafeArea(.bottom)
                    )
                    .padding(.horizontal, 8)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                }
            }
            
            StatusAlertView(status: $vm.status) { dismiss() }
        }
        .onTapGesture { focusedField = nil }
        .onDisappear(perform: vm.eraseDocumentData)
        .safeAreaPadding()
        .navigationBarTitleDisplayMode(.inline)
        .animation(.default, value: isChatPresented)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Запрос Хочу это")
                    .foregroundColor(Style.textPrimary)
                    .font(Style.title)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
    }
    
    private func displayDocStatus(_ statusDoc: TypeStatusDoc) -> some View {
        switch statusDoc {
        case .confirmed:
            return Text("Запрос подтвержден")
                .foregroundColor(Style.onBackground)
        case .waitReview, .waitImage:
            return Text("Ожидает подтверждения")
                .foregroundColor(Style.textTertiary)
        case .rejected:
            return Text("Запрос отклонен")
                .foregroundColor(Style.textPrimary2)
        case .notFill:
            return Text("Документ не заполнен")
                .foregroundColor(Style.textPrimary2)
        }
    }
}
