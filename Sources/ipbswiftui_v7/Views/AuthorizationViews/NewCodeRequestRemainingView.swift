//
//  NewCodeRequestRemainingView.swift
//  
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

public struct NewCodeRequestRemainingView: View {
    @Binding var timeRemaining: Int
    let requestNewCodeAction: () -> ()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(timeRemaining: Binding<Int>, requestNewCodeAction: @escaping () -> ()) {
        self._timeRemaining = timeRemaining
        self.requestNewCodeAction = requestNewCodeAction
    }
    
    public var body: some View {
        ZStack {
            if timeRemaining != 0 {
                Text("\(formattedTime(time: timeRemaining))")
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
                    .transition(.opacity)
                    .monospacedDigit()
            } else {
                Button(action: requestNewCodeAction) {
                    Text("Запросить новый код")
                }
                .transition(.push(from: .bottom))
            }
        }
        .font(Style.headline)
        .foregroundColor(Style.textDisabled)
        .animation(.default, value: timeRemaining != 0)
    }
    
    private func formattedTime(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
