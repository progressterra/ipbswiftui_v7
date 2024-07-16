//
//  StyleView.swift
//  WhiteLabel
//
//  Created by Sergey Spevak on 17.07.2024.
//

import Foundation
import SwiftUI


// Define the Color structure to handle hex color codes
//extension Color {
//    init(hex: String) {
//        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
//        var int: UInt64 = 0
//        scanner.scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3: // RGB (12-bit)
//            (a, r, g, b) = (255, (int >> 8 * 17), (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

struct ColorExampleView: View {
    var colorName: String
    var colorCode: String
    var color: Color

    var body: some View {
        HStack {
            Text(colorName)
                .frame(width: 150, alignment: .leading)
            Text(colorCode)
                .frame(width: 100, alignment: .leading)
            Rectangle()
                .fill(color)
                .frame(width: 50, height: 20)
        }
    }
}


struct GradientExampleView: View {
    var colorName: String
    var colorCode: String
    var gradient: LinearGradient

    var body: some View {
        HStack {
            Text(colorName)
                .frame(width: 150, alignment: .leading)
            Text(colorCode)
                .frame(width: 100, alignment: .leading)
            Rectangle()
                .fill(gradient)
                .frame(width: 50, height: 20)
        }
    }
}


struct StyleView: View {
    let colors: [(String, String, Color)] = [
        ("background", "#F2F5FF", Style.background),
        ("onBackground", "#2E8E6C", Style.onBackground),
        ("primaryStart", "#7209b7", Color(hex: "#7209b7")),
        ("primaryEnd", "#f72585", Color(hex: "#f72585")),
        ("secondary", "#3E4555", Style.secondary),
        ("secondary2", "#CDCDD6", Style.secondary2),
        ("tertiary", "#B5B5BC", Style.tertiary),
        ("surface", "#FFFFFF", Style.surface),
        ("surface2", "#111111", Style.surface2),
        ("onSurface", "#54544e", Style.onSurface),
        ("onSurface2", "#101010", Style.onSurface2),
        ("error", "#DF3636", Style.error),
        ("success", "#7ADB6B", Style.success),
        ("info", "#6980CF", Style.info),
        ("warning", "#DB742A", Style.warning),
        ("iconsPrimary", "#111111", Style.iconsPrimary),
        ("iconsPrimary2", "#E82741", Style.iconsPrimary2),
        ("iconsPrimary3", "#656565", Style.iconsPrimary3),
        ("iconsSecondary", "#FFFFFF", Style.iconsSecondary),
        ("iconsTertiary", "#B5B5BC", Style.iconsTertiary),
        ("iconsTertiary2", "#4578DC", Style.iconsTertiary2),
        ("iconsTertiary3", "#B2FF75", Style.iconsTertiary3),
        ("iconsTertiary4", "#F6E651", Style.iconsTertiary4),
        ("textPrimary", "#FFFFFF", Style.textPrimary),
        ("textPrimary2", "#E82741", Style.textPrimary2),
        ("textSecondary", "#6E7289", Style.textSecondary),
        ("textTertiary", "#9191A1", Style.textTertiary),
        ("textTertiary2", "#453896", Style.textTertiary2),
        ("textTertiary3", "#28AB13", Style.textTertiary3),
        ("textTertiary4", "#CA451C", Style.textTertiary4),
        ("textButtonPrimary", "#FFFFFF", Style.textButtonPrimary),
        ("primaryPressed", "#3D3D3D", Style.primaryPressed),
        ("primaryDisabled", "#70103c", Style.primaryDisabled),
        ("secondaryPressed", "#232427", Style.secondaryPressed),
        ("iconsPressed", "#0F1215", Style.iconsPressed),
        ("iconsDisabled", "#B5B5B5", Style.iconsDisabled),
        ("textPressed", "#24282E", Style.textPressed),
        ("textDisabled", "#B5B5B5", Style.textDisabled)
    ]
    
    let gradients: [(String, String, LinearGradient)] = [
        ("primary", "#primaryStart to #primaryEnd", Style.primary)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                ForEach(gradients, id: \.0) { gradient in
                                    GradientExampleView(colorName: gradient.0, colorCode: gradient.1, gradient: gradient.2)
                                        .padding(.vertical, 4)
                                }
                
                
                ForEach(colors, id: \.0) { color in
                    ColorExampleView(colorName: color.0, colorCode: color.1, color: color.2)
                        .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StyleView()
    }
}
