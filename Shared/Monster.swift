//
//  Monster.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 16.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

class Monster : Hashable {
    
    var name: String?
    
    var hashValue: Int {
        return "hash-values".hashValue
    }
    
    static func == (lhs: Monster, rhs: Monster) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    // REMINDER
    // Monster has to use a zPosition above all or at least above buildings + ranges.
}
