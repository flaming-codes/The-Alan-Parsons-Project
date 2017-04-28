//
//  Tower.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class Tower : Building {
    
    let coolDownTimeInMillis: Int!
    let type: TowerBuilder.TowerType
    var isFireable = true
    
    init(column: Int, row: Int, type: TowerBuilder.TowerType, name: String, rangeImage: SKShapeNode, originOfRange: CGPoint, level: Int, coolDownTimeInMillis: Int, initalResourcesRequired: [Resources : Double]) {
        
        self.coolDownTimeInMillis = coolDownTimeInMillis
        self.type = type
        
        super.init(column: column, row: row, name: name, category: .Combat, rangeImage: rangeImage, originOfRange: originOfRange, level: level, initalResourcesRequired: initalResourcesRequired)
    }
}
