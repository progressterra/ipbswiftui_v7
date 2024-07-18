//
//  File.swift
//  
//
//  Created by Sergey Spevak on 17.07.2024.
//

import Foundation
public class IPBUtils {
    public static let shared = IPBUtils()
    
    private init() {}
    
    public func formatDateString(_ input: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // Устанавливаем формат входной строки
        dateFormatter.dateFormat = "yyyyMMdd"
        
        // Преобразуем строку в объект Date
        if let date = dateFormatter.date(from: input) {
            
            // Устанавливаем формат выходной строки
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            // Преобразуем объект Date обратно в строку
            let formattedString = dateFormatter.string(from: date)
            return formattedString
        } else {
            // Если строка не может быть преобразована в объект Date
            return nil
        }
    }
}
