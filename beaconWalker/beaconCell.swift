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
    @IBOutlet weak var uuidLabel: UILabel!
    
    @IBOutlet weak var activeToggle: UIButton!
    @IBOutlet weak var progressView : UIProgressView!
    
    var beacon : Beacon!
    
    //MARK: Init & Setup
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.aliasLabel.text = nil
        self.uuidLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        self.aliasLabel.text = nil
        self.majorLabel.text = nil
        self.minorLabel.text = nil
        self.uuidLabel.text = nil
        self.progressView.setProgress(0, animated: false)
        
        
    }
    
    func setup(_ beacon: Beacon) {
        
        self.beacon = beacon
        
        self.aliasLabel.text = beacon.alias
        self.majorLabel.text = String(beacon.major)
        self.minorLabel.text = String(beacon.minor)
        self.uuidLabel.text = String(beacon.UUID)
        
        
        
        self.setupActive(beacon.isActive)
        
        self.progressView.transform = CGAffineTransform(rotationAngle: 90 * .pi/180)
        
        if self.beacon.hasBeenSequenced {
            self.highlightCell()
            self.progressView.setProgress(1, animated: false)
        } else {
            self.unhighlightCell()
            self.progressView.setProgress(0, animated: false)
        }
        
    }
    
}

//MARK: Outlets

extension beaconCell {

    @IBAction func toggleActive() {
        if self.beacon.isActive {
            self.setInactive()
            self.activeToggle.setTitle("OFF", for: UIControl.State())
        } else {
            self.setActive()
            self.activeToggle.setTitle("ON", for: UIControl.State())
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
    
    func setupActive(_ isActive: Bool) {
        if isActive {
            self.setActive()
        } else {
            self.setInactive()
        }
    }
    
    

}

//MARK: Cell Animation
extension beaconCell {
    
    func highlightCell() {
        self.layer.backgroundColor = Helper.getColorGrey().cgColor
    }
    
    func unhighlightCell() {
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func animateDuration(_ beacon: Beacon) {
        self.resetDurationProgress()
        
        UIView.animate(
            withDuration: beacon.duration,
            animations: { [unowned self] in
                self.progressView?.setProgress(1.0, animated: true)
            }
        )
        
        UIView.animate(withDuration: 1.0, animations: {
            self.highlightCell()
            })
        
    }
    
    func resetDurationProgress() {
        UIView.animate(
            withDuration: 0.1,
            animations: { [unowned self] in
                self.progressView?.setProgress(0, animated: true)
            }
        )

    }
    
}
