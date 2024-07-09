//
//  PressEffectStyle.swift
//
//  Created by Artemy Volkov on 13.03.2024.
//

import SwiftUI

/// A button style that applies a scaling effect to buttons when they are pressed.
public struct ButtonPressEffectStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
