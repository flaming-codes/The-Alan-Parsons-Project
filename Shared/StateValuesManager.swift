//
//  StateValuesManager.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 15.04.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

class StateValuesManager {
    
    // MARK: - Variables.

    var resourceCallbackReceiver: ResourceCallback? {
        willSet(newValue) {
            
            print("willSet() in StateValuesManager called.")
            
            for key in resources.keys {
                newValue?.callBack(key: key, value: resources[key]!)
            }
        }
    }
    
    static let sharedInstance: StateValuesManager = {
        return StateValuesManager()
    }()
    
    fileprivate var resources = [Resources: Double]()
    
    // MARK: - Methods.
    
    private init(){
        
        // Initialize the player's starting resources.
        resources.updateValue(100.0, forKey: Resources.Coal)
        resources.updateValue(100.0, forKey: Resources.Stone)
        resources.updateValue(100.0, forKey: Resources.Gold)
    }
    
    func fireCallback(key: Resources, val: Double) {
        resourceCallbackReceiver?.callBack(key: key, value: val)
    }
    
    func getValue(type: Resources) -> Double! {
        return resources[type]
    }
    
    func changeResourceValueTo(val: Double, type: Resources) -> Void {
        guard val >= 0.0 else {
            fatalError("StateValuesManager : changeResourceValueTo() : res isn't allowed to be < 0.")
        }
        
        resources.updateValue(val, forKey: type)
        fireCallback(key: type, val: val)
    }
    
    func changeResourceValueBy(val: Double, type: Resources) -> Void {
        let oldValue = resources[type]
        resources.updateValue(oldValue! - val, forKey: type)
        fireCallback(key: type, val: val)
    }
}
