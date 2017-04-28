//
//  BuildMenuManager.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class BuildMenuManager {
    
    static let sharedInstance: BuildMenuManager = {
        let instance = BuildMenuManager()
        // Some setup-code if nedded.
        return instance
    }()
    
    // MARK: Variables.
    
    // Dictonary with key as a building and value if the building is allowed to be build.
    var topLevelEntries = [BuildableUnitCategories : [BuildableUnit : Bool]]()
    var mainEntries = [BuildableUnit : Bool]()
    
    // MARK: Methods.
    
    private init(){}
    
}
