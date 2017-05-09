//
//  BuildMenuView.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 21.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class BuildMenuView: SKNode, BuildingCallback {
    
    // MARK: - Variables.
    
    var buildings = [BuildableUnitCategories: BuildableUnit]()
    var currentlySelected: BuildableUnit?
    
    // MARK: - Initializers.
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods.
    
    func add(key: BuildableUnitCategories, value: BuildableUnit) {
        
        //var array = [BuildableUnit: SKSpriteNode]()
        //let sprite = makeNode(unit: value)
        //array.updateValue(sprite, forKey: value)
        
        //self.addChild(sprite)
        addChild(SKSpriteNode(fileNamed: value.visuals?.first!.name ?? "Non-Buildable")!)
        buildings.updateValue(value, forKey: key)
    }
    
    func select(key: BuildableUnitCategories, value: BuildableUnit) {
        // Animation only.
        // Applies to both selecting as well as de-selecting a building-type.
        
        // 1. Animate de-selection.
        // ...
        
        // 2. Animate new selection.
        //childNode(withName: value.visuals?.first!.name ?? "Non-Buildable")!.run(SKAction)
        
        /*
        for (_, array) in buildings {
            for unit in array.keys {
                if unit === value {
                    //let sprite = array[unit]! select animation
                    //currentlySelected = sprite
                    return
                }
            }
        }*/
        
        // If this point has been reached, no entity from the building-menu matches. Exit with error.
        track(.E, "No stored unit matches the given one, it may have been delteted before", self)
        abort()
    }

    fileprivate func makeNode(unit: BuildableUnit) -> SKSpriteNode {
        return SKSpriteNode(imageNamed: "\(unit.category)")
    }
}
