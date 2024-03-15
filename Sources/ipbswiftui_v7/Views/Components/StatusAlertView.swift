//
//  StatusAlertView.swift
//
//
//  Created by Artemy Volkov on 31.08.2023.
//

import SwiftUI

public struct StatusAlertView: View {
    @Binding var status: String?
    let onDisappear: () -> ()
    
    private let bouncyAnimation = Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)
    
    public init(status: Binding<String?>, onDisappear: @escaping () -> Void) {
        self._status = status
        self.onDisappear = onDisappear
    }
    
    public var body: some View {
        if let status {
            Text(status)
                .padding()
                .foregroundStyle(Style.textButtonPrimary)
                .font(Style.headline)
                .background(Style.primary)
                .cornerRadius(8)
                .shadow(radius: 10)
                .multilineTextAlignment(.center)
                .transition(.scale.combined(with: .opacity).animation(bouncyAnimation))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.status = nil
                            onDisappear()
                        }
                    }
                }
        }
    }
}
