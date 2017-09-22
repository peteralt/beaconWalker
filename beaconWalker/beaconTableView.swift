//
//  beaconTableViewDataSource.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import UIKit

class beaconTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    @objc func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Beacon.beacons.count
    }
    
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: indexPath) as! beaconCell
        let beacon = Beacon.beacons[indexPath.item]
        
        cell.setup(beacon)
        cell.setNeedsLayout()
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: indexPath) as? beaconCell {
//        let beacon = Beacon.beacons[indexPath.item]
//        
//        cell.setup(beacon)
//        
//        cell.setNeedsLayout()
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beacon = Beacon.beacons[indexPath.item]
        if let selectedCell = tableView.cellForRow(at: indexPath) as? beaconCell {
            if indexPath.item == 0 {
                for cell in tableView.visibleCells as! [beaconCell] {
                    cell.resetDurationProgress()
                    cell.layer.backgroundColor = UIColor.clear.cgColor
                }
            }
            
            selectedCell.animateDuration(beacon)
        }
        beacon.hasBeenSequenced = true
    }

}
