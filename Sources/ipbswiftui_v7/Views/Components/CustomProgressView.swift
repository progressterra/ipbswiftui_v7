//
//  CustomProgressView.swift
//  
//
//  Created by Artemy Volkov on 29.08.2023.
//

import SwiftUI

public struct CustomProgressView: View {
    let isLoading: Bool
    
    public init(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    public var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .transition(.opacity)
            } else {
                Color.clear
                    .transition(.opacity)
            }
        }
        .animation(.default, value: isLoading)
    }
}
