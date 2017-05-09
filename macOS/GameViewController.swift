//
//  GameViewController.swift
//  macOS
//
//  Created by Thomas Schönmann on 10.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene.newGameScene()
        
        let skView = self.view as! SKView
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        skView.presentScene(scene)
    }
    /*
    override func viewDidAppear() {
        super.viewDidAppear()
        let scene = GameScene.newGameScene()
        scene.scaleMode = .resizeFill
        let skView = self.view as! SKView
        if !skView.isInFullScreenMode {
            if let mainWindow = skView.window {
                mainWindow.toggleFullScreen(nil)
            }
        }
        skView.presentScene(scene)
    }
    */
}

