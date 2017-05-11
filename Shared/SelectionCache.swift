//
//  SelectionCache.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 11.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

protocol SelectionCache {
    associatedtype T
    
    func select(type: T)
}
