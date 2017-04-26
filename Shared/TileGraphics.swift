//
//  TileGraphics.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 12.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

struct TileGraphics: VisualRepresentation {
    
    typealias T = SKTileDefinition
    
    func retrieveVisual() -> T {
        return SKTileDefinition()
    }
}
