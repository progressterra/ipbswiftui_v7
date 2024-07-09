//
//  DeliveryOptionProtocol.swift
//  
//
//  Created by Artemy Volkov on 17.04.2024.
//

import Foundation

/// Protocol defining delivery options with associated image and description.
public protocol DeliveryOptionProtocol: CaseIterable, Hashable {
    var description: String { get }
    var imageName: String { get }
}
