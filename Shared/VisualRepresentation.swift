//
//  VisualRepresentation.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 12.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

@available(*, deprecated)
protocol VisualRepresentation {
    typealias T = SKTileDefinition
    
    func retrieveVisual() -> T
}
