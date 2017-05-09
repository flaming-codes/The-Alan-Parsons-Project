//
//  Monster.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 16.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class Monster: SKSpriteNode {
    
    // MARK: - Variables.
    
    let hp: Double
    var hpNow: Double
    let damageToWall: Int
    let damageToPlayer: Int
    let armor: Int
    var resistances: [DamageType: Double]?
    
    // MARK: - Initializers.
    
    init(texture: SKTexture!, color: SKColor, size: CGSize, hp: Double, damageToWall: Int, damageToPlayer: Int, armor: Int, res: [DamageType: Double]? = nil) {
        self.hp = hp
        self.hpNow = hp
        self.damageToWall = damageToWall
        self.damageToPlayer = damageToPlayer
        self.armor = armor
        resistances = res
        
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods.
}

// MARK: Hashable methods.
/*
 var hashValue: Int {
 return "hash-values".hashValue
 }
 
 static func == (lhs: Monster, rhs: Monster) -> Bool {
 return lhs.hashValue == rhs.hashValue
 }
 */
// REMINDER
// Monster has to use a zPosition above all or at least above buildings + ranges.

