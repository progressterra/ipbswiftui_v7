//
//  ExpiryDateModifier.swift
//
//
//  Created by Artemy Volkov on 15.08.2023.
//

import SwiftUI

public struct ExpiryDateModifier: ViewModifier {
    @Binding public var month: String
    @Binding public var year: String
    @Binding public var displayedText: String
    
    public init(month: Binding<String>, year: Binding<String>, displayedText: Binding<String>) {
        self._month = month
        self._year = year
        self._displayedText = displayedText
    }
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: displayedText) { newValue in
                let filtered = newValue.filter { $0.isNumber }.prefix(4)
                
                if filtered.count > 2 {
                    month = String(filtered.prefix(2))
                    year = String(filtered.suffix(2))
                } else {
                    month = String(filtered)
                    year = ""
                }
                
                if filtered.count == 4 {
                    withAnimation(.easeInOut(duration: 0.5).delay(0.5)) {
                        displayedText = "\(month)/\(year)"
                    }
                } else {
                    displayedText = String(filtered)
                }
            }
            .onAppear {
                withAnimation {
                    displayedText = month + (year.isEmpty ? "" : "/\(year)")
                }
            }
            .autocorrectionDisabled()
            .keyboardType(.numberPad)
    }
}
