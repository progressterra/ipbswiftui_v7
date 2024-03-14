//
//  CustomTextFieldView.swift
//  
//
//  Created by Artemy Volkov on 27.07.2023.
//

import SwiftUI

public struct CustomTextFieldView: View {
    @Binding var text: String
    let prompt: String
    let backgroundColor: Color
    let isSecured: Bool
    let axis: Axis
    
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        prompt: String,
        backgroundColor: Color = Style.surface,
        isSecured: Bool = false,
        axis: Axis = .horizontal
    ) {
        self._text = text
        self.prompt = prompt
        self.backgroundColor = backgroundColor
        self.isSecured = isSecured
        self.axis = axis
    }
    
    public var body: some View {
        VStack(spacing: 2) {
            if !text.isEmpty {
                Text(prompt)
                    .font(Style.captionBold)
                    .foregroundColor(Style.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.push(from: .bottom))
            }
            
            ZStack {
                if isSecured {
                    SecureField(text: $text) {
                        Text(prompt)
                            .foregroundColor(Style.textDisabled)
                    }
                } else {
                    TextField(text: $text, axis: axis) {
                        Text(prompt)
                            .foregroundColor(Style.textDisabled)
                    }
                }
            }
            .foregroundColor(Style.textPrimary)
            .focused($isFocused)
        }
        .frame(minHeight: 46)
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
        .padding(.trailing)
        .background(backgroundColor)
        .font(Style.body)
        .cornerRadius(8)
        .overlay {
            if isFocused {
                RoundedRectangle(cornerRadius: 8)
                    .stroke()
                    .gradientColor(gradient: Style.primary)
            }
        }
        .overlay(alignment: .trailing) {
            if !text.isEmpty && isFocused && !isSecured {
                Button(action: { text = "" }) {
                    Image("xmark", bundle: .module)
                        .foregroundColor(Style.iconsPrimary)
                        .transition(.slide.combined(with: .scale))
                }
                .padding(.trailing, 8)
            } else {
                
            }
        }
        .animation(.default, value: isFocused)
        .animation(.default, value: text)
    }
}

struct CustomTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Style.background.ignoresSafeArea()
            
            CustomTextFieldView(text: .constant("test"), prompt: "test")
        }
    }
}
