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
    
    enum TargetLineDirection {
        case North
        case South
        case East
        case West
    }
    
    // MARK: - Methods.
    
    private init(){
        
        // TODO Create tiles to initialize sets correctly.
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .Ground)
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .Buildings)
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .District)
        tileSets.updateValue(SKTileSet(named: "Ground Map")!, forKey: .InBuildMode)
        
        zPositions.updateValue(0, forKey: .Ground)
        zPositions.updateValue(1, forKey: .Buildings)
        zPositions.updateValue(2, forKey: .District)
        zPositions.updateValue(3, forKey: .InBuildMode)
    }
    
    func make(with tileSet: SKTileSet, columns: Int, rows: Int, fill: Bool) -> SKTileMapNode {
        var map: SKTileMapNode
        
        map = fill
            ?
                SKTileMapNode(
                    tileSet: tileSet,
                    columns: columns,
                    rows: rows,
                    tileSize: tileSet.defaultTileSize,
                    fillWith: tileSet.tileGroups.first!)
            :
            SKTileMapNode(
                tileSet: tileSet,
                columns: columns,
                rows: rows,
                tileSize: tileSet.defaultTileSize)
        
        map.anchorPoint = CGPoint(x: 0, y: 0.5)
        return map
    }
    
    func make(type: MapType, fill: Bool) -> SKTileMapNode {
        guard tileSets[type] != nil else {
            print("ERROR @ MapBuilder : make() : The map \(type) has already been made.")
            abort()
        }
        
        let map = self.make(with: tileSets[type]!, columns: defaultColumns, rows: defaultRows, fill: fill)
        map.zPosition = zPositions[type]!
        map.name = "\(type) map"
        
        return map
    }
    
    func createWay(map: SKTileMapNode, startingColumnIndex: Int, startingRowIndex: Int) {
        guard defaultRows % defaultDistrictHeightInRows == 0 && defaultColumns % defaultDistrictLengthInColumns == 0 else {
            print("FATAL ERROR @ MapBuilder : createWay() : Number of districts per height/length wrong.")
            abort()
        }
        
        var waypoints = [(row: Int, column: Int)]()
        var districtCount = 0
        
        // .numberOfColumns has to be reduced by 1, else the index would be out of bounds.
        let columnsProvided = map.numberOfColumns - 1 - startingColumnIndex
        let rowsProvided = map.numberOfRows - 1 - startingRowIndex
        let districtsToProcessCount = ((columnsProvided+1) / defaultDistrictLengthInColumns) * ((rowsProvided+1) / defaultDistrictHeightInRows)
        
        print("Columns provided: \(columnsProvided).")
        print("Rows provided: \(rowsProvided).")
        print("Districts to process: \(districtsToProcessCount).")
        
        waypoints.append((row: startingRowIndex, column: startingColumnIndex))
        
        while districtCount < /*districtsToProcessCount*/ 1 {
            print("districtCount: \(districtCount).")
            
            waypoints.append(contentsOf: createWaypointsForDistrict(startingColumnIndex: (waypoints.last?.column)!,
                                                                    startingRowIndex: (waypoints.last?.row)!,
                                                                    target: createTargetLine(districtIndex: districtCount)))
            districtCount += 1
        }
        
        for point in waypoints {
            map.setTileGroup(tileSets[.Ground]?.tileGroups[5], forColumn: point.column, row: point.row)
        }
    }

    // Currently only works for up/down/right targetLines.
    fileprivate func createTargetLine(districtIndex: Int) -> (targetLine: [(row: Int, column: Int)], direction: TargetLineDirection) {
        var targetLine = [(row: Int, column: Int)]()
        var direction: TargetLineDirection
        let districtsPerHeight = defaultRows / defaultDistrictHeightInRows
        let currentDistrictColumn: Int = Int(districtIndex / districtsPerHeight)
        
        print("createTargetLine() called.")
        
        // targetLine (except for last district in column) goes upward.
        if currentDistrictColumn % 2 == 0 {
            
            print("Even district column to be modified.")
            
            // Check if last element has been reached and apply special targetLine.
            if districtIndex % districtsPerHeight == districtsPerHeight - 1 {
                
                print("Last district in column to be modified.")
                
                // '+1' to compensate for starting from '0', '-1' to use correct column index (would be 1 off to the right insted).
                //let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultDistrictLengthInColumns) - 1
                let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultDistrictLengthInColumns)
                let rowIndexToStartFrom = /*defaultDistrictHeightInRows * (districtsPerHeight - 1)*/ defaultRows - defaultDistrictHeightInRows
                direction = .East
                for i in 0...defaultDistrictHeightInRows - 1 {
                    targetLine.append((row: rowIndexToStartFrom + i, column: colIndexToStartFrom))
                }
            
            } else {
                
                print("A standard district is to be modified.")
                
                // A target line in an even district-column has to be applied.
                let colIndexToStartFrom = currentDistrictColumn * defaultDistrictLengthInColumns
                //let rowIndexToStartFrom = (defaultDistrictHeightInRows * ((districtIndex + 1) % districtsPerHeight)) - 1
                let rowIndexToStartFrom = (defaultDistrictHeightInRows * ((districtIndex + 1) % districtsPerHeight))
                direction = .North
                for i in 0...defaultDistrictLengthInColumns - 1 {
                    targetLine.append((row: rowIndexToStartFrom, column: colIndexToStartFrom + i))
                }
            }
        
        } else {
            
            print("Uneven district column to be modified.")
            
            // An uneven column district has to be processed.
            // targetLine (except for last district in column) goes upward.
            // Check if last element has been reached and apply special targetLine.
            if districtIndex % districtsPerHeight == 0 {
                
                print("Last district in column to be modified.")
                
                //let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultDistrictLengthInColumns) - 1
                let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultDistrictLengthInColumns)
                let rowIndexToStartFrom = 0
                direction = .East
                for i in 0...defaultDistrictHeightInRows - 1 {
                    targetLine.append((row: rowIndexToStartFrom + i, column: colIndexToStartFrom))
                }
            
            } else {
                
                print("A standard district is to be modified.")
                
                // A target line in an uneven district-column has to be applied.
                let colIndexToStartFrom = currentDistrictColumn * defaultDistrictLengthInColumns
                //let rowIndexToStartFrom = defaultDistrictHeightInRows * (districtIndex % districtsPerHeight)
                let rowIndexToStartFrom = defaultDistrictHeightInRows * (districtIndex % districtsPerHeight) - 1
                direction = .South
                for i in 0...defaultDistrictLengthInColumns - 1 {
                    targetLine.append((row: rowIndexToStartFrom, column: colIndexToStartFrom + i))
                }
            }
        }
        
        print("District index: \(districtIndex).")
        print("targetLine: \(targetLine).")
        return(targetLine: targetLine, direction: direction)
    }
 
    fileprivate func createWaypointsForDistrict(startingColumnIndex: Int, startingRowIndex: Int, target: (targetLine: [(row: Int, column: Int)], direction: TargetLineDirection)) -> [(row: Int, column: Int)] {
        
        var isWayFinished = false
        
        // Start by adding startingPoint to array as first enty.
        var districtWaypoints = [(row: Int, column: Int)]()
        districtWaypoints.append((row: startingRowIndex, column: startingColumnIndex))
        
        print("createWaypointsForDistrict() called.")
        
        // Calculate an offset by which the processed district's
        //  target line can be reached. Without any modifiction,
        //  the target line will never be reached.
        //
        // Assumption: Map moves from left to right, and every
        //  even district column's way upwards, every uneven one
        //  downwards.
        var upperBoundColumnMod = 0
        var upperBoundRowMod = 0
        var lowerBoundColumnMod = 0
        var lowerBoundRowMod = 0
        
        // Define the bound's modification.
        switch target.direction {
        case .North:
            upperBoundRowMod = 1
        case .East:
            upperBoundColumnMod = 1
        case .South:
            lowerBoundRowMod = -1
        case .West:
            lowerBoundColumnMod = -1
        }
        
        while !isWayFinished {
            
            print("isWayFinished-loop started.")
            
            var isCurrentNeighborFound = false
            let latestColumn = districtWaypoints.last?.column
            let latestRow = districtWaypoints.last?.row
          
            // Remove invalid entries.
            /*
            for x in possibleColumns {
                for y in possibleRows {
                    if (y == latestRow! + 1) && (x == latestColumn! + 1) {
                        possibleColumns = possibleColumns.filter({ $0 != x })
                        possibleRows = possibleRows.filter({ $0 != y })
                    }
                }
            }*/
            
            while !isCurrentNeighborFound {
                
                print("Starting to look for new neighbor.")
                
                // Calculate the correct points where the way has to be build.
                var possibleColumns = createAllowedCoordinates(value: latestColumn!,
                                                               upperBound: calculateUpperBoundIndex(index: latestColumn!, mod: upperBoundColumnMod),
                                                               lowerBound: calculateLowerBoundIndex(index: latestColumn!, mod: lowerBoundColumnMod))
                
                var possibleRows = createAllowedCoordinates(value: latestRow!,
                                                            upperBound: calculateUpperBoundIndex(index: latestColumn!, mod: upperBoundRowMod),
                                                            lowerBound: calculateLowerBoundIndex(index: latestColumn!, mod: lowerBoundRowMod))
                
                possibleColumns = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleColumns) as! [Int]
                possibleRows = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleRows) as! [Int]
                
                let coordinates = processNewNeighbor(possibleRows: possibleRows, possibleColumns: possibleColumns, districtWaypoints: districtWaypoints)
                
                if !((coordinates.row == latestRow! + 1) && (coordinates.column == latestColumn! + 1)) {
                    
                    districtWaypoints.append(coordinates)
                    isCurrentNeighborFound = true
                    
                    // Now check if district's target line has been reached.
                    if target.targetLine.contains(where: { $0.0 == coordinates.row && $0.1 == coordinates.column }) {
                        
                        if districtWaypoints.count <= 20 {
                            print("Hurray, the district has a complete valid way.")
                            isWayFinished = true
                        
                        } else {
                            
                        }
                    }

                } else if coordinates.row == -2 && coordinates.column == -2 {
                    print("A jump-detected was returned.")
                    
                } else {
                    print("***")
                    print("No new neighbor found, resetting whole process.")
                    print("***")
                    districtWaypoints = [(row: Int, column: Int)]()
                    districtWaypoints.append((row: startingRowIndex, column: startingColumnIndex))
                }
            }
        }
        
        return districtWaypoints
    }
    
    fileprivate func calculateUpperBoundIndex(index: Int, mod: Int) -> Int {
        return (index + (defaultDistrictLengthInColumns - (index % defaultDistrictLengthInColumns))) - 1 + mod
    }
    
    fileprivate func calculateLowerBoundIndex(index: Int, mod: Int) -> Int {
        return index - (index % defaultDistrictLengthInColumns) + mod
    }
    
    fileprivate func processNewNeighbor(possibleRows: [Int], possibleColumns: [Int], districtWaypoints: [(row: Int, column: Int)]) -> (row: Int, column: Int) {
        
        let latestColumn = districtWaypoints.last?.column
        let latestRow = districtWaypoints.last?.row
        
        for nextColumn in possibleColumns {
            for nextRow in possibleRows {
                
                // Check if a jump from (x,y) to (x+1, y+1) has appeard.
                if !((nextRow == latestRow! + 1) && (nextColumn == latestColumn! + 1)) {
                    
                    if areCoordinatesValid(row: nextRow, column: nextColumn, savedPoints: districtWaypoints) {
                        //districtWaypoints.append((row: nextRow, column: nextColumn))
                        print("")
                        print("Neighbor found. Row: \(nextRow), column: \(nextColumn).")
                        print("")

                        return (row: nextRow, column: nextColumn)
                        
                    } else {
                        print("Coordinates aren't valid.")
                    }
                
                } else {
                    print("")
                    print("Jump detected.")
                    print("No waypoint created.")
                    print("")
                    //return (row: -2, column: -2)
                }
            }
        }
        
        print("Every possible combination of valid points has been processed, but no new neighbor could be created.")
        print("DEBUG: Returning (-1,-1).")
        
        return (row: -1, column: -1)
    }
    
    fileprivate func areCoordinatesValid(row: Int, column: Int, savedPoints: [(row: Int, column: Int)]) -> Bool {
        
        if savedPoints.contains(where: { $0.0 == row && $0.1 == column }) {
            print("Point not valid, has already been registered as waypoint.")
            return false
        }
        
        if MapManager.instance.maps[.Buildings]?.tileGroup(atColumn: column, row: row) != nil {
            print("Tile in buildings-map not nil.")
            return false
        }
        
        return true
    }
    
    /// Creates an array of allowed points, for example to define the next neighbor coordinates
    /// during the way-building process. Only for one axis at a time.
    ///
    /// - Parameters:
    ///   - value: The sender's current point.
    ///   - upperBound: The upper bound which isn't allowed to be crossed.
    ///   - lowerBound: The lower bound which isn't allowed to be crossed.
    /// - Returns: Array of Ints, which define the valid points to choose from.
    fileprivate func createAllowedCoordinates(value: Int, upperBound: Int, lowerBound: Int) -> [Int] {
        var values = [Int]()
        
        values.append(value)
        
        if value > lowerBound {
            print("createAllowedCoordinates() : value > lowerBound")
            values.append(value - 1)
        }
        
        if value < upperBound {
            print("createAllowedCoordinates() : value < upperBound")
            values.append(value +  1)
        }
        
        print("Allowed coordinates: \(values).")
        return values
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
