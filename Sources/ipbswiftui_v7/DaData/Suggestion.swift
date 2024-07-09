//
//  Suggestion.swift
//  
//
//  Created by Artemy Volkov on 08.04.2024.
//

import Foundation

/// Represents a single address suggestion with a `value` property containing the suggested address as a string.
public struct Suggestion: Codable, Hashable {
    public let value: String
}
