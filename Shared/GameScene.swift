//
//  GameScene.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 10.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var camRef = SKNode()
    
    /// The current view on the scene.
    var camMenu = SKCameraNode()
    
    /// View on top of game, showing the game's global values.
    var stateValuesView = StateValuesView()
    
    // DEBUG ONLY - Type will be altered.
    var buildMenu = SKSpriteNode()
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        
        return scene
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
        self.view?.acceptsTouchEvents = true
        if (self.view?.acceptsTouchEvents)! {
            print("Accepting touch events.")
        }
        //self.view?.wantsRestingTouches = true
        
        // Assign base camera.
        camMenu = (childNode(withName: "menuCamera") as? SKCameraNode)!
        self.camera = camMenu
        
        // DEBUG MAP CREATION
        //let map = MapBuilder.instance.makeGround()
        //let groundMap = MapManager.instance.maps[.Ground]
        MapManager.instance.maps[.Ground]?.position = CGPoint(x: 50, y: self.frame.midY)
        addChild(MapManager.instance.maps[.Ground]!)
        
        // DELETE
        //let shape = SKSpriteNode(imageNamed: "demoCircle")
        //self.camera?.addChild(shape)
        
        // Add state values view.
        //let state = StateValuesView()
        self.camera?.addChild(stateValuesView)
        //self.camera?.addChild(StateValuesView.instance)
        
        //print(self.camera?.frame)
        stateValuesView.position = CGPoint(x: 0, y: camMenu.frame.maxY - 50)
        //StateValuesView.instance.position = CGPoint(x: 0, y: camMenu.frame.maxY - 50)
        
        // Register camera reference (for moving)
        camRef = childNode(withName: "camReference")!
        
        // Move camera with reference point.
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: camRef)
        camera?.constraints = [ constraint ]
        
        // Register menu bar (ONLY 1 TILE FOR NOW - DEBUG).
        self.buildMenu = self.camera?.childNode(withName: "forestTower") as! SKSpriteNode
        //let c = SKConstraint.positionX(SKRange.init(constantValue: 0), y: SKRange.init(constantValue: -s447))
        //buildMenu.constraints = [ c ]
        
        // Gesture-recognizers.
        /*
        let gestureRecognizer = NSPanGestureRecognizer(target: self, action: #selector(GameScene.handlePanFrom))
        gestureRecognizer.delegate = self as? NSGestureRecognizerDelegate
        self.view!.addGestureRecognizer(gestureRecognizer)
        */
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        // Views should be initalized now, let's hook them up to some listeners.
        hookUpCallbacks()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        print("Did change size.")
        buildMenu.position = CGPoint(x: self.size.width / 2, y: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        //debug.checkIntersection()
        /*
        if !MapManager.instance.towers.isEmpty {
            for tower in MapManager.instance.towers {
                let range = tower.rangeImage
                if sprite.intersects(range!) {
                    print("They intersect!")
                    count += 1
                    print(count)
                }
            }
        } else {
            print("No intersection.")
        }*/
    }
    
    // MARK: - Helpers.
    
    func setUpScene() {
        
        // Observe whenever a resource value has changed.
        //StateValuesManager.sharedInstance.addObserver(self, forKeyPath: "resourcesChanged", options: NSKeyValueObservingOptions(), context: nil)
        
        //StateValuesManager.sharedInstance.callBackReceiver = self
        
        
        //MapManager.sharedInstance.map = childNode(withName: "GroundTiles") as! SKTileMapNode
        print("Coal: \(StateValuesManager.sharedInstance.getValue(type: .Coal) ?? 0.0)")
        print("Stone: \(StateValuesManager.sharedInstance.getValue(type: .Stone) ?? 0.0)")
        print("Gold: \(StateValuesManager.sharedInstance.getValue(type: .Gold) ?? 0.0)")
        
        // Demo chaning a val.
        StateValuesManager.sharedInstance.changeResourceValueTo(val: 200.0, type: .Coal)
        
        //debugMan = DebugMan(scene: self)
        //debugMan.registerCirclesAndMove()
    }
    
    fileprivate func hookUpCallbacks() {
        //StateValuesManager.sharedInstance.resourceCallbackReceiver = StateValuesView.instance
        StateValuesManager.sharedInstance.resourceCallbackReceiver = stateValuesView
        //StateValuesManager.sharedInstance.fireCallback(key: <#T##Resources#>, val: <#T##Double#>)
    }
    
    // MARK: - Gesture-recognizers.
    
    func handlePanFrom(recognizer: NSPanGestureRecognizer) {
        print("Panning detected, translation: \(recognizer.translation(in: self.view)).")
        
        //recognizer.state == .
                
        let xOffset = recognizer.translation(in: self.view).x
        let yOffset = recognizer.translation(in: self.view).y
        
        let xNow = camRef.position.x
        let yNow = camRef.position.y
        
        camRef.position = CGPoint(x: xNow - xOffset, y: yNow - yOffset)
    }
    
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
}

#if os(iOS) || os(tvOS)
    // Touch-based event handling
    extension GameScene {
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            for t in touches {
            }
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
            }
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            for t in touches {
            }
        }
    }
#endif

#if os(OSX)
    // Mouse-based event handling
    extension GameScene {
        
        override func mouseDown(with event: NSEvent) {
            /*
            if count == 0 {
                count += 1
                
                sprite = childNode(withName: "sprite") as! SKSpriteNode
                sprite.run(SKAction.moveBy(x: -2000, y: 0, duration: 15))
            }*/
            
            UserInteractionManager.instance.checkInput(event: event, scene: self)
 
            /*
            let map = childNode(withName: "Tile Map Node") as! SKTileMapNode
            let point = event.location(in: map)
            let c = map.tileColumnIndex(fromPosition: point)
            let r = map.tileRowIndex(fromPosition: point)
             
            */
            /*
            let map = MapManager.instance.maps[.Ground]!
            let point = event.location(in: map)
            let c = map.tileColumnIndex(fromPosition: point)
            let r = map.tileRowIndex(fromPosition: point)
            
            print("Columnn touched: \(c).")
            print("Row touched: \(r).")
            print("Number of rows: \(map.numberOfRows).")
            print("Number of columns: \(map.numberOfColumns).")
            */
        }
        
        override func mouseDragged(with event: NSEvent) {
            print("Mouse dragged."  )
        }
        
        override func mouseUp(with event: NSEvent) {
            print("Mouse button lifted.")
        }
        
        override func touchesBegan(with event: NSEvent) {
            print("Touches began.")
        }
        
        override func touchesMoved(with event: NSEvent) {
            print("Touches moved with event.")
        }
        
        override func touchesEnded(with event: NSEvent) {
            print("Touches ended.")
        }
        
        override func touchesCancelled(with event: NSEvent) {
            print("Touches cancelled.")
        }
        
        override func magnify(with event: NSEvent) {
            print("Magnifying!")
        }
    }
    
#endif

