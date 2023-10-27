//
//  Date + Extension.swift
//  
//
//  Created by Artemy Volkov on 29.08.2023.
//

import Foundation

public extension Date {
    func format(as format: String, timeZone: TimeZone = .autoupdatingCurrent, locale: Locale = Locale(identifier: "ru_RU")) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
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
}
