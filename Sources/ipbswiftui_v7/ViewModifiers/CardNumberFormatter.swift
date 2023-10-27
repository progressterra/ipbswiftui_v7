//
//  CardNumberFormatter.swift
//  
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

public struct CardNumberFormatter: ViewModifier {
    @Binding public var text: String
    
    public init(text: Binding<String>) {
        self._text = text
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                if !text.contains(" ") && text.count == 16 {
                    text = format(cardNumber: text)
                }
            }
            .onChange(of: text) { newValue in
                let strippedValue = newValue.filter { "0"..."9" ~= $0 }
                if strippedValue.count <= 16 {
                    text = format(cardNumber: strippedValue)
                } else {
                    text = String(text.prefix(19))
                }
            }
            .keyboardType(.numberPad)
    }
    
    private func format(cardNumber: String) -> String {
        var formatted = ""
        for (index, character) in cardNumber.enumerated() {
            if index != 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(character)
        }
        return formatted
    }
}
