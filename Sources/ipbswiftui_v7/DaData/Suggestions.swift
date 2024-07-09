//
//  Suggestions.swift
//  
//
//  Created by Artemy Volkov on 08.04.2024.
//

import Foundation

/// A struct containing an array of `Suggestion`, each representing a possible match for the query.
public struct Suggestions: Codable, Hashable {
    public let suggestions: [Suggestion]
}
