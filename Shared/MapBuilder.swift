//
//  MapBuilder.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 21.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit
import GameplayKit

struct MapBuilder {
    
    // MARK: - Variables.
    
    var tileSets = [MapType : SKTileSet]()
    var zPositions = [MapType : CGFloat]()
    
    let defaultColumns = 14
    let defaultRows = 14
    let defaultDistrictHeightInRows = 7
    let defaultDistrictLengthInColumns = 7
    
    static let instance: MapBuilder = {
        return MapBuilder()
    }()
    
    // MARK: - Methods.
    
    private init(){
        
        // TODO Create tiles to initialize sets correctly.
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .Ground)
        tileSets.updateValue(SKTileSet(named: "Way Big Hexagonal Flat Tile Set")!, forKey: .Way)
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .Buildings)
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .District)
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .InBuildMode)
        
        zPositions.updateValue(0, forKey: .Ground)
        zPositions.updateValue(1, forKey: .Way)
        zPositions.updateValue(2, forKey: .Buildings)
        zPositions.updateValue(3, forKey: .District)
        zPositions.updateValue(4, forKey: .InBuildMode)
    }
    
    func make(with tileSet: SKTileSet, columns: Int, rows: Int, fill: Bool) -> SKTileMapNode {
        var map: SKTileMapNode
        
        map = fill ? SKTileMapNode(
            tileSet: tileSet,
            columns: columns,
            rows: rows,
            tileSize: tileSet.defaultTileSize,
            fillWith: tileSet.tileGroups.first!)
            : SKTileMapNode(
                tileSet: tileSet,
                columns: columns,
                rows: rows,
                tileSize: tileSet.defaultTileSize)
        
        map.anchorPoint = CGPoint(x: 0, y: 0.5)
        return map
    }
    
    func make(type: MapType, fill: Bool) -> SKTileMapNode {
        guard tileSets[type] != nil else {
            track(.F, "TileSet not set, no tiles to choose from.", self)
            abort()
        }
        
        let map = self.make(with: tileSets[type]!, columns: defaultColumns, rows: defaultRows, fill: fill)
        map.zPosition = zPositions[type]!
        map.name = "\(type) map"
        
        return map
    }
    
    // Works! (Passes by reference)
    func expand(map: SKTileMapNode, type: MapType) {
        map.numberOfColumns += defaultColumns
    }
    
    func expandWithFill(map: SKTileMapNode, type: MapType) {
        let startColumn = map.numberOfColumns
        
        self.expand(map: map, type: type)
        
        let groups = tileSets[type]!.tileGroups
        let groupsSize = UInt32(groups.count)
        
        for x in startColumn...startColumn + defaultColumns {
            for y in 0...defaultRows {
                
                // arc4random_uniform(x) == From 0 to x-1
                map.setTileGroup(groups[Int(arc4random_uniform(groupsSize))], forColumn: x, row: y)
            }
        }
    }
}
