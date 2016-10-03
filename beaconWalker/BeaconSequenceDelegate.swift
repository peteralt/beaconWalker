//
//  BeaconSequenceDelegare.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

protocol BeaconSequenceDelegate : class {
    func beaconDidProgress(beacon: Beacon, index: Int)
}