//
//  Periodic.swift
//  The Alan Parsons Project
//
//  Created by Thomas Schönmann on 06.05.17.
//  Copyright © 2017 Thomas Schönmann. All rights reserved.
//

import Foundation

class EvolutionTimer: EvolvableTimer {
    
    typealias EvolutionLogic = ((EvolutionTimer, Any) -> ())
    var processEvolution: EvolutionLogic?
    var timer = Timer()
    let defaultInterval: TimeInterval
    var interval: TimeInterval
    var isEvolving = false
    var evolutionProvider: Any
    
    // MARK: Initializers.
    
    init(withInterval defaultInterval: TimeInterval, isEvolving: Bool = true, provider: Any) {
        // @escaping == Storing function for later, even if out of caller's lifetime.
        
        self.defaultInterval = defaultInterval
        self.interval = defaultInterval
        self.isEvolving = isEvolving
        self.evolutionProvider = provider
        
        track(.I, "defaultInterval: \(defaultInterval), interval: \(interval)", self)
    }
    
    func provideEvolutionFunction(toRun: @escaping (EvolutionTimer, Any) -> ()) {
        processEvolution = toRun
    }
    
    // MARK: - Methods.
    
    @objc func start(withDelayInSeconds: Double = 0.0, isRepating: Bool = false) {
        track(.I, "", self)
        if timer.isValid {
            timer.invalidate()
        }
        
        /*
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + withDelayInSeconds) {
            self.timer = Timer.scheduledTimer(timeInterval:  self.interval,
                                         target: self,
                                         selector: #selector(self.start(withInterval:withDelayInSeconds:isRepating:isEvolving:)),
                                         userInfo: nil,
                                         repeats: isRepating)
        }*/
        
        track(.I, "Assigning scheduledTimer to timer-var now.", self)
        self.timer = Timer.scheduledTimer(timeInterval:  self.interval,
                                          target: self,
                                          selector: #selector(runProvidedFunctionAndContinue),
                                          userInfo: nil,
                                          repeats: isRepating)
        
        track(.I, "End of method reached, will be dumped now", self)
    }
    
    func stop(inSeconds: TimeInterval = 0) {
        track(.I, "inSeconds: \(inSeconds)", self)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + inSeconds) {
            self.timer.invalidate()
        }
    }
    
    @available(*, unavailable)
    func pause(inSeconds: TimeInterval) {
        track(.E, "Unprovided", self)
        
        // TODO
        // To be added.
    }
    
    @objc func runProvidedFunctionAndContinue() {
        track(.I, "", self)
        
        // Every logic regarding the altering of this object's state
        // in the process of evolution is executed in the provided function.
        processEvolution?(self, evolutionProvider)
        
        if isEvolving {
            track(.I, "Evolving now", self)
            self.start()
            
        } else {
            track(.I, "No evolving chosen", self)
        }
        
        track(.I, "End of method reached, will be dumped now", self)
    }
    
}
