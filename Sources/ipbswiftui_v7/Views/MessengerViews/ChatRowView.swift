//
//  ChatRowView.swift
//
//
//  Created by Artemy Volkov on 18.10.2023.
//

import SwiftUI

/// Image View ideal size: 64x64 points
public struct ChatRowView<ImageView: View>: View {
    let imageView: ImageView
    let title: String
    let prompt: String
    let dateLastMessages: Date?
    let badgeCount: Int?
    let backgroundColor: Color
    
    public init(imageView: ImageView, title: String, prompt: String, dateLastMessages: Date? = .now, badgeCount: Int? = 0, backgroundColor: Color = Style.surface) {
        self.imageView = imageView
        self.title = title
        self.prompt = prompt
        self.dateLastMessages = dateLastMessages
        self.badgeCount = badgeCount
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            imageView
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .lineLimit(1)
                    .font(Style.headline)
                Text(prompt)
                    .lineLimit(1)
                    .font(Style.body)
            }
            
            Spacer()
            
            VStack {
                if let badgeCount = badgeCount, badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(Style.captionBold)
                        .foregroundStyle(Style.surface)
                        .minimumScaleFactor(0.7)
                        .frame(width: 15, height: 15)
                        .padding(1)
                        .background(Style.primary)
                        .clipShape(Circle())
                        .transition(.opacity)
                        .animation(.default, value: badgeCount)
                }
                
                if let dateLastMessages = dateLastMessages {
                    Text(dateLastMessages.timeDiffString())
                        .font(Style.subheadlineBold)
                }
            }
        }
        .foregroundStyle(Style.textPrimary)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}
