//
//  MessageView.swift
//  
//
//  Created by Artemy Volkov on 10.08.2023.
//

import Foundation
import SwiftUI

public struct MessageView: View {
    
    let contentText: String
    let dateAdded: Date
    let isOwnMessage: Bool
    let backgroundColor: Color
    
    public init(contentText: String, dateAdded: Date, isOwnMessage: Bool, backgroundColor: Color) {
        self.contentText = contentText
        self.dateAdded = dateAdded
        self.isOwnMessage = isOwnMessage
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        HStack {
            if isOwnMessage { Spacer(minLength: 16) }
            
            VStack(alignment: isOwnMessage ? .trailing : .leading, spacing: 2) {
                Text(contentText)
                    .foregroundColor(Style.textPrimary)
                    .font(Style.body)
                    .multilineTextAlignment(isOwnMessage ? .trailing : .leading)
                Text(
                    dateAdded.format(
                        as: "dd MMM yyyy HH:mm",
                        timeZone: TimeZone(secondsFromGMT: 3 * 3600) ?? .current,
                        locale: Locale(identifier: "ru_RU")
                    )
                )
                .foregroundColor(Style.textTertiary)
                .font(Style.footnoteRegular)
            }
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(12)
            
            if !isOwnMessage { Spacer(minLength: 16) }
        }
    }
}
