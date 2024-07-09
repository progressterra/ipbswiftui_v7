//
//  WantThisView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 26.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// A view that allows users to submit requests for products they are interested in by uploading images and providing URLs.
///
/// This view integrates various UI components to let users upload a product image, input a product URL, and submit their request. The user's input is managed by `WantThisViewModel`. The view displays previous requests through a navigation button and shows a status alert for any operational feedback. It is designed to be user-friendly by using forms for input and validating the input before allowing the submission.
///
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
                                .foregroundStyle(Style.textPrimary)
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
                                            Image("xmark", bundle: .module)
                                                .foregroundStyle(Style.error)
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
            .frame(maxWidth: .infinity)
            .background(Style.background)
            .onTapGesture { focusedField = nil }
            .refreshable { vm.fetchFieldsData() }
            .onAppear(perform: vm.fetchFieldsData)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Хочу это")
                        .foregroundStyle(Style.textPrimary)
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
