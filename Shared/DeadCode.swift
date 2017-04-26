//
//  DeadCode.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

/*
 
 MARK: - Mouse-Down event in GameScene.swift
 
 if (self.camera?.contains(event.location(in: self)))! {
 print("ForestTower selected, detected in camera.")
 let touchedNodes = self.camera?.nodes(at: event.location(in: self))
 
 let map = self.childNode(withName: "GroundTiles") as! SKTileMapNode
 let changeColorAction = SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: 0.5)
 map.run(changeColorAction)
 
 let x = map.tileRowIndex(fromPosition: event.location(in: self))
 let y = map.tileColumnIndex(fromPosition: event.location(in: self))
 
 let node: SKNode = map.tileDefinition(atColumn: 2, row: 2) as! SKNode
 node.run(changeColorAction)
 
 /*
 for node:SKNode in touchedNodes! {
 let changeColorAction = SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: 0.5)
 node.run(changeColorAction)
 }
 */
 }
 
 var count: Int = 0
 
 // Only GameScene's top-layer elements will be detected, every child
 //  from the camera isn't part of the physics world.
 physicsWorld.enumerateBodies(at: event.location(in: self), using: {(body, _) -> Void in
 count += 1
 print("\(count): \(body.node?.name ?? "Body's name couldn't be read.")")
 })
 
 */
