//
//  ExpiryDateModifier.swift
//
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

/// A `ViewModifier` that formats and manages input for credit card expiry dates in a `TextField`.
/// It automatically handles the input for month and year, and formats it in "MM/YY" format.
///
/// ## Usage Example
///
/// Apply this modifier to a `TextField` to enable automatic formatting of credit card expiry dates:
///
/// ```swift
/// TextField("Expiry Date", text: $displayedText)
///     .modifier(ExpiryDateModifier(month: $month, year: $year, displayedText: $displayedText))
/// ```
///
/// ## Parameters:
/// - `month`: A `Binding<String>` reflecting the two-digit month.
/// - `year`: A `Binding<String>` reflecting the two-digit year.
/// - `displayedText`: A `Binding<String>` that shows the formatted expiry date in the TextField.
///
/// ## Behavior:
/// - Inputs are automatically formatted as "MM/YY". The month and year are stored separately for potential use in validations or submissions.
/// - Supports up to 4 numeric characters: the first two for the month and the last two for the year.
public struct ExpiryDateModifier: ViewModifier {
    @Binding public var month: String
    @Binding public var year: String
    @Binding public var displayedText: String
    
    public init(month: Binding<String>, year: Binding<String>, displayedText: Binding<String>) {
        self._month = month
        self._year = year
        self._displayedText = displayedText
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: displayedText) { newValue in
                let filtered = newValue.filter { $0.isNumber }.prefix(4)
                
                if filtered.count > 2 {
                    month = String(filtered.prefix(2))
                    year = String(filtered.suffix(2))
                } else {
                    month = String(filtered)
                    year = ""
                }
                
                if filtered.count == 4 {
                    withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                        displayedText = "\(month)/\(year)"
                    }
                } else {
                    displayedText = String(filtered)
                }
            }
            .onAppear {
                withAnimation {
                    displayedText = month + (year.isEmpty ? "" : "/\(year)")
                }
            }
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
    }
}
