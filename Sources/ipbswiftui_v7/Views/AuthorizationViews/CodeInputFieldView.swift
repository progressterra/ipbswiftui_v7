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

    @FocusState private var focusedField: Int?
    @State private var partials = Array(repeating: "", count: 4)
    @State private var isPlaceHolderShowing: [Bool] = Array(repeating: false, count: 4)
    @State private var displayedPhoneNumber: String = ""

    public init(codeString: Binding<String>, phoneNumber: String) {
        self._codeString = codeString
        self.phoneNumber = phoneNumber
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Код из смс на номер:\n\(displayedPhoneNumber)")
                .multilineTextAlignment(.center)
                .foregroundColor(Style.textSecondary)
                .font(Style.body)
                .modifier(PhoneNumberFormatterModifier(phoneNumber: .constant(phoneNumber), displayedPhoneNumber: $displayedPhoneNumber))

            HStack(spacing: 12) {
                ForEach(0..<4) { index in
                    TextField("", text: $partials[index])
                        .font(Style.largeTitle)
                        .onChange(of: partials[index]) { newValue in
                            handleInputChange(newValue, at: index)
                        }
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Style.textPrimary)
                        .frame(width: 56, height: 56)
                        .background(Style.background)
                        .cornerRadius(8)
                        .overlay {
                            if !isPlaceHolderShowing[index] {
                                ZStack {
                                    Style.background
                                    Circle()
                                        .foregroundColor(Style.textDisabled)
                                        .frame(height: 5)
                                }
                                .cornerRadius(8)
                                .transition(.opacity)
                            }
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke()
                                .gradientColor(gradient: Style.primary)
                                .opacity(focusedField == index ? 1 : 0)
                        }
                        .textContentType(.oneTimeCode)
                        .focused($focusedField, equals: index)
                        .onTapGesture { focusedField = index }
                        .animation(.default, value: focusedField)
                        .animation(.default, value: isPlaceHolderShowing)
                }
                .onAppear { focusedField = 0 }
            }
        }
        .onTapGesture { focusedField = nil }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Style.surface)
        .cornerRadius(12)
    }

    private func handleInputChange(_ newValue: String, at index: Int) {
        let truncatedValue = String(newValue.prefix(1))
        partials[index] = truncatedValue

        if truncatedValue.isEmpty {
            handleDeletion(at: index)
        } else if let lastChar = truncatedValue.last, lastChar.isNumber {
            handleNumberInput(lastChar, at: index)
        } else {
            partials[index] = ""
        }
    }

    private func handleDeletion(at index: Int) {
        if index > 0 && focusedField != 0 {
            focusedField = index - 1
        }
        if index < codeString.count {
            codeString.remove(at: codeString.index(codeString.startIndex, offsetBy: index))
        }
        isPlaceHolderShowing[index] = false
    }

    private func handleNumberInput(_ character: Character, at index: Int) {
        if codeString.count > index {
            let startIndex = codeString.index(codeString.startIndex, offsetBy: index)
            codeString.replaceSubrange(startIndex...startIndex, with: String(character))
        } else {
            codeString.append(character)
        }

        isPlaceHolderShowing[index] = true
        if index < partials.count - 1 {
            focusedField = index + 1
        }
    }
}
