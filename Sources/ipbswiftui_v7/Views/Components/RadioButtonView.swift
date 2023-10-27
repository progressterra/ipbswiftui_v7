//
//  RadioButtonView.swift
//
//
//  Created by Artemy Volkov on 02.10.2023.
//

import SwiftUI

public struct RadioButtonView: View {
    
    let isSelected: Bool
    
    public init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    public var body: some View {
        ZStack {
            if isSelected {
                selectedOptionView
            } else {
                unselectedOptionView
            }
        }
        .frame(width: 24, height: 24)
        .animation(.default, value: isSelected)
    }
    
    private var unselectedOptionView: some View {
        Circle()
            .stroke(lineWidth: 2)
            .frame(width: 16)
            .foregroundStyle(Style.iconsDisabled)
    }
    
    private var selectedOptionView: some View {
        Circle()
            .stroke(lineWidth: 2)
            .frame(width: 16)
            .gradientColor(gradient: Style.primary)
            .overlay {
                Circle()
                    .frame(width: 10)
                    .gradientColor(gradient: Style.primary)
            }
    }
}
