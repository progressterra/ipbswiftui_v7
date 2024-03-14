//
//  PressEffectStyle.swift
//
//  Created by Artemy Volkov on 13.03.2024.
//

import SwiftUI

public struct ButtonPressEffectStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
