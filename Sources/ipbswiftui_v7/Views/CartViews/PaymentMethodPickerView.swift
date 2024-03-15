//
//  PaymentMethodPickerView.swift
//  
//
//  Created by Artemy Volkov on 17.08.2023.
//

import SwiftUI

public struct PaymentMethodPickerView<T: DisplayOptionProtocol>: View {
    @Binding var value: T
    let options: [T]
    
    public init(value: Binding<T>, options: [T]) {
        self._value = value
        self.options = options
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Оплата")
                .foregroundStyle(Style.textPrimary)
                .font(Style.title)
            
            VStack(spacing: 4) {
                ForEach(options, id: \.self) { option in
                    Button(action: { value = option }) {
                        HStack(spacing: 12) {
                            RadioButtonView(isSelected: value == option)
                                .fixedSize()
                            
                            Text(option.rawValue)
                                .font(Style.body)
                                .foregroundStyle(Style.textPrimary)
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Style.surface)
        .cornerRadius(12)
    }
}
