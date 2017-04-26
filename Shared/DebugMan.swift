//
//  DebugMan.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 10.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Tower: UInt32 = 0b10      // 2
}
/*
class Tester1: Mapping {
    typealias A = String
    typealias B = Int
    
    func map(a: String) -> Int {
        return a == "one" ? 1 : -1
    }
}

class Tester2: Mapping {
    typealias A = String
    typealias B = Int
    
    func map(a: String) -> Int {
        return a == "two" ? 2 : -1
    }
}
*/
@available(*, deprecated)
class DebugMan {
    
    var scene: SKScene
    var c1 = SKSpriteNode()
    var c2 = SKSpriteNode()
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // For empty initalization in var declaration only.
    init() {
        scene = SKScene()
    }
    
    func registerCirclesAndMove() {
        
        c1 = sprite(name: "circle1")
        c2 = sprite(name: "circle2")
        
        c1.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        c1.physicsBody?.contactTestBitMask = PhysicsCategory.Tower
        c1.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        c2.physicsBody?.categoryBitMask = PhysicsCategory.Tower
        c2.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        c2.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let moveToPoint = CGPoint(x: c2.position.x - 900.0, y: c2.position.y)
        let move = SKAction.move(to: moveToPoint, duration: 30)
        
        c2.run(move)
    }
    
    func checkIntersection() {
        c1.intersects(c2) ? print("Hurray, they intersect!") : print("No intersection.")
    }
    
    func createShockWave() -> SKAction {
        return { ()
            let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),
                                                    SKAction.fadeOut(withDuration: 0.5)])
            
            let sequence = SKAction.sequence([growAndFadeAction,
                                              SKAction.removeFromParent()])
            
            return sequence
        }()
    }
    /*
    func testGenericProtocol() {
        
        let mapper = Tester1()
        print("Result from protocol-test: \(mapper.map(a: "one"))")
    }
    */
    
    func makeMap() -> SKTileMapNode {
        
        let set = SKTileSet(named: "Sample Hexagonal Tile Set")
        let groups = set?.tileGroups
        
        for group in groups! {
            print(group.name!)
        }
        
        let map = SKTileMapNode(
            tileSet: SKTileSet(named: "Sample Hexagonal Tile Set")!,
            columns: 80,
            rows: 80,
            tileSize: (SKTileSet(named: "Sample Hexagonal Tile Set")?.defaultTileSize)!,
            fillWith: (groups?.first)!)
        
        return map
    }
    
    private func sprite(name: String) -> SKSpriteNode {
        return scene.childNode(withName: name) as! SKSpriteNode
    }
}
