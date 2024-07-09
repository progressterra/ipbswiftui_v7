//
//  String + Extension.swift
//
//
//  Created by Artemy Volkov on 29.08.2023.
//

import Foundation

public extension String {
    
    /// Converts a string to a `Date` object based on the provided format and locale.
    ///
    /// - Parameters:
    ///   - format: A string representing the date format used in the string. Defaults to "yyyy-MM-dd'T'HH:mm:ss".
    ///   - locale: A `Locale` used to interpret the string. Defaults to "en_US_POSIX" which is a locale that's generally used for date strings.
    /// - Returns: An optional `Date` object if the string can be successfully converted, or `nil` if the conversion fails.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// let dateString = "2023-01-01T12:00:00"
    /// let date = dateString.toDate()
    /// print(date)
    /// ```
    ///
    /// This method is useful for parsing date strings that are formatted in a specific way into `Date` objects.
    func toDate(
        withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss",
        locale: Locale = Locale(identifier: "en_US_POSIX")
    ) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }
    
    /// Converts the date format of the string from one format to another, considering the input and output locales.
    ///
    /// - Parameters:
    ///   - inputFormat: The date format of the current string. Defaults to "yyyy-MM-dd'T'HH:mm:ss.SSSSSS".
    ///   - outputFormat: The target format for the output string.
    ///   - inputLocale: The locale corresponding to the input format. Defaults to "en_US_POSIX".
    ///   - outputLocale: The locale for the output format. Defaults to "ru_RU".
    /// - Returns: A `String` representing the date in the new format, or an empty string if conversion fails.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// let dateString = "2023-01-01T12:00:00.000000"
    /// let formattedString = dateString.convertDateFormat(from: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", to: "dd MMM yyyy", outputLocale: Locale(identifier: "en_US"))
    /// print(formattedString)
    /// // Might print "01 Jan 2023" depending on the locale.
    /// ```
    ///
    /// This method is particularly useful for displaying dates in a user-friendly format or converting between formats for serialization.
    func convertDateFormat(
        from inputFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
        to outputFormat: String,
        inputLocale: Locale = Locale(identifier: "en_US_POSIX"),
        outputLocale: Locale = Locale(identifier: "ru_RU")
    ) -> String {
        guard let date = self.toDate(withFormat: inputFormat, locale: inputLocale) else { return "" }
        return date.format(as: outputFormat, locale: outputLocale)
    }
}
