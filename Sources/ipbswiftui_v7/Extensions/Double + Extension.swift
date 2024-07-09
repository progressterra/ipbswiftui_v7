//
//  Double + Extensionc.swift
//
//
//  Created by Artemy Volkov on 19.07.2023.
//

import Foundation

public extension Double {
    
    /// Formats the `Double` value as a currency string with the specified number of fraction digits, currency code, and locale.
    ///
    /// - Parameters:
    ///   - fractionDigits: The maximum number of digits after the decimal point. The default is 0.
    ///   - currencyCode: The ISO 4217 currency code. The default is "RUB" for the Russian Ruble.
    ///   - locale: The locale for formatting. The default is `Locale(identifier: "ru-RU")` for Russian.
    /// - Returns: A `String` representing the formatted currency value. Returns an empty string if the formatting fails.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// let amount = 1234.56
    /// print(amount.asCurrency(fractionDigits: 2))
    /// // Prints "1 234,56 ₽" when the default currency code and locale are used.
    /// ```
    ///
    /// This method can be used to display monetary values in a user interface, customized for different currencies and locales.
    func asCurrency(fractionDigits: Int = 0, currencyCode: String = "RUB", locale: Locale = Locale(identifier: "ru-RU")) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        numberFormatter.locale = locale
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    /// A string representation of the `Double` value without trailing zeros, formatted to a maximum of 2 decimal places.
    ///
    /// - Returns: A `String` representing the formatted number. Returns an empty string if the formatting fails.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// let value = 1234.50
    /// print(value.clean)
    /// // Prints "1234.5"
    ///
    /// let value2 = 1234.00
    /// print(value2.clean)
    /// // Prints "1234"
    /// ```
    ///
    /// This property is useful for displaying numeric values in a concise format when precision beyond two decimal places is not necessary.
    var clean: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
