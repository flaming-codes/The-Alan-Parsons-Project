//
//  MapBuilder.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 21.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

struct MapBuilder {
    
    let defaultGroundSet: SKTileSet
    let defaultBuildingSet: SKTileSet
    let defaultDistrictSet: SKTileSet
    let defaultInBuildModeSet: SKTileSet
    
    let defaultColumns = 14
    let defaultRows = 14
    
    let zGround: CGFloat = 0
    let zDistricts: CGFloat = 1
    let zBuildings: CGFloat = 2
    let zInBuildMode: CGFloat = 3
    
    static let instance: MapBuilder = {
        return MapBuilder()
    }()
    
    private init(){
        defaultGroundSet = SKTileSet(named: "Ground Map")!
        
        // TODO Create tiles to initialize sets correctly.
        defaultDistrictSet = SKTileSet(named: "Ground Map")!
        defaultBuildingSet = SKTileSet(named: "Ground Map")!
        defaultInBuildModeSet = SKTileSet(named: "Ground Map")!
    }
    
    func make(with tileSet: SKTileSet, columns: Int, rows: Int) -> SKTileMapNode {
        let map = SKTileMapNode(
            tileSet: tileSet,
            columns: columns,
            rows: rows,
            tileSize: tileSet.defaultTileSize,
            fillWith: tileSet.tileGroups.first!)
        
        map.anchorPoint = CGPoint(x: 0, y: 0.5)
        return map
    }
    
    func makeGround() -> SKTileMapNode {
        let map = self.make(with: defaultGroundSet, columns: defaultColumns, rows: defaultRows)
        map.zPosition = zGround
        
        return map
    }
    
    func makeBuldings() -> SKTileMapNode {
        let map = self.make(with: defaultBuildingSet, columns: defaultColumns, rows: defaultRows)
        map.zPosition = zBuildings
        
        return map
    }
    
    func makeInBuildMode() -> SKTileMapNode {
        let map = self.make(with: defaultInBuildModeSet, columns: defaultColumns, rows: defaultRows)
        map.zPosition = zInBuildMode
        
        return map
    }
    
    func makeDistricts() -> SKTileMapNode {
        let map = self.make(with: defaultDistrictSet, columns: defaultColumns, rows: defaultRows)
        map.zPosition = zDistricts
        
        return map
    }
    
    // Works! (Passes by reference)
    func expand(map: SKTileMapNode) {
        map.numberOfColumns += defaultColumns
    }
    
    func expandWithFill(map: SKTileMapNode) {
        let startColumn = map.numberOfColumns
        
        self.expand(map: map)
        
        let groups = defaultGroundSet.tileGroups
        let groupsSize = UInt32(groups.count)
        
        for x in startColumn...startColumn + defaultColumns {
            for y in 0...defaultRows {
                
                // arc4random_uniform(x) == From 0 to x-1
                map.setTileGroup(groups[Int(arc4random_uniform(groupsSize))], forColumn: x, row: y)
            }
        }
    }
    
    func updateTile(map: SKTileMapNode, point: CGPoint, type: MapManager.MapType, tile: SKTileGroup) -> Bool {
        let column = map.tileColumnIndex(fromPosition: point)
        let row = map.tileRowIndex(fromPosition: point)
        
        print("Update tile called.")
        print("Columnn touched: \(column).")
        print("Row touched: \(row).")
        print("TileGroup: \(tile.name ?? "Tile to set has no name.")")
        
        switch type {
        case .Ground:
            map.setTileGroup(tile, forColumn: column, row: row)
            return true
            
        default:
            return false
        }

    }
}
