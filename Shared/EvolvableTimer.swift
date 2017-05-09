//
//  Timing.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 06.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

protocol EvolvableTimer {
    func start(withDelayInSeconds: TimeInterval, isRepating: Bool)
    //func start(withInterval: TimeInterval, withDelayInSeconds: TimeInterval, isRepating: Bool, isEvolving: Bool)
    
    func stop(inSeconds: TimeInterval)
    func pause(inSeconds: TimeInterval)
}
