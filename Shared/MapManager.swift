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
        maps.updateValue(MapBuilder.instance.make(type: .Ground, fill: true), forKey: .Ground)
        maps.updateValue(MapBuilder.instance.make(type: .Buildings, fill: false), forKey: .Buildings)
        maps.updateValue(MapBuilder.instance.make(type: .District, fill: false), forKey: .District)
        maps.updateValue(MapBuilder.instance.make(type: .InBuildMode, fill: false), forKey: .InBuildMode)
    }
    
    func expand(mapType: MapType) {
        if mapType == .Ground {
            MapBuilder.instance.expandWithFill(map: maps[mapType]!, type: mapType)
            
        } else {
            MapBuilder.instance.expand(map: maps[mapType]!, type: mapType)
        }
    }
    
    func add(building: BuildableUnit, location: CGPoint) {
        guard !building.areConditionsViolated() else {
            print("Building can't be placed due to violated conditions.")
            return
        }
        
        // Update tile.
        maps[.Buildings]!.setTileGroup(building.visuals![2], forColumn: building.column, row: building.row)
        
        if let tower = building as? Tower {
            print("Building to be placed is a tower.")
            
            towers.append(tower)
            let map = maps[.Buildings]!
            tower.rangeImage.position = map.centerOfTile(atColumn: tower.column, row: tower.row)
            map.addChild(tower.rangeImage)
        }
        
        // TODO
        // Insert additional checks for other building-categories.
    }
}
