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
 
 // MARK: - GameScene
 
 extension NSTouch {
 /**
 * Returns the relative position of the touch to the view
 * NOTE: the normalizedTouch is the relative location on the trackpad. values range from 0-1. And are y-flipped
 * TODO: debug if the touch area is working with a rect with a green stroke
 */
 func pos(_ view:NSView) -> CGPoint{
 let w = view.frame.size.width
 let h = view.frame.size.height
 let touchPos:CGPoint = CGPoint(x: self.normalizedPosition.x, y: 1 + (self.normalizedPosition.y * -1))/*flip the touch coordinates*/
 
 let deviceSize:CGSize = self.deviceSize
 let deviceRatio:CGFloat = deviceSize.width/deviceSize.height/*find the ratio of the device*/
 let viewRatio:CGFloat = w/h
 var touchArea:CGSize = CGSize(width: w, height: h)
 
 /*Uniform-shrink the device to the view frame*/
 if(deviceRatio > viewRatio){/*device is wider than view*/
 touchArea.height = h/viewRatio
 touchArea.width = w
 }else if(deviceRatio < viewRatio){/*view is wider than device*/
 touchArea.height = h
 touchArea.width = w/deviceRatio
 }/*else ratios are the same*/
 let touchAreaPos:CGPoint = CGPoint(
 x: (w - touchArea.width)/2,
 y: (h - touchArea.height)/2)/*we center the touchArea to the View*/
 let addition = CGPoint(x: touchPos.x * touchArea.width, y: touchPos.y * touchArea.height)
 print("Touches: \(CGPoint(x: addition.x + touchAreaPos.x, y: addition.y + touchAreaPos.y))")
 return CGPoint(x: addition.x + touchAreaPos.x, y: addition.y + touchAreaPos.y)
 }
 }
 */

// MARK: - SKPhysics' delegate methods.

// Delegte is called when a specific contact happens, its counterpart is called
//  when this specific contact ends == per contact one 'didBegin' & 'didEnd'
/*
 func didBegin(_ contact: SKPhysicsContact) {
 
 // 1
 var firstBody: SKPhysicsBody
 var secondBody: SKPhysicsBody
 if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
 firstBody = contact.bodyA
 secondBody = contact.bodyB
 } else {
 firstBody = contact.bodyB
 secondBody = contact.bodyA
 }
 
 if firstBody.node?.name == "circle1" && secondBody.node?.name == "circle2" {
 print("First contact happend at circle1.")
 }
 
 if firstBody.node?.name == "circle2" && secondBody.node?.name == "circle1" {
 print("First contact happend at circle2.")
 }
 
 // 2
 if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
 (secondBody.categoryBitMask & PhysicsCategory.Tower != 0)) {
 //if let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
 //projectileDidCollideWithMonster(projectile: projectile, monster: monster)
 print("They collided!")
 
 let shockwave = SKShapeNode(circleOfRadius: 5)
 shockwave.zPosition = 1
 shockwave.position = contact.contactPoint
 addChild(shockwave)
 shockwave.run(debugMan.createShockWave())
 }
 
 }
 
 @available(*, deprecated)
 func didEnd(_ contact: SKPhysicsContact) {
 if contact.bodyA.node?.name == "circle2" || contact.bodyB.node?.name == "circle2" {
 print("The moving circle has left the intersection are with the tower.")
 }
 }
 */
