//
//  beaconTableViewDataSource.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import UIKit

class beaconTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Beacon.beacons.count
    }
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("beaconCell", forIndexPath: indexPath) as! beaconCell
        let beacon = Beacon.beacons[indexPath.item]
        
        cell.setup(beacon)
        cell.setNeedsLayout()
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("beaconCell", forIndexPath: indexPath) as! beaconCell
        let beacon = Beacon.beacons[indexPath.item]
        
        cell.setup(beacon)
        cell.setNeedsLayout()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! beaconCell
        let beacon = Beacon.beacons[indexPath.item]
        
        if indexPath.item == 0 {
            for cell in tableView.visibleCells as! [beaconCell] {
                cell.resetDurationProgress()
                cell.layer.backgroundColor = UIColor.clearColor().CGColor
            }
        }
        
        selectedCell.animateDuration(beacon)
    }

}
