//
//  DeliveryOptionPickerView.swift
//
//
//  Created by Artemy Volkov on 17.08.2023.
//

import SwiftUI

/// Protocol defining delivery options with associated image and description.
public protocol DeliveryOptionProtocol: CaseIterable, Hashable {
    var description: String { get }
    var imageName: String { get }
}

public struct DeliveryOptionPickerView<T: DeliveryOptionProtocol>: View {
    @Binding var selectedOption: T
    
    public init(selectedOption: Binding<T>) {
        self._selectedOption = selectedOption
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Выберите способ доставки")
                .font(Style.title)
                .foregroundStyle(Style.textPrimary)
            
            VStack(spacing: 36) {
                ForEach(Array(T.allCases), id: \.self) { option in
                    Button(action:  { selectedOption = option }) {
                        HStack {
                            RadioButtonView(isSelected: selectedOption == option)
                                .fixedSize()
                            
                            Text(option.description)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(
                                    selectedOption == option
                                    ? Style.textPrimary
                                    : Style.textDisabled
                                )
                                .padding(.leading, 20)
                            
                            Spacer(minLength: 66)
                            
                            Image(option.imageName, bundle: .module)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(
                                                selectedOption == option
                                               ? Style.primary
                                               : LinearGradient(colors: [Style.textDisabled],
                                                                startPoint: .center,
                                                                endPoint: .center)
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(.default, value: selectedOption)
    }
}
