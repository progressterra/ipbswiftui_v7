//
//  FillDocumentView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 03.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct FillDocumentView: View {
    @EnvironmentObject var vm: DocumentsViewModel
    @EnvironmentObject var supportServiceVM: MessengerViewModel
    
    @Environment(\.dismiss) var dismiss
    
    let characteristic: CharacteristicData
    
    @FocusState private var focusedField: Int?
    @State private var isChatPresented: Bool = false
    
    public init(characteristic: CharacteristicData) {
        self.characteristic = characteristic
    }
    
    public var body: some View {
        ZStack {
            Style.background
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if let fields = vm.inputFields[characteristic.characteristicValue.idUnique] {
                        ForEach(fields, id: \.order) { field in
                            CustomTextFieldView(
                                text: Binding(
                                    get: { vm.userInputs[field.order, default: field.valueData ?? ""] },
                                    set: { vm.userInputs[field.order] = $0 }
                                ),
                                prompt: field.comment ?? ""
                            )
                            .focused($focusedField, equals: field.order)
                            .onSubmit {
                                if let nextIndex = fields.firstIndex(where: { $0.order > field.order }) {
                                    focusedField = fields[nextIndex].order
                                } else {
                                    focusedField = nil
                                }
                            }
                            .submitLabel(field.order == fields.last?.order ? .done : .next)
                            .autocorrectionDisabled()
                        }
                    }
                    
                    if let imageRequired = characteristic.imageRequired, imageRequired {
                        HStack(spacing: 12) {
                            Text("Фото")
                                .font(Style.body)
                                .foregroundStyle(Style.textPrimary)
                            
                            CameraButtonView(inputImage: $vm.inputImage)
                            Spacer()
                        }.padding(.horizontal, 8)
                    }
                    
                    if let inputImage = vm.inputImage {
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 63, height: 63)
                            .cornerRadius(8)
                            .onAppear {
                                vm.inputImages[characteristic.characteristicValue.idUnique] = inputImage
                            }
                    } else if let imageURL = characteristic.characteristicValue.listImages?.sorted(by: { $0.dateAdded > $1.dateAdded}).first?.urlData {
                        AsyncImageView(
                            imageURL: imageURL,
                            width: 63,
                            height: 63,
                            cornerRadius: 8
                        )
                    }
                }
                .padding()
                .disabled(!vm.canEdit)
                
                CompactChatView(isPresented: $isChatPresented)
                    .padding()
            }
            .animation(.default, value: focusedField)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(characteristic.characteristicType.name ?? "")
                        .foregroundStyle(Style.textPrimary)
                        .font(Style.title)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CustomProgressView(isLoading: vm.isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        supportServiceVM.fetchOrCreateDialog(
                            for: .docset,
                            with: characteristic.characteristicType.name ?? "Документ",
                            reasonID: characteristic.characteristicValue.idUnique
                        )
                        isChatPresented = true
                    }) {
                        HStack(spacing: 5) {
                            Text("Чат")
                                .foregroundStyle(Style.textTertiary)
                                .font(Style.footnoteRegular)
                            Image("chatIcon", bundle: .module)
                                .foregroundStyle(Style.iconsTertiary)
                        }
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    Spacer()
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(action: {
                        navigateToPreviousField()
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(isFirstFieldFocused())
                }
                
                ToolbarItem(placement: .keyboard) {
                    Button(action: {
                        navigateToNextField()
                    }) {
                        Image(systemName:
                                focusedField == vm.inputFields[characteristic.characteristicValue.idUnique]?.last?.order
                              ? "keyboard.chevron.compact.down.fill"
                              : "chevron.down"
                        )
                    }
                }
            }
            
            VStack {
                Spacer()
                
                if focusedField == nil {
                    CustomButtonView(title: "Готово", isDisabled: $vm.isButtonDisabled) {
                        fillDocument()
                    }
                    .padding(8)
                    .background(
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Style.surface)
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                            .edgesIgnoringSafeArea(.bottom)
                    )
                    .padding(.horizontal, 8)
                    .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
                }
            }
            
            StatusAlertView(status: $vm.status) {
                dismiss()
            }
        }
        .animation(.default, value: isChatPresented)
        .onAppear {
            vm.currentDocumentID = characteristic.characteristicValue.idUnique
            vm.canEdit = characteristic.characteristicValue.statusDoc != .confirmed
        }
        .onDisappear {
            vm.inputImage = nil
            vm.userInputs = [:]
        }
    }
    
    private func navigateToPreviousField() {
        if let currentFieldOrder = focusedField, let previousField = vm.inputFields[characteristic.characteristicValue.idUnique]?.filter({ $0.order < currentFieldOrder }).last {
            focusedField = previousField.order
        }
    }
    
    private func navigateToNextField() {
        if let currentFieldOrder = focusedField, let nextField = vm.inputFields[characteristic.characteristicValue.idUnique]?.filter({ $0.order > currentFieldOrder }).first {
            focusedField = nextField.order
        } else {
            focusedField = nil
        }
    }
    
    private func isFirstFieldFocused() -> Bool {
        return focusedField == vm.inputFields[characteristic.characteristicValue.idUnique]?.first?.order
    }
    
    
    private func fillDocument() {
        guard var fields = vm.inputFields[characteristic.characteristicValue.idUnique] else { return }
        
        fields.indices.forEach { fields[$0].valueData = vm.userInputs[fields[$0].order] }
        
        vm.inputFields[characteristic.characteristicValue.idUnique] = fields
        
        vm.fillDocument(with: characteristic.characteristicValue.idUnique)
    }
}
