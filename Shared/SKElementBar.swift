//
//  SKElementBar.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 10.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class SKElementBar<T: SKNode>: SKNode {
    
    // MARK: - Variables.
    //typealias T = N
    
    var elements = [T]() {
        willSet {
            track(.I, "About to change elements to:  \(newValue)", self)
            newValue.forEach{ addChild($0) }
        }
        
        didSet {
            correctlyAlignElements()
        }
    }
    
    var selection: T? {
        willSet {
            track(.I, "willSet in selection called", self)
            
            // Animate unselection of previous node selected.
            if let s = selection {
                if let unselect = unselectAnimation {
                    s.run(unselect)
                }
            }
            
            // DEBUG - DELETE ASAP
            //UserInteractionManager.instance.selection =
        }
        
        didSet {
            track(.I, "didSet in selection called", self)
            
            // Animate selection.
            if let select = selectAnimation {
                selection?.run(select)
            }
        }
    }
    
    let defaultLenghtOfOneElement: CGFloat
    let defaultSpacing: CGFloat
    var selectAnimation: SKAction?
    var unselectAnimation: SKAction?
    
    // MARK: - Initializers.
    
    init(defaultLenghtOfOneElement: CGFloat, defaultSpacing: CGFloat, isInteractionEnabled: Bool = false, withXscale xScale: CGFloat = 1, yScale: CGFloat = 1) {
        self.defaultLenghtOfOneElement = defaultLenghtOfOneElement
        self.defaultSpacing = defaultSpacing
        
        super.init()
        
        isUserInteractionEnabled = isInteractionEnabled
        self.xScale = xScale
        self.yScale = yScale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods.
    
    fileprivate func correctlyAlignElements() {
        let offset: CGFloat = CGFloat(((CGFloat(elements.count) * defaultLenghtOfOneElement) + (CGFloat(elements.count) * defaultSpacing)) / 2)
        var count: CGFloat = 0
        
        for element in elements {
            let oldPos = element.position
            let newCenter: CGFloat = (defaultSpacing + defaultLenghtOfOneElement) * count
            let positiveAdjustment = CGFloat(newCenter + (defaultLenghtOfOneElement / 2))
            element.position = CGPoint(x: oldPos.x - offset + positiveAdjustment, y: oldPos.y)
            
            count += 1
        }
    }
    
    // MARK: - Interactions.
    
    #if os(OSX)
    
    override func mouseDown(with event: NSEvent) {
        track(.I, "", self)
    }
    
    #endif
}
