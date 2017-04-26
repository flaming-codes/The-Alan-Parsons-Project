//
//  Callback.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 20.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation


/// Enables sending of String-information to superclasses.
protocol ResourceCallback {
    func callBack(key: Resources, value: Double)
}

protocol BuildingCallback {
    func add(key: BuildableUnitCategories, value: BuildableUnit)
    
    // Select may also handle unselection (only one building per time selectable).
    func select(key: BuildableUnitCategories, value: BuildableUnit)
}
