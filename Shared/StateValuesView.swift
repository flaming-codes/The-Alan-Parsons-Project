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
        print("StateValuesView init() called.")
        
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
    
    // MARK: - Functions.
    
    func callBack(key: Resources, value: Double) {
        print("StateValuesView with key \(key) and value \(value) called.")
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
