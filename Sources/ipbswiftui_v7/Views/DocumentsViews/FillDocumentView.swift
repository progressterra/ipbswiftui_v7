//
//  FillDocumentView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 03.08.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// A view for filling out or updating specific document details.
///
/// `FillDocumentView` presents an interface for users to input or update their details for a specific document characteristic. It supports handling images and input fields dynamically based on the document's requirements and allows for chat support interaction.
///
/// - Provides text fields for each required detail of the document.
/// - Supports adding an image associated with the document.
/// - Offers navigation to a chat view for additional support.
/// - Performs data validation and submission to update or complete document details.
///
/// ## Usage
///
/// The view is used within a navigation context where `DocumentsViewModel` and `MessengerViewModel` are injected as environment objects. This setup ensures that the view can manage document data and interact with support services.
///
/// ```swift
/// NavigationView {
///     FillDocumentView(characteristic: characteristic)
///         .environmentObject(DocumentsViewModel())
///         .environmentObject(MessengerViewModel())
/// }
/// ```
///
/// ## Functionality
/// - **Document Data Management**: Dynamically generates fields for input based on the document's requirements.
/// - **Image Handling**: Allows users to add or update an image related to the document.
/// - **Support Interaction**: Enables users to initiate a chat related to the document for additional support.
/// - **Data Submission**: Validates and submits the data to update the document details.
///
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
        .safeAreaInset(edge: .bottom) {
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
        }
        .overlay {
            StatusAlertView(status: $vm.status) {
                dismiss()
            }
        }
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
        .animation(.default, value: isChatPresented)
        .background(Style.background)
        .onTapGesture { focusedField = nil } 
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
