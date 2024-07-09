//
//  StatusAlertView.swift
//
//
//  Created by Artemy Volkov on 31.08.2023.
//

import SwiftUI

/// A view for displaying status messages with a fade-out animation.
///
/// `StatusAlertView` shows a temporary status message overlay that disappears after 3 seconds. It's typically used to provide feedback to users after an action, such as a successful save or error message. The view animates both its appearance and disappearance with a bouncy spring effect and fades out.
///
/// ## Example
/// Here's an example of how you can use `StatusAlertView` within a SwiftUI view:
///
/// ```swift
/// struct ContentView: View {
///     @State private var statusMessage: String?
///
///     var body: some View {
///         ZStack {
///             Button("Show Success Message") {
///                 statusMessage = "Operation Successful"
///             }
///             StatusAlertView(status: $statusMessage) {
///                 // Action to perform when the alert disappears
///                 print("Alert has been dismissed")
///             }
///         }
///     }
/// }
/// ```
///
/// ## Parameters
/// - `status`: A binding to an optional `String` that holds the current status message to display. The alert view appears if `status` is non-nil.
/// - `onDisappear`: A closure that is called when the alert view is about to disappear. This can be used to perform any cleanup or follow-up actions.
///
public struct StatusAlertView: View {
    @Binding var status: String?
    let onDisappear: () -> ()
    
    private let bouncyAnimation = Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)
    
    public init(status: Binding<String?>,  onDisappear: @escaping () -> Void) {
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
