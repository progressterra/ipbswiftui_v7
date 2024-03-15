//
//  CodeInputFieldView.swift
//
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

public struct CodeInputFieldView: View {
    @Binding var codeString: String
    let phoneNumber: String
    
    @FocusState private var isFocused: Bool
    @State private var isPlaceholderShowing: [Bool] = Array(repeating: false, count: 4)
    @State private var displayedPhoneNumber: String = ""
    
    public init(codeString: Binding<String>, phoneNumber: String) {
        self._codeString = codeString
        self.phoneNumber = phoneNumber
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Код из смс на номер:\n\(displayedPhoneNumber)")
                .multilineTextAlignment(.center)
                .foregroundStyle(Style.textSecondary)
                .font(Style.body)
                .modifier(PhoneNumberFormatterModifier(phoneNumber: .constant(phoneNumber), displayedPhoneNumber: $displayedPhoneNumber))
            
            HStack(spacing: 12) {
                ForEach(0..<4) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Style.background)
                            .frame(width: 56, height: 56)
                        
                        Text(index < codeString.count ? String(codeString[codeString.index(codeString.startIndex, offsetBy: index)]) : "")
                            .foregroundStyle(Style.textPrimary)
                            .font(Style.largeTitle)
                            .multilineTextAlignment(.center)
                            .frame(width: 56, height: 56)
                            .overlay {
                                if isFocused && index == codeString.count {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke()
                                        .foregroundStyle( Style.primary)
                                }
                            }
                    }
                }
            }
            
            TextField("", text: $codeString)
                .font(Style.largeTitle)
                .foregroundStyle(Style.textPrimary)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .opacity(0.01)
                .frame(width: 1, height: 1)
                .onChange(of: codeString) { newValue in
                    if newValue.count > 4 {
                        codeString = String(newValue.prefix(4))
                    }
                    for i in codeString.count..<4 {
                        isPlaceholderShowing[i] = false
                    }
                }
        }
        .onAppear {
            displayedPhoneNumber = phoneNumber
            isFocused = true
        }
        .onTapGesture {
            isFocused = true
        }
        .animation(.default, value: isFocused)
        .animation(.default, value: isPlaceholderShowing)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Style.surface)
        .cornerRadius(12)
    }
}
