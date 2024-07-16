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

extension Color {


    var hexString: String {
        let components = self.cgColor?.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        return String(format: "#%02lX%02lX%02lX", lround(Double(r * 255)), lround(Double(g * 255)), lround(Double(b * 255)))
    }
}

struct ColorExampleView: View {
    var colorName: String
    var colorCode: String
    var color: Color?

    var body: some View {
        HStack {
            Text(colorName)
                .frame(width: 150, alignment: .leading)
            Text(colorCode)
                .frame(width: 100, alignment: .leading)
            if let color = color {
                Rectangle()
                    .fill(color)
                    .frame(width: 50, height: 20)
            }
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
    let colors: [(String, Color?)] = [
            ("background", Style.background),
            ("onBackground", Style.onBackground),
            ("secondary", Style.secondary),
            ("secondary2", Style.secondary2),
            ("tertiary", Style.tertiary),
            ("surface", Style.surface),
            ("surface2", Style.surface2),
            ("onSurface", Style.onSurface),
            ("onSurface2", Style.onSurface2),
            ("error", Style.error),
            ("success", Style.success),
            ("info", Style.info),
            ("warning", Style.warning),
            ("iconsPrimary", Style.iconsPrimary),
            ("iconsPrimary2", Style.iconsPrimary2),
            ("iconsPrimary3", Style.iconsPrimary3),
            ("iconsSecondary", Style.iconsSecondary),
            ("iconsTertiary", Style.iconsTertiary),
            ("iconsTertiary2", Style.iconsTertiary2),
            ("iconsTertiary3", Style.iconsTertiary3),
            ("iconsTertiary4", Style.iconsTertiary4),
            ("textPrimary", Style.textPrimary),
            ("textPrimary2", Style.textPrimary2),
            ("textSecondary", Style.textSecondary),
            ("textTertiary", Style.textTertiary),
            ("textTertiary2", Style.textTertiary2),
            ("textTertiary3", Style.textTertiary3),
            ("textTertiary4", Style.textTertiary4),
            ("textButtonPrimary", Style.textButtonPrimary),
            ("primaryPressed", Style.primaryPressed),
            ("primaryDisabled", Style.primaryDisabled),
            ("secondaryPressed", Style.secondaryPressed),
            ("iconsPressed", Style.iconsPressed),
            ("iconsDisabled", Style.iconsDisabled),
            ("textPressed", Style.textPressed),
            ("textDisabled", Style.textDisabled)
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
                    ColorExampleView(colorName: color.0, colorCode: color.1!.hexString, color: color.1)
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
