//
//  PhoneNumberFormatterModifier.swift
//
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

/// A `ViewModifier` for formatting phone numbers in a user-friendly way. 
/// Number typed as `7##########` will be displayed as `+7(###)###-##-##`.
///
/// ## Usage Example
/// This modifier can be applied to any `TextField` in SwiftUI to automatically format the entered phone number:
///
/// ```swift
/// TextField("Phone Number", text: $displayedPhoneNumber)
///     .modifier(PhoneNumberFormatterModifier(phoneNumber: $phoneNumber, displayedPhoneNumber: $displayedPhoneNumber))
/// ```
///
/// ## Parameters:
/// - `phoneNumber`: A `Binding<String>` that stores the raw phone number after removing non-numeric characters.
/// - `displayedPhoneNumber`: A `Binding<String>` that shows the formatted phone number in the UI.
///
/// ## Behavior:
/// - Automatically adds country codes, parentheses, and dashes for better readability.
/// - Begins formatting with the country code `+7` for Russia as an example, adaptable for other locales.
/// - Prevents non-numeric input and truncates to the maximum length typical for phone numbers (up to 11 digits).
public struct PhoneNumberFormatterModifier: ViewModifier {
    @Binding public var phoneNumber: String
    @Binding public var displayedPhoneNumber: String
    
    public init(phoneNumber: Binding<String>, displayedPhoneNumber: Binding<String>) {
        self._phoneNumber = phoneNumber
        self._displayedPhoneNumber = displayedPhoneNumber
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: displayedPhoneNumber) { newValue in
                let cleanedValue = newValue.filter(\.isNumber)
                phoneNumber = cleanedValue.isEmpty ? "7" : String(cleanedValue.prefix(11))
                
                let formatted = format(phoneNumber: phoneNumber)
                
                if displayedPhoneNumber != formatted {
                    displayedPhoneNumber = formatted
                }
            }
            .onAppear {
                if phoneNumber.isEmpty { phoneNumber = "7" }
                displayedPhoneNumber = format(phoneNumber: phoneNumber)
            }
    }
    
    private func format(phoneNumber: String) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        
        var result = ""
        
        if phoneNumber.first == "7" {
            result += "+"
        }
        
        let indices = [1, 4, 7, 9]
        let components: [String] = [
            " (",
            ") ",
            "-",
            "-"
        ]
        
        var previousIndex = phoneNumber.startIndex
        
        for (index, component) in zip(indices, components) {
            if index < phoneNumber.count {
                let nextIndex = phoneNumber.index(phoneNumber.startIndex, offsetBy: index)
                result += phoneNumber[previousIndex..<nextIndex]
                result += component
                previousIndex = nextIndex
            }
        }
        
        if previousIndex < phoneNumber.endIndex {
            result += phoneNumber[previousIndex..<phoneNumber.endIndex]
        }
        
        return result
    }
}
