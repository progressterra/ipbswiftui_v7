//
//  Double + Extensionc.swift
//  
//
//  Created by Artemy Volkov on 19.07.2023.
//

import Foundation

public extension Double {
    func asCurrency(fractionDigits: Int = 0) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "RUB"
        numberFormatter.locale = Locale(identifier: "ru-RU")
        numberFormatter.maximumFractionDigits = fractionDigits
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var clean: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
