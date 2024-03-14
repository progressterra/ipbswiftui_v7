//
//  QuantityPicker.swift
//
//
//  Created by Artemy Volkov on 13.03.2024.
//

import SwiftUI

public struct QuantityPicker: View {
    
    @Binding var currentQuantity: Int
    let decreaseAction: () -> ()
    let increaseAction: () -> ()
    
    public init(currentQuantity: Binding<Int>, decreaseAction: @escaping () -> (), increaseAction: @escaping () -> ()) {
        self._currentQuantity = currentQuantity
        self.decreaseAction = decreaseAction
        self.increaseAction = increaseAction
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            Button(action: decreaseItemQuantity) {
                Image(systemName: "minus")
                    .font(.system(size: 10))
                    .frame(width: 24, height: 24)
                    .background(Style.iconsSecondary)
                    .clipShape(Circle())
            }
            
            Text(currentQuantity.formatted())
                .frame(width: 28, height: 28)
                .background(Style.iconsSecondary)
                .clipShape(Circle())
            
            Button(action: increaseItemQuantity) {
                Image(systemName: "plus")
                    .font(.system(size: 10))
                    .frame(width: 24, height: 24)
                    .background(Style.iconsSecondary)
                    .clipShape(Circle())
            }
        }
        .foregroundColor(Style.textPrimary)
        .font(Style.footnoteRegular)
    }
    
    private func decreaseItemQuantity() {
        if currentQuantity > 0 {
            currentQuantity -= 1
            decreaseAction()
        } else {
            currentQuantity = 0
        }
    }
    
    private func increaseItemQuantity() {
        currentQuantity += 1
        increaseAction()
    }
}
