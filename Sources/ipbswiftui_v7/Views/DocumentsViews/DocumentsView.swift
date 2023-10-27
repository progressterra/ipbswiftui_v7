//
//  DocumentsView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 31.07.2023.
//

import SwiftUI
import ipbswiftapi_v7

public struct DocumentsView: View {
    @EnvironmentObject var vm: DocumentsViewModel
    
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
                    .foregroundColor(Style.textPrimary)
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
