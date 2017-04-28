//
//  File.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class MapManager {
    
    // MARK: - Variables.
    
    enum MapType {
        case Ground
        case District
        case Buildings
        case InBuildMode
    }
    
    var maps: [MapType:SKTileMapNode] = [:]
    var towers = [Tower]()
    var economyBuildings = [Building]()
    
    // TODO Rethink implementation - Maybe a 'SelectionManager' fits better.
    // Cache for user's current selection - a build unit from the build menu.
    var buildingSelected: BuildableUnit?
    
    // Singleton instance
    static let instance: MapManager = {
        let instance = MapManager()
        return instance
    }()
    
    // MARK: - Methods.
    
    private init() {
        maps.updateValue(MapBuilder.instance.makeGround(), forKey: .Ground)
    }
    
    func expandGroundMap() {
        MapBuilder.instance.expandWithFill(map: maps[.Ground]!)
    }
}
