//
//  CardNumberFormatter.swift
//  
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

/// A `ViewModifier` that formats an input text to display as a credit card number with spaces separating every four digits.
///
/// This modifier improves readability by grouping digits into sets of four, commonly used in credit card number formatting. It automatically filters out any non-numeric characters and ensures the input is limited to 16 digits, reflecting standard credit card number lengths.
///
/// ## Usage Example
///
/// Attach this modifier to a `TextField` in SwiftUI to format user input as a credit card number:
///
/// ```swift
/// TextField("Enter your card number", text: $cardNumber)
///     .modifier(CardNumberFormatter(text: $cardNumber))
/// ```
///
/// ## Parameters
/// - `text`: A `Binding<String>` to the text input that will be formatted.
///
/// ## Behavior
/// - On appearance and when the text changes, the input is formatted to include spaces after every four digits to ensure the text is visually coherent as a credit card number.
/// - Prevents entry of more than 16 digits to match standard credit card formats.
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
