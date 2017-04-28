//
//  IDGenerator.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 27.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

class IDGenerator {
    
    // MARK: - Variables.
    
    static let instance: IDGenerator = {
        return IDGenerator()
    }()
    
    fileprivate var currentTopId = -1
    
    // MARK: - Methods.
    
    private init() {}
    
    func createID() -> Int {
        currentTopId += 1
        return currentTopId
    }
}
