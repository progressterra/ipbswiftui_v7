//
//  String + Extension.swift
//  
//
//  Created by Artemy Volkov on 29.08.2023.
//

import Foundation

public extension String {
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
