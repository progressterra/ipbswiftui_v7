//
//  HapticUtility.swift
//  
//
//  Created by Artemy Volkov on 12.09.2023.
//

import UIKit

public struct HapticUtility {
    public init() {}

    public static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    public static func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
