//
//  SKEnhancedMap.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 11.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class SKEnhancedMap: SKTileMapNode {
    
    // MARK: - Variables.
    
    // MARK: - Interactions.
    
    #if os(OSX)
    
    override func mouseDown(with event: NSEvent) {
        track(.I, "", self)
    }
    
    #endif
}
