//
//  WayBuilder.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 01.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit
import GameplayKit

class WayBuilder {
    
    // MARK: - Variables.
    
    static let instance: WayBuilder = {
        return WayBuilder()
    }()
    
    fileprivate var maps = [SKTileMapNode]()
    fileprivate var waypoints: [CGPoint]?
    fileprivate var latestSegmentIndex = 0
    fileprivate var lowerLeftCorner: CGPoint?
    fileprivate var upperRightCorner: CGPoint?
    fileprivate var targetArea = [CGPoint]()
    fileprivate var prohibitedMapTypes: [TerrainType]?
    fileprivate let referencePointsClockwiseEvenColumn = [CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0), CGPoint(x: 1, y: -1),
                                                          CGPoint(x: 0, y: -1), CGPoint(x: -1, y: -1), CGPoint(x: -1, y: 0)]
    fileprivate let referencePointsClockwiseUnevenColumn = [CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 1), CGPoint(x: 1, y: 0),
                                                          CGPoint(x: 0, y: -1), CGPoint(x: -1, y: 0), CGPoint(x: -1, y: 1)]
    
    let defaultColumns = 14
    let defaultRows = 14
    let defaultSegmentHeightInRows = 7
    let defaultSegmentLengthInColumns = 7
    var segmentsPerLength: Int { return defaultColumns / defaultSegmentLengthInColumns }
    var segmentsPerHeight: Int { return defaultRows / defaultSegmentHeightInRows }
    
    fileprivate var probabilityValues: [Probabilies: Float] = [.Central : 0.5,
                                                               .CentralLeft : 0.3,
                                                               .CentralRight : 0.3,
                                                               .WeakLeft : 0.1,
                                                               .WeakRight : 0.1,
                                                               .Back : 0]
    
    fileprivate enum TargetDirection {
        case North
        case South
        case East
        case West
    }
    
    fileprivate enum  Probabilies {
        case Central
        case CentralLeft
        case CentralRight
        case WeakLeft
        case WeakRight
        case Back
    }
    
    // MARK: - Methods.
    
    private init() {}
    
    /// The single necessary interaction point to build a way.
    ///
    /// - Parameters:
    ///   - segmentsToProcess: Number of segments totally to process
    ///   - point: An optional starting point.
    ///   - maps: An optional list of maps to use.
    /// - Returns: A continious way through one or more segments,
    ///            stored as a chronological list of CGPoints.
    func make(segmentsToProcess: Int,
              from point: CGPoint = CGPoint(x: 0, y: 0),
              withMaps maps: [SKTileMapNode]? = nil,
              removeDuplicates: Bool = true) -> [CGPoint] {
        
        // Make sure to initalize the array.
        if waypoints == nil {
            waypoints = [CGPoint]()
            waypoints?.append(point)
        }
        
        // If provided, set up some maps for later terrain checking.
        if let providedMaps = maps {
            self.maps = providedMaps
        }
        
        // Process every segment
        while latestSegmentIndex < segmentsToProcess {
            
            // Ok, here's quite a magic trick:
            //
            //  Every segment in an uneven column of segments has to be reversed
            //  in its position.
            //  That's because the global waypoints have to go in a snake-style like
            //  fashion. Without this modification, the way would never complete due
            //  to the fact that the first segment in an uneven segment column would
            //  be down where it should be on top.
            
            track(.I, "SegmentIndex before modification: \(latestSegmentIndex)", self)
            
            let magicIndex = getSegmentColumn(latestSegmentIndex) % 2 == 0
                ? latestSegmentIndex
                : (segmentsPerHeight - 1) - (latestSegmentIndex % segmentsPerHeight) + (getSegmentColumn(latestSegmentIndex) * segmentsPerHeight)
            
            track(.I, "Computed segment index: \(magicIndex)", self)
            createSegmentBounds(segmentIndex: magicIndex, withTarget: true)
            
            // Add the newly created waypoints from the latest segment to the master waypoints-list.
            waypoints! += makeSegment(from: waypoints!.last!)
            
            latestSegmentIndex += 1
        }
        
        // Put on the finishing touches, if necessary.
        self.maps.removeAll()
        
        if removeDuplicates {
            let cleanWay = Array(NSOrderedSet(array: waypoints!))
            waypoints?.removeAll()
            
            for point in cleanWay {
                waypoints?.append(point as! CGPoint)
            }
        }
        
        return waypoints!
    }
    
    /// Create an array of waypoints for a segment.
    ///
    /// - Parameter startingPoint: The point to start from
    /// - Returns: A chronological list of waypoints.
    func makeSegment(from startingPoint: CGPoint = CGPoint(x: 0, y: 0)) -> [CGPoint] {
        
        var isDone = false
        var way =  [CGPoint]()
        
        while !isDone {
            
            way = makeWay(startPoint: startingPoint)
            isDone = !way.isEmpty
            
            if !isDone {
                track(.I, "The way returned from makeWay() was empty. Starting over", self)
            }
        }
        
        return way
    }
    
    /// Set the current segment's bounds. The values provided are included in the bound's area.
    ///
    /// - Parameters:
    ///   - lowerLeftIncl: Coordinates of the lower left corner.
    ///   - upperRightIncl: Coordinates of the upper right corner.
    /// - Returns: WayBuilder-instance to fulfill builder-pattern.
    func defineAreaBounds(lowerLeftIncl: CGPoint, upperRightIncl: CGPoint) -> WayBuilder {
        guard lowerLeftIncl.x >= 0 && lowerLeftIncl.y >= 0 && upperRightIncl.x >= 1 && upperRightIncl.y >= 1 else {
            track(.E, "One or more values provided are out of bounds", self)
            return self
        }
        
        lowerLeftCorner = lowerLeftIncl
        upperRightCorner = upperRightIncl
        
        return self
    }
    
    /// Set the starting point from where to way-building has to start.
    ///
    /// - Parameter point: The coordinates from where to start.
    /// - Returns: WayBuilder-instance to fulfill builder-pattern.
    func defineStartingPoint(from point: CGPoint) -> WayBuilder {
        waypoints = [CGPoint]()
        waypoints?.append(point)
        
        return self
    }
    
    /// Set the target-area, which defines when the way-building has succeeded.
    /// A success occures when the first point is set in the target-area.
    ///
    /// - Parameter targetArea: The area the
    /// - Returns: WayBuilder-instance to fulfill builder-pattern.
    func defineTargetBounds(targetArea: [CGPoint]) -> WayBuilder {
        guard !targetArea.isEmpty else {
            track(.F, "One or more values provided are out of bounds", self)
            abort()
        }
        
        self.targetArea = targetArea
        return self
    }
    
    /// Add a map to the list of maps which are checked when looking for a neighbor. Some tiles
    /// may prohibit the placement of a new waypoint.
    ///
    /// - Parameter map: The SKTileMapNode to add.
    /// - Returns: WayBuilder-instance to fulfill builder-pattern.
    func addMap(map: SKTileMapNode) -> WayBuilder {
        maps.append(map)
        
        return self
    }
    
    /// Method to define the waypoints.
    ///
    /// - Parameter startPoint: the point from where to start.
    /// - Returns: A list of waypoints in chronological order.
    fileprivate func makeWay(startPoint: CGPoint) -> [CGPoint] {
        
        var count = 0
        var segmentPoints = [CGPoint]()
        segmentPoints.append(startPoint)
        
        while !isOnTarget(point: segmentPoints.last!) {
            
            let neighbors = findAllPossibleNeighbors(pastPoints: segmentPoints)
            
            if !neighbors.isEmpty {
                //segmentPoints.append(chooseNeighbor(possiblePoints: neighbors, ))
                segmentPoints.append(chooseNeighbor(possiblePoints: neighbors, pastSegmentPoints: segmentPoints))
                
                track(.I, "New point: column:\(segmentPoints.last!.x), row: \(segmentPoints.last!.y)", self)
                
            } else {
                track(.I, "Neighbors returned to makeSegement() empty. Count: \(count)", self)
                return [CGPoint]()
                //abort()
            }
            
            count += 1
        }
        
        return segmentPoints
    }
    
    /// Searches for every neighbor next to a given point.
    /// Aside from keeping the point in bounds, no furher checks are applied.
    ///
    /// - Parameter fromPoint: The point whom neighbors are searched for.
    /// - Returns: A list of neighbors.
    func findAllNeighbors(fromPoint: CGPoint) -> [CGPoint] {
        assertPointIsValid(fromPoint, from: "findAllNeighbors")
        var points = [CGPoint]()
        
        // TODO
        // Check if tile on map isn't allowed, e.g. a mountain, sea, etc.
        
        for r in -1...1 {
            for c in -1...1 {
                
                if !((r == -1 && c == -1) || (r == -1 && c == 1) || (r == 0 && c == 0) || (r == 1 && c == 1) || (r == 1 && c == -1)) {
                    if isInBounds(point: fromPoint) && isInBounds(point: CGPoint(x: Int(fromPoint.x) + c, y: Int(fromPoint.y) + r)){
                        
                        points.append(CGPoint(x: Int(fromPoint.x) + c, y: Int(fromPoint.y) + r))
                        //points.append((row: fromPoint.y + r, column: fromPoint.x + c))
                    }
                }
            }
        }
        
        if points.isEmpty { track(.I, "No neighbor found", self) }
        
        return points
    }
    
    /// Search for every neighbor allowed.
    ///
    /// - Parameter pastPoints: A list of waypoints defined in the past.
    /// - Returns: A list of all possible neighbors.
    func findAllPossibleNeighbors(pastPoints: [CGPoint]) -> [CGPoint] {
        
        // Special treatment if very first point in waypoints is used.
        // Otherwise, the point would block itself from being build by
        // blocking with its own neighbors.
        if pastPoints.count == 1 {
            track(.I, "Finding neighbors from starting point", self)
            return findAllNeighbors(fromPoint: pastPoints.last!)
        }
        
        var currentNeighbors = findAllNeighbors(fromPoint: pastPoints.last!)
        
        let lastPointNeighbors = findAllNeighbors(fromPoint: pastPoints[pastPoints.count - 2])
        
        // Subtract the last point's neighbors to avoid too dense way-buliding + the last points itself to avoid going back.
        currentNeighbors = computeRelativeComplement(minuend: currentNeighbors, subtrahend: lastPointNeighbors)
        currentNeighbors = computeRelativeComplement(minuend: currentNeighbors, subtrahend: pastPoints)
        
        return currentNeighbors
    }
    
    /// Compute the relative complement for two given sets of waypoints.
    ///
    /// - Parameters:
    ///   - minuend: The set which contains all points except the subtrahend's ones.
    ///   - subtrahend: The set to subtract from the minuend.
    /// - Returns: Theh relative complement from the two provided sets.
    func computeRelativeComplement(minuend: [CGPoint], subtrahend: [CGPoint] ) -> [CGPoint] {
        var points = [CGPoint]()
        
        for n in minuend {
            if !subtrahend.contains(n) && !points.contains(n) {
                points.append(n)
            }
        }
        
        return points
    }
    
    /// Settle for a neighbor from a given set.
    ///
    /// - Parameter possiblePoints: The set from which to choose a neighbor.
    /// - Parameter pastSegmentPoints: The set of stored points for the segment to process.
    /// - Returns: The choosen neighbor.
    func chooseNeighbor(possiblePoints: [CGPoint], pastSegmentPoints: [CGPoint]) -> CGPoint {
        
        // Check if at least 2 waypoints have already been stored.
        //  If so, use smart way detection, else go the plain way,
        //  because at least 2 points are requiered for smart detection
        //  (with only one point, no direction can be specified).
        if pastSegmentPoints.count < 2 {
            
            track(.I, "Too little waypoints stored for smart way-building. Simple method used insted", self)
            return possiblePoints[GKRandomSource.sharedRandom().nextInt(upperBound: possiblePoints.count)]
        }
        
        let latestPoint = pastSegmentPoints.last!
        let neighborDict = getNeighborProbabilities(oldPoint: pastSegmentPoints[pastSegmentPoints.count - 2], latestPoint: latestPoint)
        var probabilitySum: Float = 0
        
        // Get sum of all propability values.
        for value in neighborDict.values {
            probabilitySum += value
        }
        
        var relatedReferencePoints = [Float](repeating: 0.0, count: 6)
        
        for (key, value) in neighborDict {
            relatedReferencePoints[key] = value / probabilitySum
        }
        
        var newNeighbor: CGPoint?
        
        while newNeighbor == nil {
            
            let i = GKRandomSource.sharedRandom().nextInt(upperBound: referencePointsClockwiseEvenColumn.count)
            let nextPointCandidate = addCGPoints(latestPoint, referencePointsClockwiseEvenColumn[i])
            
            if pastSegmentPoints.contains(nextPointCandidate) {
                track(.I, "Possible new neighbor already stored as past point. Not valid, retrying", self)
                
            } else if possiblePoints.contains(nextPointCandidate) {
                if GKRandomSource.sharedRandom().nextUniform() <= relatedReferencePoints[i] {
                    
                    // A neighbor has been chosen.
                    newNeighbor = nextPointCandidate
                    track(.I, "New neighbor chosen: \(newNeighbor!).", self)
                    if pastSegmentPoints.contains(newNeighbor!) {
                        track(.E, "Strangely, the new neighbor has already been stored, yet got chosen", self)
                    }
                }
                
                track(.I, "Too bad, dat new neighbor hadn't that much luck", self)
            }
        }
        
        return newNeighbor!
    }
    
    /// Check if a given point is within the defined bounds.
    ///
    /// - Parameter point: The point to verify.
    /// - Returns: Result of verification if point is within bounds.
    func isInBounds(point: CGPoint) -> Bool {
        return point.y >= lowerLeftCorner!.y && point.y <= upperRightCorner!.y
            && point.x >= lowerLeftCorner!.x && point.x <= upperRightCorner!.x
    }
    
    /// Examine if a given point is within the bounds of a target area.
    ///
    /// - Parameter point: The point to check.
    /// - Returns: Result if point is on target area.
    func isOnTarget(point: CGPoint) -> Bool {
        assertPointIsValid(point, from: "isOnTarget")
        return targetArea.contains(point)
    }
    
    /// Retrieve the correct probabilites for setting a new neighbor.
    ///
    /// - Parameters:
    ///   - oldPoint: The second-latest point added to the waypoints.
    ///   - newPoint: The latest stored waypoint.
    /// - Returns: Dictonary of indizes regarding the 'referencePointsClockwise' array and its computed probabilities.
    func getNeighborProbabilities(oldPoint: CGPoint, latestPoint: CGPoint) -> [Int:Float]{
        let count = referencePointsClockwiseEvenColumn.count
        
        // Calculate the point where to start the probability assignment.
        // This point is a neighbor from 'newPoint', yet only with realtive x und y values.
        let alignmentPoint = subtractCGPoints(minuend: latestPoint, subtrahend: oldPoint)
        
        // Retrieve index from central 'forward' moving point.
        let indexCentral = referencePointsClockwiseEvenColumn.index(of: alignmentPoint)!
        let indexCentralLeft = (indexCentral + count - 1) % count
        let indexCentralRight = (indexCentral + 1) % count
        let indexWeakLeft = (indexCentral + count - 2) % count
        let indexWeakRight = (indexCentral + 2) % count
        
        // Save the indizes and their corresponding probability-values for this neighbor.
        var probabilityPerPoint = [Int:Float]()
        probabilityPerPoint.updateValue(probabilityValues[.Central]!, forKey: indexCentral)
        probabilityPerPoint.updateValue(probabilityValues[.CentralLeft]!, forKey: indexCentralLeft)
        probabilityPerPoint.updateValue(probabilityValues[.CentralRight]!, forKey: indexCentralRight)
        probabilityPerPoint.updateValue(probabilityValues[.WeakLeft]!, forKey: indexWeakLeft)
        probabilityPerPoint.updateValue(probabilityValues[.WeakRight]!, forKey: indexWeakRight)
        
        return probabilityPerPoint
    }
    
    func getCorrectReferencePoint(point: CGPoint,at index: Int) -> CGPoint {
        guard index >= 0 || index < referencePointsClockwiseUnevenColumn.count else {
            track(.F, "Index for determining referencePoint is out of bounds", self)
            abort()
        }
        
        return Int(point.x) % 2 == 0
            ? referencePointsClockwiseEvenColumn[index]
            : referencePointsClockwiseUnevenColumn[index]
    }
    
    /// Little helper to subtract to CGPoint's.
    ///
    /// - Parameters:
    ///   - minuend: The value to subtract from.
    ///   - subtrahend: The value to subtract.
    /// - Returns: Result of a CGPoint-subtraction.
    func subtractCGPoints(minuend: CGPoint, subtrahend: CGPoint) -> CGPoint {
        return CGPoint(x: (minuend.x - subtrahend.x), y: (minuend.y - subtrahend.y))
    }
    
    func addCGPoints(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        return CGPoint(x: a.x + b.x, y: a.y + b.y)
    }
    
    /// Little helper to make sure only non-negative values for points are provided.
    ///
    /// - Parameters:
    ///   - point: The point to verify.
    ///   - from: Result if point's x and y value are non-negative.
    fileprivate func assertPointIsValid(_ point: CGPoint, from: String) {
        if point.x < 0 || point.y < 0 {
            track(.F, "\(from)() : At least one of point's values is < 0", self)
            abort()
        }
    }
    
    /// Method to create the correct target line based on the column's index.
    /// The schema of segment distribution looks like to following:
    ///
    /// -------
    /// 1  |  3
    /// ---+---
    /// 0  |  2
    /// -------
    ///
    /// Currently only works for up/down/right targetLines.
    ///
    /// - Parameter districtIndex: The index to use as a seed.
    /// - Returns: List of points definening the target area.
    func createTargetArea(from districtIndex: Int) -> [CGPoint] {
        var targetArea = [CGPoint]()
        var direction: TargetDirection
        let districtsPerHeight = defaultRows / defaultSegmentHeightInRows
        let currentDistrictColumn: Int = getSegmentColumn(districtIndex)
        
        // targetLine (except for last district in column) goes upward.
        if currentDistrictColumn % 2 == 0 {
            
            track(.I, "Even district column to be modified", self)
            
            // Check if last element has been reached and apply special targetLine.
            if districtIndex % districtsPerHeight == districtsPerHeight - 1 {
                
                track(.I, "Last district in column to be modified", self)
                
                // '+1' to compensate for starting from '0', '-1' to use correct column index (would be 1 off to the right insted).
                //let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultDistrictLengthInColumns) - 1
                let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultSegmentLengthInColumns)
                let rowIndexToStartFrom = /*defaultDistrictHeightInRows * (districtsPerHeight - 1)*/ defaultRows - defaultSegmentHeightInRows
                direction = .East
                for i in 0...defaultSegmentHeightInRows - 1 {
                    //targetArea.append((row: rowIndexToStartFrom + i, column: colIndexToStartFrom))
                    targetArea.append(CGPoint(x: colIndexToStartFrom, y: rowIndexToStartFrom + i))
                }
                
            } else {
                
                track(.I, "A standard district is to be modified", self)
                
                // A target line in an even district-column has to be applied.
                let colIndexToStartFrom = currentDistrictColumn * defaultSegmentLengthInColumns
                //let rowIndexToStartFrom = (defaultDistrictHeightInRows * ((districtIndex + 1) % districtsPerHeight)) - 1
                let rowIndexToStartFrom = (defaultSegmentHeightInRows * ((districtIndex + 1) % districtsPerHeight))
                direction = .North
                for i in 0...defaultSegmentLengthInColumns - 1 {
                    //targetArea.append((row: rowIndexToStartFrom, column: colIndexToStartFrom + i))
                    targetArea.append(CGPoint(x: colIndexToStartFrom + i, y: rowIndexToStartFrom))
                }
            }
            
        } else {
            
            track(.I, "Uneven district column to be modified", self)
            
            // An uneven column district has to be processed.
            // targetLine (except for last district in column) goes upward.
            // Check if last element has been reached and apply special targetLine.
            if districtIndex % districtsPerHeight == 0 {
                
                track(.I, "Last district in column to be modified", self)
                
                //let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultDistrictLengthInColumns) - 1
                let colIndexToStartFrom = ((currentDistrictColumn + 1) * defaultSegmentLengthInColumns)
                let rowIndexToStartFrom = 0
                direction = .East
                for i in 0...defaultSegmentHeightInRows - 1 {
                    //targetLine.append((row: rowIndexToStartFrom + i, column: colIndexToStartFrom))
                    targetArea.append(CGPoint(x: colIndexToStartFrom, y: rowIndexToStartFrom + i))
                }
                
            } else {
                
                track(.I, "A standard district is to be modified", self)
                
                // A target line in an uneven district-column has to be applied.
                let colIndexToStartFrom = currentDistrictColumn * defaultSegmentLengthInColumns
                //let rowIndexToStartFrom = defaultDistrictHeightInRows * (districtIndex % districtsPerHeight)
                let rowIndexToStartFrom = defaultSegmentHeightInRows * (districtIndex % districtsPerHeight) - 1
                direction = .South
                for i in 0...defaultSegmentLengthInColumns - 1 {
                    //targetLine.append((row: rowIndexToStartFrom, column: colIndexToStartFrom + i))
                    targetArea.append(CGPoint(x: colIndexToStartFrom + i, y: rowIndexToStartFrom))
                }
            }
        }
        
        track(.I, "Segment's index: \(districtIndex)", self)
        track(.I, "Target area: \(targetArea)", self)
        track(.I, "Direction: \(direction)", self)
        
        return targetArea
    }
    
    /// Retrieve the segment belonging to a given index.
    ///
    /// - Parameter segmentIndex: The index to use as the reference.
    /// - Returns: The segment's column index.
    func getSegmentColumn(_ segmentIndex: Int) -> Int {
        return Int(segmentIndex / (defaultRows / defaultSegmentHeightInRows))
    }
    
    /// Little helper to check if a given segment is the last in its column.
    ///
    /// - Parameter i: The index referencing the segment to check against.
    /// - Returns: Boolean whether a given segment is last in its column.
    func isSegmentLast(_ i: Int) -> Bool {
        let districtsPerHeight = defaultRows / defaultSegmentHeightInRows
        
        return getSegmentColumn(i) % 2 == 0
            ? i % districtsPerHeight == districtsPerHeight - 1
            : i % districtsPerHeight == 0
    }
    
    /// Retrieve the correct direction for a segment from a given segment index.
    ///
    /// - Parameter segmentIndex: The index to use as a reference.
    /// - Returns: The correct TargetDirection for the given segment.
    fileprivate func getDirection(from segmentIndex: Int) -> TargetDirection {
        return isSegmentLast(segmentIndex)
            ? .East
            : getSegmentColumn(segmentIndex) % 2 == 0 ? .North : .South
    }
    
    /// Define a segment's bounds based on a provided segment index.
    ///
    /// - Parameters:
    ///   - segmentIndex: The index to use as a reference.
    ///   - withTarget: Optional boolean if the target-area should be processed, too.
    fileprivate func createSegmentBounds(segmentIndex: Int, withTarget: Bool = false) {
        guard segmentIndex >= 0 else {
            track(.F, "segmentIndex not allowed to be < 0", self)
            abort()
        }
        
        let xIndex = Int(segmentIndex / segmentsPerLength) * defaultSegmentLengthInColumns
        let yIndex = (segmentIndex % segmentsPerHeight) * defaultSegmentHeightInRows
        
        lowerLeftCorner = CGPoint(x: xIndex, y: yIndex)
        upperRightCorner = CGPoint(x: xIndex + (defaultSegmentLengthInColumns - 1), y: yIndex + (defaultSegmentHeightInRows - 1))
        
        if withTarget {
            switch getDirection(from: segmentIndex) {
            case .North:
                upperRightCorner?.y += 1
            case .East:
                upperRightCorner?.x += 1
            case .South:
                lowerLeftCorner?.y -= 1
            case .West:
                lowerLeftCorner?.x -= 1
            }
            
            self.targetArea.removeAll()
            self.targetArea = createTargetArea(from: segmentIndex)
        }
    }
    
    /// Method to find the upper-bound value (inclusive)
    /// from a given segment index. Works for both x- and y- axis.
    ///
    /// - Parameter index: The segment index to use as a reference.
    /// - Returns: The upper-bound value.
    func calculateUpperBoundIndex(index: Int) -> Int {
        return (index + (defaultSegmentLengthInColumns - (index % defaultSegmentLengthInColumns))) - 1
    }
    
    /// Method to find the lower-bound value (inclusive)
    /// from a given segment index. Works for both x- and y- axis.
    ///
    /// - Parameter index: The segment index to use as a reference.
    /// - Returns: The lower-bound value.
    func calculateLowerBoundIndex(index: Int) -> Int {
        return index - (index % defaultSegmentLengthInColumns)
    }
    
    /// Retrieve the correct type of way-tile for a given waypoint on the map.
    ///
    /// - Parameter waypoint: The point to use as reference.
    /// - Returns: A string containing the indices of the neighbors in the naming schema for setting the correct way tile.
    func getWayTileName(for waypoint: CGPoint) -> String {
        guard waypoints != nil && waypoints!.count > 0 else {
            track(.E, "waypoints[] is nil", self)
            return ""
        }
        
        if let index = waypoints?.index(of: waypoint) {
            
            // TODO
            // Implement reasonable treatment of first tile.
            if index == 0 || index == waypoints!.count - 1 {
                track(.I, "First or last index detected, using debug tile name", self)
                return "Big_1_2"
            }
            
            let firstNeighbor = waypoints![index - 1]
            let secondNeighbor = waypoints![index + 1]
            
            track(.I, "Point to process: \(waypoint), 1. n: \(firstNeighbor), 2. n: \(secondNeighbor)", self)
            
            let firstRelativeValues = calculateRelativePosition(withMinuend: waypoint, subtrahend: firstNeighbor)
            let secondRelativeValues = calculateRelativePosition(withMinuend: waypoint, subtrahend: secondNeighbor)
            
            let firstIndex = mapRelativePointToWaySchema(with: firstRelativeValues, columnReference: Int(waypoint.x))
            let secondIndex = mapRelativePointToWaySchema(with: secondRelativeValues, columnReference: Int(waypoint.x))
            
            return firstIndex < secondIndex
                ? "Big_\(firstIndex)_\(secondIndex)"
                : "Big_\(secondIndex)_\(firstIndex)"
        }
        
        return ""
    }
    
    /// Retrieve the matching tile for a given waypoint.
    ///
    /// - Parameter point: The point to look for a matching tile.
    /// - Returns: The matching tile group.
    func getWayTile(for point: CGPoint) -> SKTileGroup? {
        track(.I, "Tile to choose: \(getWayTileName(for: point))", self)

        if let groups = MapBuilder.instance.tileSets[.Way]?.tileGroups {
            
            let tileToChoose = getWayTileName(for: point)
            for group in groups {
                if group.name! == tileToChoose {
                    return group
                }
            }
            
            track(.E, "No matching tileGroup found", self)
        }
        
        track(.E, "No SKTileSet for way defined yet", self)
        return nil
    }
    
    /// Little helper to get the correct neighbor-index for a given point
    /// in this naming schema.
    ///
    /// - Parameter point: The point to use for mapping.
    /// - Parameter columnReference: The center-point's column index to correctly get neighbors.
    /// - Returns: Index of neighbor in schema
    func mapRelativePointToWaySchema(with point: CGPoint, columnReference: Int) -> Int {
        track(.I, "Point received: \(point)", self)
        
        // Slightly different reference points for un-/even columns.
        if columnReference % 2 == 0 {
            switch (point.x, point.y) {
            case (-0,1):
                return 1
            case (1,-0):
                return 2
            case (1,-1):
                return 3
            case (-0,-1):
                return 4
            case (-1,-1):
                return 5
            case (-1,-0):
                return 6
            default:
                track(.E, "Point's relative values are out of bounds: \(point)", self)
                return 1
            }
            
        } else {
            switch (point.x, point.y) {
            case (-0,1):
                return 1
            case (1,1):
                return 2
            case (1,-0):
                return 3
            case (-0,-1):
                return 4
            case (-1,-0):
                return 5
            case (-1,1):
                return 6
            default:
                track(.E, "Point's relative values are out of bounds: \(point)", self)
                return 1
            }
        }
        
    }
    
    /// Retrieve a point's reference coordinates relative to another given point.
    ///
    /// - Parameters:
    ///   - minuend: The point used as orientation.
    ///   - subtrahend: The point whoms reference coordinates have to be identified.
    /// - Returns: The correct reference point for the subtrahend.
    func calculateRelativePosition(withMinuend minuend: CGPoint, subtrahend: CGPoint) -> CGPoint {
        var point = subtractCGPoints(minuend: minuend, subtrahend: subtrahend)
        point.x *= -1
        point.y *= -1
        
        return point
    }
}
