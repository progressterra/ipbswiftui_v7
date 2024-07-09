//
//  CVCMaskModifier.swift
//  
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

/// A `ViewModifier` that masks the input text for a Card Verification Code (CVC) field and manages the real input separately for security purposes.
///
/// The modifier keeps the actual CVC text and a masked version as separate variables. The displayed text is masked with asterisks for security, only revealing the length of the input. The real CVC is stored in a separate variable that can be used for processing.
///
/// ## Usage Example
///
/// This modifier is ideal for `TextField` views where you need to accept a CVC while keeping the input obscured:
///
/// ```swift
/// TextField("CVC", text: $displayedText)
///     .modifier(CVCMaskModifier(realText: $realText, displayedText: $displayedText))
/// ```
///
/// ## Parameters
/// - `realText`: A `Binding<String>` that stores the actual CVC input.
/// - `displayedText`: A `Binding<String>` to the masked version of the CVC displayed in the UI.
///
/// ## Behavior
/// - The modifier masks input by replacing characters with asterisks after a slight delay, providing minimal feedback on the number of digits entered.
/// - Supports up to 3 digits, reflecting typical CVC lengths to maintain user privacy.
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
