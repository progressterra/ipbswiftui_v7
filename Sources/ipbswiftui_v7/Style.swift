//
//  Style.swift
//
//
//  Created by Artemy Volkov on 19.07.2023.
//

import Foundation
import SwiftUI

/// Manages the UI style configuration for the application.
///
/// The `Style` struct provides a unified approach to configuring and applying a consistent style across the SwiftUI application. It reads settings from the `StyleConfig.json` file, enabling easy adjustments to colors, button styles, and more without altering the codebase.
///
/// ## Configuration
/// Locate `StyleConfig.json` in the project's directory with following structure:
///
/**
 ```json
 {
     "offerURL": "https://progressterra.com",
     "privacyURL": "https://progressterra.com",

     "mandatoryProfileFields": ["photo", "name", "surname", "patronymic", "birthday", "sex", "phone"],
     "customProfileNavigationTitle": "Личные данные",
     "customProfileButtonTitle": "Далее",

     "buttonHeight": 50,
     "buttonCornerRadius": 14,

     "background": "#262223",
     "onBackground": "#001001",
     "primaryStart": "#7209b7",
     "primaryEnd": "#f72585",
     "secondary": "#3E4555",
     "secondary2": "#CDCDD6",
     "tertiary": "#B5B5BC",
     "surface": "#2e2e2d",
     "surface2": "#111111",
     "onSurface": "#54544e",
     "onSurface2": "#101010",
     
     "error": "#DF3636",
     "success": "#7ADB6B",
     "info": "#6980CF",
     "warning": "#DB742A",
     
     "iconsPrimary": "#111111",
     "iconsPrimary2": "#E82741",
     "iconsPrimary3": "#656565",
     "iconsSecondary": "#FFFFFF",
     "iconsTertiary": "#B5B5BC",
     "iconsTertiary2": "#4578DC",
     "iconsTertiary3": "#B2FF75",
     "iconsTertiary4": "#F6E651",
     
     "textPrimary": "#FFFFFF",
     "textPrimary2": "#E82741",
     "textSecondary": "#6E7289",
     "textTertiary": "#9191A1",
     "textTertiary2": "#453896",
     "textTertiary3": "#28AB13",
     "textTertiary4": "#CA451C",
     "textButtonPrimary": "#FFFFFF",
     
     "primaryPressed": "#3D3D3D",
     "primaryDisabled": "#70103c",
     "secondaryPressed": "#232427",
     "iconsPressed": "#0F1215",
     "iconsDisabled": "#B5B5B5",
     "textPressed": "#24282E",
     "textDisabled": "#B5B5B5"
 }
 ```
 */
///
/// ## Initialization
/// Ensure to call `loadConfiguration()` during app launch:
///
/// ```swift
/// Style.loadConfiguration()
/// ```
///
/// ## Custom Fonts
/// Besides using system dynamic fonts, `Style` allows specifying custom fonts to better align with your branding guidelines. Assign custom font values to `Style`'s static properties to apply them globally:
///
/// ```swift
/// Style.title = .custom("YourFontName-Bold", size: 20, relativeTo: .title3)
/// ```
///
/// ## Customization Points
/// - **URLs**: Links for offers, privacy policies, etc.
/// - **SCRM Fields**: Customizable fields for profile details.
/// - **Button Style**: Height and corner radius for buttons.
/// - **Fonts**: Font sizes and weights for different text elements.
/// - **Colors**: Comprehensive theming with support for light and dark modes.
///
/// ## Usage
/// After configuring the `Style` struct, access its properties directly when styling SwiftUI views. For instance, use `Style.primary` for button background gradients or `Style.textPrimary` for primary text color.
public struct Style {
    
    // URLs
    public private(set) static var offerURL: String = ""
    public private(set) static var privacyURL: String = ""
    
    // SCRM fields configuration
    public private(set) static var mandatoryProfileFields: Set<ProfileDetailView.Field>?
    public private(set) static var customProfileNavigationTitle: String?
    public private(set) static var customProfileButtonTitle: String?
    
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
        
        // URLs
        let offerURL: String?
        let privacyURL: String?
        
        // SCRM fields configuration
        let mandatoryProfileFields: [String]?
        let customProfileNavigationTitle: String?
        let customProfileButtonTitle: String?
        
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
            fatalError("Failed to decode StyleConfig.json file: \(error)")
        }
    }
    
    private static func configure(with config: StyleConfiguration) {
        
        // URLs
        if let url = config.offerURL {
            self.offerURL = url
        }
        if let url = config.privacyURL {
            self.privacyURL = url
        }
        
        // SCRM fields configuration
        if let fields = config.mandatoryProfileFields {
            self.mandatoryProfileFields = Set(fields.compactMap { ProfileDetailView.Field(rawValue: $0) })
        }
        if let title = config.customProfileNavigationTitle {
            customProfileNavigationTitle = title
        }
        if let buttonTitle = config.customProfileButtonTitle {
            customProfileButtonTitle = buttonTitle
        }
        
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
