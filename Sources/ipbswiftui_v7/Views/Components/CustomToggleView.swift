//
//  CustomToggleView.swift
//  
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct CustomToggleView: View {
    
    @Binding var isOn: Bool
    
    @Namespace private var animation
    
    public init(isOn: Binding<Bool>) {
        self._isOn = isOn
    }
    
    public var body: some View {
        Capsule(style: .continuous)
            .frame(width: 36, height: 18)
            .foregroundStyle(Style.background)
            .overlay(alignment: .leading) {
                if !isOn {
                    Circle()
                        .padding(2)
                        .foregroundStyle(Style.textDisabled)
                        .matchedGeometryEffect(id: "Circle", in: animation)
                }
            }
            .overlay(alignment: .trailing) {
                if isOn {
                    Circle()
                        .padding(2)
                        .foregroundStyle( Style.primary)
                        .matchedGeometryEffect(id: "Circle", in: animation)
                }
            }
            .onTapGesture { isOn.toggle() }
            .animation(.default, value: isOn)
    }
}
