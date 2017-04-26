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
            return SKSpriteNode(imageNamed: "Farm_Hex")
        case .Combat:
            return SKSpriteNode(imageNamed: "Grass_Hex")
        case .Miscellaneous:
            return SKSpriteNode(imageNamed: "Mountain_Hex")
        }
    }
}
