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
    
    // DELETE
    var waypoints: [(row: Int, column: Int)]?
    var lowerLeftCorner: (row: Int, column: Int)?
    var upperRightCorner: (row: Int, column: Int)?
    
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
        MapManager.instance.maps[.Ground]?.position = CGPoint(x: 200, y: self.frame.midY)
        addChild(MapManager.instance.maps[.Ground]!)
        //MapManager.instance.maps[.Ground]!.isHidden = true
        
        MapManager.instance.maps[.Way]?.position = CGPoint(x: 200, y: self.frame.midY)
        addChild(MapManager.instance.maps[.Way]!)
        
        MapManager.instance.maps[MapType.Buildings]?.position = CGPoint(x: 50, y: self.frame.midY)
        addChild(MapManager.instance.maps[.Buildings]!)
        //MapManager.instance.maps[.Buildings]!.isHidden = true
        //MapManager.instance.maps[.Buildings]!.fill(with: MapBuilder.instance.tileSets[.Ground]!.tileGroups[3])
        
        MapManager.instance.maps[.District]?.position = CGPoint(x: 200, y: self.frame.midY)
        addChild(MapManager.instance.maps[.District]!)
        MapManager.instance.maps[.District]!.isHidden = true
        
        MapManager.instance.maps[.InBuildMode]?.position = CGPoint(x: 200, y: self.frame.midY)
        addChild(MapManager.instance.maps[.InBuildMode]!)
        MapManager.instance.maps[.InBuildMode]!.isHidden = true
        
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
        
        // DEBUG - WORKS - DELETE AFTER INTEGRATION WITH MAPBUILDER
        
        let map = MapManager.instance.maps[.Way]!
        let waypoints = WayBuilder.instance
            .make(segmentsToProcess: 4)

        
        // TODO
        // Hacky way of making sure no duplicates are stored.
        // Better check that no duplicates get in there in the first place.
        let unique = Array(NSOrderedSet(array: waypoints))
        
        let reversedPoints = unique.reversed()
        
        for p in reversedPoints {
            let point = p as! CGPoint
            print("Point to draw: \(point).")
            //map.setTileGroup(MapBuilder.instance.tileSets[.Buildings]?.tileGroups[3], forColumn: Int(point.x), row: Int(point.y))
            if let tile = WayBuilder.instance.getWayTile(for: point) {
                map.setTileGroup(tile, forColumn: Int(point.x), row: Int(point.y))
            } else {
                print("Setting waytile failed.")
            }
        }
        
        var positions = [CGPoint]()
        for point in reversedPoints {
            let p = point as! CGPoint
            positions.append(map.centerOfTile(atColumn: Int(p.x), row: Int(p.y)))
        }
        
        let monster = childNode(withName: "MonsterBoss") as! SKSpriteNode
        monster.removeFromParent()
        map.addChild(monster)
        monster.position = positions.first!
        
        var moves = [SKAction]()
        
        for p in positions {
            moves.append(SKAction.move(to: p, duration: 0.2))
        }
        
        let sequence = SKAction.sequence(moves)
        monster.run(sequence)
        
        // Views should be initalized now, let's hook them up to some listeners.
        hookUpCallbacks()
        
        // DEBUG
        // Demo Periodic-class.
        /*
        let p = EvolutionTimer(withInterval: 5, isEvolving: true, provider: self)
        let f: (EvolutionTimer, Any) -> Void = {
            (p: EvolutionTimer, me: Any) -> Void in
            
            //let v = self
            
            print("Hey there from function inside periodic!")
            print("Evolution before modification: \(p.isEvolving).")
            p.isEvolving = true
            print("Evolution after modification: \(p.isEvolving).")
            /*
            let label = SKLabelNode(text: "A message from a stored closure!")
            label.position = CGPoint(x: v.frame.midX, y: v.frame.midY)
            label.fontSize = 60
            v.addChild(label)
            */
        }
        
        p.provideEvolutionFunction(toRun: f)
        p.start(withDelayInSeconds: 0.0, isRepating: false)
        */
        
        // WORKS
        // DEBUG
        // Proof BuldView's capabilities.
        /*
        let cats = BuildView.SuperCategoriesNode()
        cats.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        addChild(cats)
        */
        
        // DEBUG
        // Create sprite and add it.
        // WORKS
        /*
        let node = SKSpriteNode(imageNamed: "Hill")
        node.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(node)
        */
        
        let buildView = BuildView()
        buildView.position = CGPoint(x: 0, y: 0 - (frame.height / 2) + 20)
        camera?.addChild(buildView)
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
        
        print("Coal: \(StateValuesManager.sharedInstance.getValue(type: .Coal) ?? 0.0)")
        print("Stone: \(StateValuesManager.sharedInstance.getValue(type: .Stone) ?? 0.0)")
        print("Gold: \(StateValuesManager.sharedInstance.getValue(type: .Gold) ?? 0.0)")
        
        // Demo changing a val.
        //StateValuesManager.sharedInstance.changeResourceValueTo(val: 200.0, type: .Coal)
    }
    
    fileprivate func hookUpCallbacks() {
        StateValuesManager.sharedInstance.resourceCallbackReceiver = stateValuesView
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
            
            //UserInteractionManager.instance.checkInput(event: event, scene: self)
            
            //MapManager.instance.maps[.Ground]!.setTileGroup(MapBuilder.instance.tileSets[.Buildings]!.tileGroups[3], forColumn: 0, row: 0)
            
            /*
             let map = childNode(withName: "Tile Map Node") as! SKEnhancedMap
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

