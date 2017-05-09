//
//  ViewHelper.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 09.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class ViewHelper {
    
    private init() {}
    
    static func addToChild(elements: [SKNode], parent: SKNode) {
        for node in elements {
            parent.addChild(node)
        }
    }
    
    static func correctlyAlignElements(elements: [SKNode], lengthPerElement: Int, spacing: Int) {
        let offset: CGFloat = CGFloat(((elements.count * lengthPerElement) + (elements.count * spacing)) / 2)
        var count = 0
        
        for element in elements {
            let oldPos = element.position
            let positiveAdjustment = CGFloat(((spacing + lengthPerElement) * count) + (lengthPerElement / 2))
            element.position = CGPoint(x: oldPos.x - offset + positiveAdjustment, y: oldPos.y)
            
            count += 1
        }
    }
}
