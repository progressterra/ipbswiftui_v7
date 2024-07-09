//
//  DisplayOptionProtocol.swift
//
//
//  Created by Artemy Volkov on 17.04.2024.
//

import Foundation

/// Protocol for option picker view
public protocol DisplayOptionProtocol: Hashable, Equatable, CaseIterable {
    var rawValue: String { get }
}
