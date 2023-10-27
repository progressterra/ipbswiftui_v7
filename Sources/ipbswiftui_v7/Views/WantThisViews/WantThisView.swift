//
//  WantThisView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 26.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct WantThisView: View {
    @EnvironmentObject var vm: WantThisViewModel
    
    @State private var showingImagePicker = false
    @State private var isPresented: Bool = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case itemURL
        case itemName
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        NavigationButtonView(title: "Предыдущие запросы") {
                            isPresented = true
                        }
                        
                        HStack {
                            Text("Прикрепите фото и ссылку на товар, который вы хотите")
                                .foregroundColor(Style.textPrimary)
                                .font(Style.body)
                            Spacer(minLength: 12)
                            CameraButtonView(inputImage: $vm.itemImage)
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
                                            Image("xmark")
                                                .foregroundColor(Style.error)
                                                .font(.title)
                                        }
                                        .padding(8)
                                    }
                            }
                            
                            Spacer().frame(height: 157)
                        }
                        .animation(.default, value: vm.itemImage)
                        
                        if let fieldsData = vm.fieldsData {
                            CustomTextFieldView(text: $vm.itemName, prompt: fieldsData.first?.comment ?? "")
                                .focused($focusedField, equals: .itemName)
                                .onSubmit { focusedField = .itemURL }
                                .submitLabel(.next)
                                .autocorrectionDisabled()
                            
                            CustomTextFieldView(text: $vm.itemURL, prompt: fieldsData.last?.comment ?? "")
                                .focused($focusedField, equals: .itemURL)
                                .onSubmit { focusedField = nil }
                                .submitLabel(.done)
                                .autocorrectionDisabled()
                                .keyboardType(.URL)
                        }
                        
                        CustomButtonView(title: "Отправить запрос", isDisabled: $vm.isSubmitButtonDisabled) {
                            vm.fillDocument()
                        }
                        .padding(.vertical, 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                }
                
                StatusAlertView(status: $vm.status, onDisappear: vm.eraseDocumentData)
            }
            .safeAreaPadding()
            .frame(maxWidth: .infinity)
            .background(Style.background)
            .onTapGesture { focusedField = nil }
            .refreshable { vm.fetchFieldsData() }
            .onAppear(perform: vm.fetchFieldsData)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Хочу это")
                        .foregroundColor(Style.textPrimary)
                        .font(Style.title)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
            }
            .navigationDestination(isPresented: $isPresented) {
                WantThisRequestsView().toolbarRole(.editor)
            }
        }
    }
}
