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
    fileprivate var lowerLeftCorner: CGPoint?
    fileprivate var upperRightCorner: CGPoint?
    fileprivate var targetArea = [CGPoint]()
    fileprivate let referencePointsClockwise = [CGPoint(x: 1, y: 0), CGPoint(x: 0, y: 1), CGPoint(x: -1, y: 1),
                                    CGPoint(x: -1, y: 0), CGPoint(x: 0, y: -1), CGPoint(x: 1, y: -1)]
    
    // MARK: - Methods.
    
    private init() {}
    
    /// Set the current segment's bounds. The values provided are included in the bound's area.
    ///
    /// - Parameters:
    ///   - lowerLeftIncl: Coordinates of the lower left corner.
    ///   - upperRightIncl: Coordinates of the upper right corner.
    /// - Returns: WayBuilder-instance to fulfill builder-pattern.
    func defineAreaBounds(lowerLeftIncl: CGPoint, upperRightIncl: CGPoint) -> WayBuilder {
        guard lowerLeftIncl.x >= 0 && lowerLeftIncl.y >= 0 && upperRightIncl.x >= 1 && upperRightIncl.y >= 1 else {
            print("ERROR @ WayBuilder : defineAreaBounds() : One or more values provided are out of bounds.")
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
            print("FATAL ERROR @ WayBuilder : defineTargetBounds() : One or more values provided are out of bounds.")
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
    
    /// Create the the way for a given segment.
    ///
    /// - Parameter startingPoint: The point to start from
    /// - Returns: A chronological list of waypoints.
    func makeSegment(startingPoint: CGPoint) -> [CGPoint] {
        /*
         var segmentPoints = [CGPoint]()
         var finished = false
         var count = 0
         */
        
        if waypoints == nil {
            waypoints = [CGPoint]()
            print("INFO @ WayBuilder : makeSegment() : waypoints were null, are initialized now")
        }
        
        var isDone = false
        var way =  [CGPoint]()
        
        while !isDone {
            
            way = makeWay(startPoint: startingPoint)
            isDone = !way.isEmpty
            
            if !isDone {
                print("The way returned from makeWay() was empty. Starting over.")
            }
        }
        
        return way
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
                segmentPoints.append(chooseNeighbor(possiblePoints: neighbors, segmentPoints: segmentPoints))
                
                print("New point: column:\(segmentPoints.last!.x), row: \(segmentPoints.last!.y).")
                
            } else {
                print("Neighbors returned to makeSegement() empty. Count: \(count).")
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
        
        if points.isEmpty { print("INFO @ WayBuilder : findAllNeighbors() : No neighbor found.") }
        
        return points
    }
    
    /// Search for every neighbor allowed.
    ///
    /// - Parameter pastPoints: A list of waypoints defined in the past.
    /// - Returns: A list of all possible neighbors.
    func findAllPossibleNeighbors(pastPoints: [CGPoint]) -> [CGPoint] {
        
        // Special treatment if very first point in waypoints is used.
        if pastPoints.count == 1 {
            print("INFO @ WayBuilder : findPossibleNeighbors() : Finding neighbors from starting point.")
            return findAllNeighbors(fromPoint: pastPoints.last!)
        }
        
        var currentNeighbors = findAllNeighbors(fromPoint: pastPoints.last!)
        
        let lastPoint = pastPoints[pastPoints.count - 2]
        let lastPointNeighbors = findAllNeighbors(fromPoint: lastPoint)
        
        // Subtract the last point's neighbors to avoid too dense way-buliding + the last points itself to avoid going back.
        currentNeighbors = computeRelativeComplemente(minuend: currentNeighbors, subtrahend: lastPointNeighbors)
        currentNeighbors = computeRelativeComplemente(minuend: currentNeighbors, subtrahend: pastPoints)
        
        return currentNeighbors
    }
    
    /// Compute the relative complement for two given sets of waypoints.
    ///
    /// - Parameters:
    ///   - minuend: The set which contains all points except the subtrahend's ones.
    ///   - subtrahend: The set to subtract from the minuend.
    /// - Returns: Theh relative complement from the two provided sets.
    func computeRelativeComplemente(minuend: [CGPoint], subtrahend: [CGPoint] ) -> [CGPoint] {
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
    /// - Returns: The choosen neighbor.
    func chooseNeighbor(possiblePoints: [CGPoint], segmentPoints: [CGPoint]) -> CGPoint {
        
        // Check if at least 2 waypoints have already been stored.
        //  If so, use smart way detection, else go the plain way,
        //  because at least 2 points are requiered for smart detection.
        if segmentPoints.count < 2 {
            
            print("Too little waypoints stored for smart way-building. Simple method used insted.")
            return possiblePoints[GKRandomSource.sharedRandom().nextInt(upperBound: possiblePoints.count)]
        }
        
        let latestPoint = segmentPoints.last!
        let neighborDict = getNeighborProbabilities(oldPoint: segmentPoints[segmentPoints.count - 2], latestPoint: latestPoint)
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
            
            let i = GKRandomSource.sharedRandom().nextInt(upperBound: referencePointsClockwise.count)
            let nextPointCandidate = addCGPoints(latestPoint, referencePointsClockwise[i])
            
            if possiblePoints.contains(nextPointCandidate) {
                if GKRandomSource.sharedRandom().nextUniform() <= relatedReferencePoints[i] {
                    
                    // A neighbor has been chosen.
                    newNeighbor = nextPointCandidate
                    print("New neighbor chosen.")
                }
                
                print("Too bad, neighbor hadn't that much luck.")
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
        let count = referencePointsClockwise.count
        
        // Calculate the point where to start the probability assignment.
        // This point is a neighbor from 'newPoint', yet only with realtive x und y values.
        let alignmentPoint = subtractCGPoints(minuend: latestPoint, subtrahend: oldPoint)
        
        // Retrieve index from central 'forward' moving point.
        let indexCentral = referencePointsClockwise.index(of: alignmentPoint)!
        let indexCentralLeft = (indexCentral + count - 1) % count
        let indexCentralRight = (indexCentral + 1) % count
        let indexWeakLeft = (indexCentral + count - 2) % count
        let indexWeakRight = (indexCentral + 2) % count
        
        // Save the indizes and their corresponding probability-values for this neighbor.
        var probabilityPerPoint = [Int:Float]()
        probabilityPerPoint.updateValue(1, forKey: indexCentral)
        probabilityPerPoint.updateValue(0.25, forKey: indexCentralLeft)
        probabilityPerPoint.updateValue(0.25, forKey: indexCentralRight)
        probabilityPerPoint.updateValue(0.125, forKey: indexWeakLeft)
        probabilityPerPoint.updateValue(0.125, forKey: indexWeakRight)
        
        return probabilityPerPoint
    }
    
    /// Little helper to subtract to CGPoint's.
    ///
    /// - Parameters:
    ///   - minuend: The value to subtract from.
    ///   - subtrahend: The value to subtract.
    /// - Returns: Result of a CGPoint-subtraction.
    func subtractCGPoints(minuend: CGPoint, subtrahend: CGPoint) -> CGPoint {
        return CGPoint(x: minuend.x - subtrahend.x, y: minuend.y - subtrahend.y)
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
            print("FATAL ERROR @ WayBuilder : \(from)() : At least one of point's values is < 0.")
            abort()
        }
    }
}
