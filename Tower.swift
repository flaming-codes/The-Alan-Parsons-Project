//
//  Tower.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class Tower : Building {
    
    var monstersInRangeQueue = [Monster]()
    let coolDownTimeInMillis: Int!
    
    init(column: Int, row: Int, name: String, range: Int, rangeImage: SKShapeNode, originOfRange: CGPoint, level: Int, coolDownTimeInMillis: Int, initalResourcesRequired: [Resources : Double]) {
        
        self.coolDownTimeInMillis = coolDownTimeInMillis
        
        super.init(column: column, row: row, name: name, category: .Combat, range: range, rangeImage: rangeImage, originOfRange: originOfRange, level: level, initalResourcesRequired: initalResourcesRequired)
    }
}
