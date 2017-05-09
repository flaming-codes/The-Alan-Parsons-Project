//
//  BuildableUnitCategories.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 16.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

/// Represents the top-level categories of buildable units avaialable.
enum BuildableUnitCategories : Hashable, Mapping {
    
    // MARK: - Enum' cases.
    
    case Economy
    case Combat
    case Civil
    case Miscellaneous
    
    // Mark: - Variables.
    
    internal typealias A = BuildableUnitCategories
    internal typealias B = SKSpriteNode
    
    // MARK: - Functions.
    
    @available(*, deprecated)
    static func map(a: BuildableUnitCategories) -> SKSpriteNode {
        print("Mapping function called.")
        
        switch a {
        case .Economy:
            return SKSpriteNode(imageNamed: "Grass")
        case .Combat:
            return SKSpriteNode(imageNamed: "Mountain")
        case .Miscellaneous:
            return SKSpriteNode(imageNamed: "Lake")
        default:
            track(.I, "Default called. Returning empty sprite", self)
            return SKSpriteNode()
        }
    }
}
