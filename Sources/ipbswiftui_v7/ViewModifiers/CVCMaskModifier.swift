//
//  CVCMaskModifier.swift
//  
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

public struct CVCMaskModifier: ViewModifier {
    @Binding public var realText: String
    @Binding public var displayedText: String
    
    public init(realText: Binding<String>, displayedText: Binding<String>) {
        self._realText = realText
        self._displayedText = displayedText
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: displayedText) { newValue in
                let trimmedValue = newValue.prefix(3)
                
                if trimmedValue.count > realText.count {
                    let addedChar = trimmedValue.last!
                    realText.append(addedChar)
                } else if newValue == "" {
                    realText = ""
                } else if trimmedValue.count < realText.count {
                    realText = String(realText.dropLast())
                }
                
                withAnimation(.easeInOut(duration: 0.3).delay(0.5)) {
                    displayedText = String(repeating: "*", count: realText.count)
                }
            }
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
    }
}
