//
//  HapticUtility.swift
//
//
//  Created by Artemy Volkov on 12.09.2023.
//

import UIKit

/// A utility struct for generating haptic feedback.
///
/// This struct provides static methods to easily trigger different types of haptic feedback including notifications, impacts, and selection changes.
public struct HapticUtility {
    
    public init() {}
    
    /// Generates a notification feedback.
    ///
    /// This method triggers a predefined haptic feedback pattern intended to communicate successes, failures, and warnings.
    ///
    /// - Parameter type: The type of notification feedback to be generated, defined in `UINotificationFeedbackGenerator.FeedbackType`.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// HapticUtility.notification(type: .success)
    /// ```
    public static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    /// Generates an impact feedback.
    ///
    /// This method triggers a physical thud, simulating the impact between UI elements. It's useful for enhancing UI actions such as snapping, collisions, or UI controls that slide into place.
    ///
    /// - Parameter style: The style of the impact feedback, defined in `UIImpactFeedbackGenerator.FeedbackStyle`. The default value is `.medium`.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// HapticUtility.impact(style: .heavy)
    /// ```
    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    /// Generates a selection feedback.
    ///
    /// This method is intended to simulate the feeling of a mechanical switch, useful in contexts such as adjusting sliders, switching settings, or changing options.
    ///
    /// **Usage Example:**
    ///
    /// ```swift
    /// HapticUtility.selectionChanged()
    /// ```
    public static func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
