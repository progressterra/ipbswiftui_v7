//
//  View + Extension.swift
//  
//
//  Created by Artemy Volkov on 19.07.2023.
//

import SwiftUI

public struct SafeAreaPadding: ViewModifier {
    public let edge: VerticalEdge
    public let value: CGFloat
    
    public init(edge: VerticalEdge, value: CGFloat) {
        self.edge = edge
        self.value = value
    }
    
    public func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: edge) {
                EmptyView().frame(height: value)
            }
    }
}

public extension View {
    /// Padding for safe area to extend size
    /// * Default value is 65 for bottom edge
    func safeAreaPadding(edge: VerticalEdge = .bottom, value: CGFloat = 65) -> some View {
        modifier(SafeAreaPadding(edge: edge, value: value))
    }
}

struct GradientModifier: ViewModifier {
    var gradient: LinearGradient

    func body(content: Content) -> some View {
        content
            .foregroundColor(.clear)
            .background(gradient)
            .mask(content)
    }
}

public extension View {
    func gradientColor(gradient: LinearGradient) -> some View {
        modifier(GradientModifier(gradient: gradient))
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

public extension View {
    func hideKeyboard() {
        UIApplication.shared.hideKeyboard()
    }
}
