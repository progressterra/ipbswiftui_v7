//
//  DeliveryOptionFillView.swift
//  WhiteLabel
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct DeliveryOptionFillView: View {
    @EnvironmentObject var vm: CartViewModel
    
    public enum DeliveryOption: DeliveryOptionProtocol {
//                case box
        case express
        
        public var description: String {
            switch self {
//                            case .box:
//                                return "Доставка до постамата или пункта выдачи"
            case .express:
                return "Курьерская доставка"
            }
        }
        
        public var imageName: String {
            switch self {
//                            case .box:
//                                return "deliveryBoxIcon"
            case .express:
                return "expressDeliveryIcon"
            }
        }
    }
    
    @State private var deliveryOption: DeliveryOption = .express
    
    public var body: some View {
        ZStack {
            VStack(spacing: 40) {
                DeliveryOptionPickerView(selectedOption: $deliveryOption)
                
                CustomTextFieldView(text: $vm.address, prompt: "Адрес")
                    .autocorrectionDisabled()
                
                if let suggestions = vm.suggestions, suggestions.count > 1 {
                    List(suggestions, id: \.self) { suggestion in
                        Text(suggestion.value)
                            .onTapGesture {
                                vm.address = suggestion.value
                                vm.suggestions = nil
                            }
                    }
                    .background(Style.surface)
                    .listStyle(.plain)
                    .cornerRadius(8)
                    .listRowBackground(Style.surface)
                    .frame(height: 200)
                    .shadow(color: .gray.opacity(0.1), radius: 2)
                    .padding(.top, -36)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Комментарий")
                    TextField("Напишите комментарий", text: $vm.comment, axis: .vertical)
                        .overlay(alignment: .bottom) { Divider() }
                }
            }
        }
        .onTapGesture(perform: dismissKeyboardAndSuggestionsList)
        .animation(.default, value: vm.suggestions)
    }
    
    private func dismissKeyboardAndSuggestionsList() {
        vm.suggestions = nil
        hideKeyboard()
    }
}
