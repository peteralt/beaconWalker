//
//  BeaconSequence.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import UIKit

class BeaconSequence {
    
    private var beacons : [Beacon]!
    private var sequenceRunning = false
    
    private var sequenceTimer : NSTimer!
    private var sequenceIndex = 0
    
    private var delegate : BeaconSequenceDelegate?
    
    init(beacons: [Beacon], delegate: BeaconSequenceDelegate?) {
        self.beacons = beacons
        self.delegate = delegate
    }
    
    func startSequence() {
        self.sequenceIndex = 0
        self.sequenceTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.progressTimer), userInfo: nil, repeats: false)
    }
    
    func stopSequence() {
        self.sequenceTimer?.invalidate()
    }
    
    @objc func progressTimer() {
        print("step reached: \(self.sequenceIndex), next delay: \(self.getDelayForCurrentBeacon())")
        
        let beacon = self.beacons[self.sequenceIndex]
        
        if !beacon.isActive {
           self.stepSequence()
            self.sequenceTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.progressTimer), userInfo: nil, repeats: false)
            return
        }
        
        delegate?.beaconDidProgress(beacon, index: self.sequenceIndex)
        
        self.sequenceTimer = NSTimer.scheduledTimerWithTimeInterval(self.getDelayForCurrentBeacon(), target: self, selector: #selector(self.progressTimer), userInfo: nil, repeats: false)
        
        self.stepSequence()
        
    }

}

//MARK: Helpers

extension BeaconSequence {
    
    private func stepSequence() {
        self.sequenceIndex += 1
        
        if self.sequenceIndex >= self.beacons.count {
            self.sequenceIndex = 0
        }
    }
    
    private func getDelayForBeaconAtIndex(index: Int) -> Double {
        return self.beacons[index].duration
    }
    
    private func getDelayForCurrentBeacon() -> Double {
        return self.getDelayForBeaconAtIndex(self.sequenceIndex)
    }
}