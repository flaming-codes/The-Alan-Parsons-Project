//
//  StateValuesView.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 20.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class StateValuesView: SKNode, ResourceCallback {

    // MARK: - Variables.
    
    var labels = [Resources: SKLabelNode]()
    
    // MARK: Initializers.
    
    override init() {
        super.init()
        self.isUserInteractionEnabled = true
        track(.I, "StateValuesView init() called", self)
        
        labels.updateValue(
            createLabel(text: "Coal", pos: CGPoint(x: frame.midX, y: frame.midY)),
            forKey: .Coal)
        
        labels.updateValue(
            createLabel(text: "Stone", pos: CGPoint(x: frame.midX - 200, y: frame.midY)),
            forKey: .Stone)
        
        labels.updateValue(
            createLabel(text: "Gold", pos: CGPoint(x: frame.midX + 200, y: frame.midY)),
            forKey: .Gold)
        
        for value in labels.values {
            self.addChild(value)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Interactions.
    
    #if os(OSX)
    
    override func mouseDown(with event: NSEvent) {
        track(.I, "StateValuesView self-detected touched", self)
        /*
        if let node = scene.camMenu.atPoint(event.location(in: scene.camMenu)) as? SKSpriteNode {
            print("Hurray, a node in the build menu was touched: \(node.name!)!")
            
            if let name = node.name {
                switch name {
                case "forestTower":
                    //scene.buildMenu.select(key: BuildableUnitCategories, value: BuildableUnit)
                    selection = TowerBuilder.instance.start(type: .Basic).addVisuals().make()
                    print("forestTower touched and selcted.")
                default:
                    print("ERROR @ UserInteractionManager : isInBuildMenuView() : default called.")
                }
            }
            
            return true
            
        } else {
            return false
        }*/
    }
    
    #endif
    
    // MARK: - Functions.
    
    func callBack(key: Resources, value: Double) {
        track(.I, "StateValuesView with key \(key) and value \(value) called", self)
        labels[key]?.text = "\(key): \(value)"
    }
    
    fileprivate func createLabel(text: String, pos: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = text
        label.fontSize = 30
        label.fontColor = SKColor.white
        label.position = CGPoint(x: pos.x, y: pos.y)
        
        return label
    }
}
