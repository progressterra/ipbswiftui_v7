//
//  OptionPickerView.swift
//  
//
//  Created by Artemy Volkov on 16.08.2023.
//

import SwiftUI

/// Protocol for option picker view
public protocol DisplayOptionProtocol: Hashable, Equatable {
    var rawValue: String { get }
}

/// Option picker - view to present options from enum that conforms to DisplayOptionProtocol
public struct OptionPickerView<T: DisplayOptionProtocol>: View {
    @Binding var value: T
    let options: [T]
    
    @Namespace private var animation
    
    public init(value: Binding<T>, options: [T]) {
        self._value = value
        self.options = options
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                ZStack {
                    if value == option {
                        Style.background
                            .cornerRadius(8)
                            .matchedGeometryEffect(id: "PickerBackground", in: animation)
                    }
                    Text(option.rawValue)
                        .padding(12)
                        .opacity(value == option ? 0 : 1)
                        .foregroundStyle(Style.textSecondary)
                        .overlay(
                            Text(option.rawValue)
                                .bold()
                                .opacity(value == option ? 1 : 0)
                                .foregroundStyle(Style.textPressed)
                        )
                        .frame(maxWidth: .infinity)
                        .onTapGesture { value = option }
                }
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(Style.surface)
        .cornerRadius(12)
        .font(Style.subheadlineRegular)
        .animation(.easeInOut, value: value)
    }
}
