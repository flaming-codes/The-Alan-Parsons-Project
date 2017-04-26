//
//  Resources.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 16.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

/// Represents every possible resource available in the game.
///
/// - Coal:     Basic resource coal.
/// - Stone:    Basic resource stone.
/// - Gold:     Basic resource gold.
enum Resources : Hashable {
    case Coal
    case Stone
    case Gold
}
