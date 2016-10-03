//
//  beaconCell.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import UIKit

class beaconCell: UITableViewCell {
    
    @IBOutlet weak var aliasLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    
    @IBOutlet weak var activeToggle: UIButton!
    @IBOutlet weak var progressView : UIProgressView!
    
    var beacon : Beacon!
    
    //MARK: Init & Setup
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.aliasLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        self.aliasLabel.text = nil
        self.majorLabel.text = nil
        self.minorLabel.text = nil
        self.progressView.setProgress(1, animated: false)
    }
    
    func setup(beacon: Beacon) {
        
        self.beacon = beacon
        
        self.aliasLabel.text = beacon.alias
        self.majorLabel.text = String(beacon.major)
        self.minorLabel.text = String(beacon.minor)
        
        self.progressView.setProgress(1, animated: false)
        
        self.setupActive(beacon.isActive)
        
        self.progressView.transform = CGAffineTransformMakeRotation(90 * CGFloat(M_PI)/180)
        
    }
    
}

//MARK: Outlets

extension beaconCell {

    @IBAction func toggleActive() {
        if self.beacon.isActive {
            self.setInactive()
            self.activeToggle.setTitle("OFF", forState: .Normal)
        } else {
            self.setActive()
            self.activeToggle.setTitle("ON", forState: .Normal)
        }
    }
    
}


//MARK: Active State

extension beaconCell {
    
    func setActive() {
        self.beacon.isActive = true
        self.activeToggle.backgroundColor = Helper.getColorGreen()
    }
    
    func setInactive() {
        self.beacon.isActive = false
        self.activeToggle.backgroundColor = Helper.getColorRed()
    }
    
    func setupActive(isActive: Bool) {
        if isActive {
            self.setActive()
        } else {
            self.setInactive()
        }
    }
    
    

}

//MARK: Cell Animation
extension beaconCell {
    func animateDuration(beacon: Beacon) {
        self.resetDurationProgress()
        
        UIView.animateWithDuration(
            beacon.duration,
            animations: { [unowned self] in
                self.progressView?.setProgress(1.0, animated: true)
            }
        )
        
        UIView.animateWithDuration(1.0, animations: {
            self.layer.backgroundColor = Helper.getColorGrey().CGColor
        })
    }
    
    func resetDurationProgress() {
        UIView.animateWithDuration(
            0.1,
            animations: { [unowned self] in
                self.progressView?.setProgress(0, animated: true)
            }
        )
    }
    
}
