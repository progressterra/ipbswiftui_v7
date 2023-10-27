//
//  NavigationButtonView.swift
//  
//
//  Created by Artemy Volkov on 28.07.2023.
//

import SwiftUI

public struct NavigationButtonView: View {
    public enum Status {
        case info
        case rejected
        case approved
    }
    
    let title: String
    let prompt: String?
    let badgeCount: Int?
    let isDestructive: Bool
    let status: Status
    let action: () -> ()
    
    public init(
        title: String,
        prompt: String? = nil,
        badgeCount: Int? = nil,
        isDestructive: Bool = false,
        status: Status = .info,
        action: @escaping () -> ()
    ) {
        self.title = title
        self.prompt = prompt
        self.badgeCount = badgeCount
        self.isDestructive = isDestructive
        self.status = status
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: -2) {
                    Text(title)
                        .font(Style.body)
                        .foregroundColor(isDestructive ? Style.textPrimary2 : Style.textPrimary)
                    if let prompt {
                        Text(prompt)
                            .font(Style.footnoteRegular)
                            .foregroundColor(promptColor)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if let badgeCount, badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(Style.captionBold)
                        .foregroundColor(Style.surface)
                        .minimumScaleFactor(0.7)
                        .frame(width: 15, height: 15)
                        .padding(1)
                        .background(Style.primary)
                        .clipShape(Circle())
                        .transition(.opacity)
                        .animation(.default, value: badgeCount)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(isDestructive ? Style.iconsPrimary2 : Style.iconsPrimary)
                    .font(.footnote)
                    .frame(width: 16, height: 16)
            }
            .frame(height: 52)
            .padding(.horizontal)
            .background(Style.surface)
            .cornerRadius(8)
        }
    }
    
    var promptColor: Color {
        switch status {
        case .info:
            return Style.textTertiary
        case .rejected:
            return Style.textPrimary2
        case .approved:
            return Style.onBackground
        }
    }
}


struct NavigationButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            VStack(spacing: 8) {
                NavigationButtonView(title: "Удалить аккаунт", isDestructive: true, action: {})
                NavigationButtonView(title: "Паспорт", prompt: "Требуется добавить изображение документа", status: .rejected, action: {})
                NavigationButtonView(title: "Паспорт", prompt: "Требуется добавить изображение документа", status: .info, action: {})
                NavigationButtonView(title: "Паспорт", prompt: "Требуется добавить изображение документа", badgeCount: 999, status: .approved, action: {})
            }
            .padding()
        }
    }
}
