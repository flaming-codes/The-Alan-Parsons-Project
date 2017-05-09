//
//  Building.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class Building : BuildableUnit {
    
    // MARK: - Variables.
    
    let name: String!
    let level: Int
    
    override var hashValue: Int {
        get {
            return "\(self.column),\(self.row),\(self.name),\(self.level)".hashValue
        }
    }
    
    init(column: Int, row: Int, name: String, category: BuildableUnitCategories, level: Int, initalResourcesRequired: [Resources : Double]) {
        guard !name.isEmpty && level >= 0 else {
            print("ERROR @ Building : init() : name isn't allowed to be empty.")
            abort()
        }
        
        self.name = name
        self.level = level
        
        super.init(column: column, row: row, initalResourcesRequired: initalResourcesRequired, category: category)
    }
}
