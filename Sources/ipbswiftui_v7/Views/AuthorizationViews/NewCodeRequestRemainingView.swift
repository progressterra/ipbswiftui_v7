//
//  NewCodeRequestRemainingView.swift
//  
//
//  Created by Artemy Volkov on 11.08.2023.
//

import SwiftUI

/// `NewCodeRequestRemainingView` displays a countdown timer or a button to request a new code, depending on the time remaining.
///
/// This view is typically used in screens involving verification processes where users need to enter a code sent via SMS or other means. It shows a countdown timer until it reaches zero, after which it displays a button allowing users to request another code if needed.
///
/// ## Functionality
/// - Shows a countdown timer until the time expires.
/// - Provides a button to request a new verification code once the timer expires.
/// - Uses a repeating timer to update the countdown every second.
///
/// ## Usage
///
/// You can integrate this view into any verification screen where a timed code entry is required. Here's an example of how to use it:
///
/// ```swift
/// NewCodeRequestRemainingView(
///     timeRemaining: $viewModel.timeRemaining,
///     requestNewCodeAction: viewModel.requestNewCode
/// )
/// ```
///
/// ## Parameters
/// - `timeRemaining`: A binding to an integer that decrements every second to zero, triggering a state change in the view.
/// - `requestNewCodeAction`: An action to execute when the time has expired and the user taps the "Request new code" button.
///
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
        .foregroundStyle(Style.textDisabled)
        .animation(.default, value: timeRemaining != 0)
    }
    
    private func formattedTime(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
