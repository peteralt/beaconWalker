//
//  BeaconSequence.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import UIKit

class BeaconSequence {
    
    fileprivate var beacons : [Beacon]!
    fileprivate var sequenceRunning = false
    
    fileprivate var sequenceTimer : Timer!
    fileprivate var sequenceIndex = 0
    
    fileprivate var delegate : BeaconSequenceDelegate?
    
    init(beacons: [Beacon], delegate: BeaconSequenceDelegate?) {
        self.beacons = beacons
        self.delegate = delegate
    }
    
    func startSequence() {
        self.sequenceIndex = 0
        self.sequenceTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.progressTimer), userInfo: nil, repeats: false)
    }
    
    func stopSequence() {
        self.sequenceTimer?.invalidate()
        for beacon in self.beacons {
            beacon.hasBeenSequenced = false
        }
    }
    
    @objc func progressTimer() {
        print("step reached: \(self.sequenceIndex), next delay: \(self.getDelayForCurrentBeacon())")
        
        let beacon = self.beacons[self.sequenceIndex]
        
        if !beacon.isActive {
           self.stepSequence()
            self.sequenceTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.progressTimer), userInfo: nil, repeats: false)
            return
        }
        
        delegate?.beaconDidProgress(beacon, index: self.sequenceIndex)
        
        self.sequenceTimer = Timer.scheduledTimer(timeInterval: self.getDelayForCurrentBeacon(), target: self, selector: #selector(self.progressTimer), userInfo: nil, repeats: false)
        
        self.stepSequence()
        
    }

}

//MARK: Helpers

extension BeaconSequence {
    
    fileprivate func stepSequence() {
        self.sequenceIndex += 1
        
        if self.sequenceIndex >= self.beacons.count {
            self.sequenceIndex = 0
        }
    }
    
    fileprivate func getDelayForBeaconAtIndex(_ index: Int) -> Double {
        print("delay for beacon at index \(index): \(self.beacons[index].duration)")
        return self.beacons[index].duration
    }
    
    fileprivate func getDelayForCurrentBeacon() -> Double {
        return self.getDelayForBeaconAtIndex(self.sequenceIndex)
    }
}
