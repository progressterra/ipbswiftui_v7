//
//  BonusesToggleView.swift
//
//
//  Created by Artemy Volkov on 18.08.2023.
//

import SwiftUI

public struct BonusesToggleView: View {
    let availableBonuses: Double
    @Binding var isBonusesApplied: Bool
    
    public init(availableBonuses: Double, isBonusesApplied: Binding<Bool>) {
        self.availableBonuses = availableBonuses
        self._isBonusesApplied = isBonusesApplied
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Использовать бонусы")
                .font(Style.title)
                .foregroundStyle(Style.textPrimary)
            
            HStack {
                Text("\(availableBonuses.clean) Б")
                    .font(Style.body)
                    .foregroundStyle(Style.textTertiary)
                Spacer()
                CustomToggleView(isOn: $isBonusesApplied)
            }
        }
        .padding(12)
        .background(Style.surface)
        .cornerRadius(12)
    }
}
