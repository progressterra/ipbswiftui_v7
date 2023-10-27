//
//  Style.swift
//  
//
//  Created by Artemy Volkov on 19.07.2023.
//

import Foundation
import SwiftUI

public struct Style {
    
    // Button style
    public private(set) static var buttonHeight: CGFloat = 50
    public private(set) static var buttonCornerRadius: CGFloat = 14
    
    // Font styles
    public static var largeTitle = Font.largeTitle.bold()
    public static var title = Font.title3.bold()
    public static var headline = Font.headline.bold()
    public static var body = Font.body
    public static var body2 = Font.subheadline
    public static var subheadlineRegular = Font.subheadline
    public static var subheadlineItalic = Font.subheadline.weight(.semibold).italic()
    public static var subheadlineBold = Font.subheadline.bold()
    public static var footnoteRegular = Font.footnote
    public static var footnoteBold = Font.footnote.bold()
    public static var captionBold = Font.caption.bold()
    
    // General
    public static var background = Color(hex: "#F2F5FF")
    public static var onBackground = Color(hex: "#2E8E6C")
    public static var primary: LinearGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "#35C290"), location: 0.00),
            .init(color: Color(hex: "#2E9399"), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
    )
    public static var secondary = Color(hex: "#3E4555")
    public static var secondary2 = Color(hex: "#CDCDD6")
    public static var tertiary = Color(hex: "#B5B5BC")
    public static var surface = Color(hex: "#FFFFFF")
    public static var surface2 = Color(hex: "#111111")
    public static var onSurface = Color(hex: "#FFFFFF")
    public static var onSurface2 = Color(hex: "#101010")
    
    // Server
    public static var error = Color(hex: "#DF3636")
    public static var success = Color(hex: "#7ADB6B")
    public static var info = Color(hex: "#6980CF")
    public static var warning = Color(hex: "#DB742A")
    
    // Icons
    public static var iconsPrimary = Color(hex: "#111111")
    public static var iconsPrimary2 = Color(hex: "#E82741")
    public static var iconsPrimary3 = Color(hex: "#656565")
    public static var iconsSecondary = Color(hex: "#FFFFFF")
    public static var iconsTertiary = Color(hex: "#B5B5BC")
    public static var iconsTertiary2 = Color(hex: "#4578DC")
    public static var iconsTertiary3 = Color(hex: "#B2FF75")
    public static var iconsTertiary4 = Color(hex: "#F6E651")
    
    // Text
    public static var textPrimary = Color(hex: "#111111")
    public static var textPrimary2 = Color(hex: "#E82741")
    public static var textSecondary = Color(hex: "#6E7289")
    public static var textTertiary = Color(hex: "#9191A1")
    public static var textTertiary2 = Color(hex: "#453896")
    public static var textTertiary3 = Color(hex: "#28AB13")
    public static var textTertiary4 = Color(hex: "#CA451C")
    public static var textButtonPrimary = Color(hex: "#FFFFFF")
    
    // States
    public static var primaryPressed = Color(hex: "#3D3D3D")
    public static var primaryDisabled = Color(hex: "#E4E4F0")
    public static var secondaryPressed = Color(hex: "#232427")
    public static var iconsPressed = Color(hex: "#0F1215")
    public static var iconsDisabled = Color(hex: "#B5B5B5")
    public static var textPressed = Color(hex: "#24282E")
    public static var textDisabled = Color(hex: "#B5B5B5")
    
    
    private struct StyleConfiguration: Codable {
        
        // Button style
        let buttonHeight: Float?
        let buttonCornerRadius: Float?
        
        // Colors (Hex strings)
        let background: String?
        let onBackground: String?
        let primaryStart: String?
        let primaryEnd: String?
        let secondary: String?
        let secondary2: String?
        let tertiary: String?
        let surface: String?
        let surface2: String?
        let onSurface: String?
        let onSurface2: String?
        let error: String?
        let success: String?
        let info: String?
        let warning: String?
        
        // Icons Colors
        let iconsPrimary: String?
        let iconsPrimary2: String?
        let iconsPrimary3: String?
        let iconsSecondary: String?
        let iconsTertiary: String?
        let iconsTertiary2: String?
        let iconsTertiary3: String?
        let iconsTertiary4: String?
        
        // Text Colors
        let textPrimary: String?
        let textPrimary2: String?
        let textSecondary: String?
        let textTertiary: String?
        let textTertiary2: String?
        let textTertiary3: String?
        let textTertiary4: String?
        let textButtonPrimary: String?
        
        // State Colors
        let primaryPressed: String?
        let primaryDisabled: String?
        let secondaryPressed: String?
        let iconsPressed: String?
        let iconsDisabled: String?
        let textPressed: String?
        let textDisabled: String?
    }
    
    
    public static func loadConfiguration() {
        let decoder = JSONDecoder()
        
        guard let url = Bundle.main.url(forResource: "StyleConfig", withExtension: "json") else {
            fatalError("Failed to locate StyleConfig.json file.")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load StyleConfig.json file.")
        }
        
        do {
            let config = try decoder.decode(StyleConfiguration.self, from: data)
            configure(with: config)
        } catch {
            fatalError("Failed to decode StyleConfig.json file: \(error.localizedDescription)")
        }
    }
    
    private static func configure(with config: StyleConfiguration) {
        
        // Button style
        if let height = config.buttonHeight {
            self.buttonHeight = CGFloat(height)
        }
        if let cornerRadius = config.buttonCornerRadius {
            self.buttonCornerRadius = CGFloat(cornerRadius)
        }
        
        // General Colors
        if let hex = config.background {
            self.background = Color(hex: hex)
        }
        if let hex = config.onBackground {
            self.onBackground = Color(hex: hex)
        }
        if let startHex = config.primaryStart, let endHex = config.primaryEnd {
            self.primary = LinearGradient(
                stops: [
                    .init(color: Color(hex: startHex), location: 0.00),
                    .init(color: Color(hex: endHex), location: 1.00)
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
        }
        if let hex = config.secondary {
            self.secondary = Color(hex: hex)
        }
        if let hex = config.secondary2 {
            self.secondary2 = Color(hex: hex)
        }
        if let hex = config.tertiary {
            self.tertiary = Color(hex: hex)
        }
        if let hex = config.surface {
            self.surface = Color(hex: hex)
        }
        if let hex = config.surface2 {
            self.surface2 = Color(hex: hex)
        }
        if let hex = config.onSurface {
            self.onSurface = Color(hex: hex)
        }
        if let hex = config.onSurface2 {
            self.onSurface2 = Color(hex: hex)
        }
        
        // Status Colors
        if let hex = config.error {
            self.error = Color(hex: hex)
        }
        if let hex = config.success {
            self.success = Color(hex: hex)
        }
        if let hex = config.info {
            self.info = Color(hex: hex)
        }
        if let hex = config.warning {
            self.warning = Color(hex: hex)
        }
        
        // Icons Colors
        if let hex = config.iconsPrimary {
            self.iconsPrimary = Color(hex: hex)
        }
        if let hex = config.iconsPrimary2 {
            self.iconsPrimary2 = Color(hex: hex)
        }
        if let hex = config.iconsSecondary {
            self.iconsSecondary = Color(hex: hex)
        }
        if let hex = config.iconsTertiary {
            self.iconsTertiary = Color(hex: hex)
        }
        if let hex = config.iconsTertiary2 {
            self.iconsTertiary2 = Color(hex: hex)
        }
        if let hex = config.iconsTertiary3 {
            self.iconsTertiary3 = Color(hex: hex)
        }
        if let hex = config.iconsTertiary4 {
            self.iconsTertiary4 = Color(hex: hex)
        }
        
        // Text Colors
        if let hex = config.textPrimary {
            self.textPrimary = Color(hex: hex)
        }
        if let hex = config.textPrimary2 {
            self.textPrimary2 = Color(hex: hex)
        }
        if let hex = config.textSecondary {
            self.textSecondary = Color(hex: hex)
        }
        if let hex = config.textTertiary {
            self.textTertiary = Color(hex: hex)
        }
        if let hex = config.textTertiary2 {
            self.textTertiary2 = Color(hex: hex)
        }
        if let hex = config.textTertiary3 {
            self.textTertiary3 = Color(hex: hex)
        }
        if let hex = config.textTertiary4 {
            self.textTertiary4 = Color(hex: hex)
        }
        if let hex = config.textButtonPrimary {
            self.textButtonPrimary = Color(hex: hex)
        }
        
        // State Colors
        if let hex = config.primaryPressed {
            self.primaryPressed = Color(hex: hex)
        }
        if let hex = config.primaryDisabled {
            self.primaryDisabled = Color(hex: hex)
        }
        if let hex = config.secondaryPressed {
            self.secondaryPressed = Color(hex: hex)
        }
        if let hex = config.iconsPressed {
            self.iconsPressed = Color(hex: hex)
        }
        if let hex = config.iconsDisabled {
            self.iconsDisabled = Color(hex: hex)
        }
        if let hex = config.textPressed {
            self.textPressed = Color(hex: hex)
        }
        if let hex = config.textDisabled {
            self.textDisabled = Color(hex: hex)
        }
    }
}
