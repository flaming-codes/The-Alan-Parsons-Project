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
    
    let defaultColumns = 8
    let defaultRows = 8
    
    let zGround: CGFloat = 0
    let zDistricts: CGFloat = 1
    let zBuildings: CGFloat = 2
    let zInBuildMode: CGFloat = 3
    
    static let instance: MapBuilder = {
        return MapBuilder()
    }()
    
    private init(){
        defaultGroundSet = SKTileSet(named: "Sample Hexagonal Tile Set")!
        
        // TODO Create tiles to initialize sets correctly.
        defaultDistrictSet = SKTileSet()
        defaultBuildingSet = SKTileSet()
        defaultInBuildModeSet = SKTileSet()
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
    
    func makeInBuldMode() -> SKTileMapNode {
        let map = self.make(with: defaultInBuildModeSet, columns: defaultColumns, rows: defaultRows)
        map.zPosition = zInBuildMode
        
        return map
    }
    
    func makeDistricts() -> SKTileMapNode {
        let map = self.make(with: defaultDistrictSet, columns: defaultColumns, rows: defaultRows)
        map.zPosition = zDistricts
        
        return map
    }
    
    // Works!
    func expandMap(map: SKTileMapNode) {
        map.numberOfColumns += map.numberOfColumns + defaultColumns
    }
}
