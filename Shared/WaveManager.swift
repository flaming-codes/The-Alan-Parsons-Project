//
//  File.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 05.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import SpriteKit

class WaveManager {
    
    // MARK: - Variables.
    
    static let shared: WaveManager = {
        return WaveManager()
    }()
    
    var timerCount = 0
    var spawnTimer = Timer()
    var interval: TimeInterval = 3
    
    // MARK: - Methods.
    
    @objc func start(withInterval: TimeInterval = -1) {
        if spawnTimer.isValid {
            spawnTimer.invalidate()
        }
                
        spawnTimer = Timer.scheduledTimer(timeInterval:  withInterval == -1 ? interval : withInterval, target: self, selector: #selector(start(withInterval:)), userInfo: nil, repeats: false)
    }
    
    @objc func force(stopInSeconds: TimeInterval) {
        Timer.scheduledTimer(timeInterval: stopInSeconds, target: self, selector: #selector(stopSpawnTimer), userInfo: nil, repeats: false)
    }
    
    @objc func force(researtInSeconds: TimeInterval, isRepeating: Bool = false) {
        Timer.scheduledTimer(timeInterval: researtInSeconds, target: self, selector: #selector(start(withInterval:)), userInfo: nil, repeats: isRepeating)
    }
    
    @objc fileprivate func stopSpawnTimer() {
        track(.I, "", self)
        spawnTimer.invalidate()
    }
    
}
