//
//  DocumentsView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

/// A view for managing documents based on user-selected citizenship.
///
/// `DocumentsView` provides an interface for users to select their citizenship and manage corresponding documents. It leverages the `DocumentsViewModel` to handle data fetching and updates based on the selected citizenship, and dynamically displays the necessary document fields for user interaction.
///
/// - Allows users to select their citizenship from a picker menu.
/// - Displays relevant documents and their statuses once citizenship is selected.
/// - Uses navigation to detailed views for filling out or updating individual document details.
///
/// ## Usage
///
/// The view is used within a navigation context where `DocumentsViewModel` is injected as an environment object. This setup ensures that the view has access to the necessary document data and state management provided by the ViewModel.
///
/// ```swift
/// NavigationView {
///     DocumentsView()
///         .environmentObject(DocumentsViewModel())
/// }
/// ```
/// 
public struct DocumentsView: View {
    
    @EnvironmentObject var vm: DocumentsViewModel
    
    @AppStorage("citizenship") private var citizenship: String = DocumentsViewModel.Citizenship.none.rawValue
    
    @State private var isPresented: Bool = false
    @State private var currentDocumentCharacteristic: CharacteristicData?
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Menu {
                Picker("Выберите гражданство", selection: $vm.citizenship) {
                    ForEach(DocumentsViewModel.Citizenship.allCases.dropLast(), id: \.self) { citizenship in
                        Text(citizenship.rawValue)
                    }
                }
            } label: {
                CustomTextFieldView(text: $vm.citizenshipText, prompt: "Гражданство")
                    .multilineTextAlignment(.leading)
            }
            .onChange(of: vm.citizenship) {
                citizenship = $0.rawValue
            }
            .onAppear {
                vm.citizenship = DocumentsViewModel.Citizenship(rawValue: citizenship) ?? .none
            }
            
            if let listProductCharacteristic = vm.documentSet?.data?.listProductCharacteristic {
                ForEach(listProductCharacteristic, id: \.characteristicType.idUnique) { characteristic in
                    NavigationButtonView(
                        title: characteristic.characteristicType.name ?? "",
                        prompt: vm.displayDocStatus(characteristic.characteristicValue.statusDoc),
                        status: .info
                    ) {
                        isPresented = true
                        currentDocumentCharacteristic = characteristic
                    }
                }
            }
            Spacer()
        }
        .animation(.default, value: vm.documentSet?.result.xRequestID)
        .onAppear(perform: vm.fetchDocumentSet)
        .padding()
        .background(Style.background)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Документы")
                    .foregroundStyle(Style.textPrimary)
                    .font(Style.title)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomProgressView(isLoading: vm.isLoading)
            }
        }
        .navigationDestination(isPresented: $isPresented) {
            if let currentDocumentCharacteristic {
                FillDocumentView(characteristic: currentDocumentCharacteristic).toolbarRole(.editor)
            }
        }
    }
}
