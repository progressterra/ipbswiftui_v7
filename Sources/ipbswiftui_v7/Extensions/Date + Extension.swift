//
//  Date + Extension.swift
//
//
//  Created by Artemy Volkov on 29.08.2023.
//

import Foundation

public extension Date {
    
    /// Formats the `Date` object into a `String` representation based on the specified format, time zone, and locale.
    ///
    /// - Parameters:
    ///   - format: A `String` specifying the desired date format. This format string uses the format patterns from the Unicode Technical Standard #35. For example, "yyyy-MM-dd HH:mm:ss" represents a common timestamp format.
    ///   - timeZone: A `TimeZone` object representing the time zone to use when formatting the date. The default value is `.autoupdatingCurrent`, which uses the user's current time zone.
    ///   - locale: A `Locale` object representing the locale to use for formatting. The default value is `Locale(identifier: "ru_RU")`, which formats the date using Russian locale conventions.
    /// - Returns: A `String` representing the formatted date according to the specified format, time zone, and locale.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// let now = Date()
    /// let formattedDate = now.format(as: "yyyy-MM-dd HH:mm:ss")
    /// print(formattedDate) // Output might be "2024-04-05 12:34:56" depending on the current date and time.
    /// ```
    ///
    /// This method is particularly useful for displaying dates to users in a clear and locale-appropriate format, or when preparing dates for serialization where a specific format is required.
    func format(as format: String, timeZone: TimeZone = .autoupdatingCurrent, locale: Locale = Locale(identifier: "ru_RU")) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    /// Calculates the time difference between the instance date and the current date, returning it as a human-readable string.
    ///
    /// - Returns: A string representing the time difference in a compact format. Examples: "5д", "23ч", "15м". Returns an empty string for differences under one minute or future dates.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// let pastDate = Calendar.current.date(byAdding: .hour, value: -5, to: Date())!
    /// let diffString = pastDate.timeDiffString()
    /// print(diffString) // Prints "5ч" if the `pastDate` is exactly 5 hours in the past from now.
    /// ```
    ///
    /// This method is useful for displaying time differences in user interfaces where space is limited and precise timestamps are not required.
    func timeDiffString() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return  "\(day)д"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)ч"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)м"
        } else {
            return ""
        }
    }
    
    /// Returns the start of the day for the `Date` object based on the current calendar.
    func startOfDay() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}
