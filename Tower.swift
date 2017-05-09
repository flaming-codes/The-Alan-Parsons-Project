//
//  Tower.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class Tower : Building {
    
    let range: CGFloat
    let rangeImage: SKShapeNode
    var originOfRange: CGPoint
    let coolDownTimeInMillis: TimeInterval!
    let type: TowerBuilder.TowerType
    var isFireable = true
    var spawnTimer = Timer()
    
    init(column: Int, row: Int, type: TowerBuilder.TowerType, name: String, rangeImage: SKShapeNode, originOfRange: CGPoint, level: Int, coolDownTimeInMillis: TimeInterval, initalResourcesRequired: [Resources : Double]) {
        
        self.coolDownTimeInMillis = coolDownTimeInMillis
        self.type = type
        self.range = rangeImage.frame.height / 2
        self.rangeImage = rangeImage
        self.originOfRange = originOfRange
        
        super.init(column: column, row: row, name: name, category: .Combat, level: level, initalResourcesRequired: initalResourcesRequired)
    }
}
