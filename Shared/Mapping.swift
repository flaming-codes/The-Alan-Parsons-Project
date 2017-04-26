//
//  MapProtocol.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 11.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

protocol Mapping {
    associatedtype A
    associatedtype B
    
    static func map(a: A) -> B
}
