//
//  CustomButtonView.swift
//  
//
//  Created by Artemy Volkov on 24.07.2023.
//

import SwiftUI

public struct CustomButtonView: View {
    let title: String
    @Binding var isDisabled: Bool
    let isOpaque: Bool
    let action: () -> ()
    
    public init(
        title: String,
        isDisabled: Binding<Bool> = .constant(false),
        isOpaque: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self._isDisabled = isDisabled
        self.isOpaque = isOpaque
        self.action = action
    }
    
    public var body: some View {
        Button(action: { if !isDisabled { action() } }) {
            Text(title)
                .foregroundStyle( gradient)
                .font(Style.headline)
                .bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(height: Style.buttonHeight)
                .background(background)
                .cornerRadius(Style.buttonCornerRadius)
                .overlay {
                    if isOpaque {
                        RoundedRectangle(cornerRadius: Style.buttonCornerRadius)
                            .stroke(lineWidth: 2)
                            .foregroundStyle( Style.primary)
                    }
                }
        }
        .buttonStyle(ButtonPressEffectStyle())
    }
    
    var gradient: LinearGradient {
        if isOpaque {
            return Style.primary
        } else {
            return LinearGradient(
             colors: [isDisabled ? Style.textDisabled : Style.textButtonPrimary],
             startPoint: .center,
             endPoint: .center
            )
        }
    }
    
    var background: some View {
        ZStack {
            if !isDisabled {
                isOpaque
                ? LinearGradient(colors: [.clear],
                                 startPoint: .center,
                                 endPoint: .center)
                : Style.primary
            } else {
                isOpaque
                ? .clear
                : Style.primaryDisabled
            }
        }
    }
}

struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(title: "Button", isDisabled: .constant(false), isOpaque: false, action: { print("button tapped") })
            .padding()
    }
}
