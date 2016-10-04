//
//  ViewController.swift
//  beaconWalker
//
//  Created by Peter.Alt on 9/20/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, BeaconSequenceDelegate {
    
    @IBOutlet weak var beaconTableView: UITableView!
    
    @IBOutlet weak var sequenceStatusView: UIView!
    @IBOutlet weak var bluetoothStatusView: UIView!
    @IBOutlet weak var accessStatusView: UIView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var activeSequenceView: UIView!
    @IBOutlet weak var activeSequenceHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currentFileLabel: UILabel!
    
    
    private var sequencePlaying = false
    private var beaconSequencer : BeaconSequence!
    
    private let locationManager = CLLocationManager()
    private let peripheralManager = CBPeripheralManager()
    
    private let defaultUUID = "f7826da6-4fa2-4e98-8024-bc5b71e0893e"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.activeSequenceHeightConstraint.constant = 0
        
        self.versionLabel.text = Helper.getVersion()
        self.currentFileLabel.text = ""
        
        // Copying a demo JSON file on first launch
        let bundlePath = NSBundle.mainBundle().pathForResource("beacons_test", ofType: "json")
        let destPath = Helper.getDocumentsDirectory().stringByAppendingString("/beacons_demo.json")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(destPath) {
            do {
                try NSFileManager.defaultManager().copyItemAtPath(bundlePath!, toPath: destPath)
            } catch {
                print(error)
            }
        }
        
        self.checkAppRequirements()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.bluetoothStatusView.layer.cornerRadius = self.bluetoothStatusView.frame.width / 2
        self.accessStatusView.layer.cornerRadius = self.accessStatusView.frame.width / 2
        
        self.choseBeaconFile()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.layoutIfNeeded()
    }
    
    @IBAction func choseBeaconFile() {
        let controller = UIAlertController(title: "Choose your data file", message: "Use iTunes to add JSON data files.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        if let files = Helper.getAllJSONFiles() {
        
            for file in files {
                controller.addAction(UIAlertAction(title: "\((file.URLByDeletingPathExtension?.lastPathComponent)!)", style: UIAlertActionStyle.Default, handler: { action in
                    
                    self.currentFileLabel.text = (file.URLByDeletingPathExtension?.lastPathComponent)!
                    
                    let _ = Beacon.load(filePath: file, completion: { beacons in
                        print("beacons loaded: \(beacons.count)")
                        dispatch_async(dispatch_get_main_queue()) {
                            self.beaconTableView.reloadData()
                            self.beaconSequencer = BeaconSequence(beacons: beacons, delegate: self)
                            
                        }
                    })
                    
                }))
            }
            controller.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func toggleSequence(sender: AnyObject) {
        
        if !(Beacon.beacons.count > 0) {
            return
        }
        
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        
        if !Helper.Platform.isSimulator {
        
            if !self.isBluetoothActive() || !self.areLocationServicesAllowed() {
                print("something isn't right, we need permissions")
                let alertController = UIAlertController(title: "Please verify settings", message: "This app requires Bluetooth to be enabled and access to Location Services (while in use only).\nPlease verify settings and try again.", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                }
                alertController.addAction(cancelAction)
                
                let settingsAction = UIAlertAction(title: "Go to Settings", style: .Default) { (action) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }
                alertController.addAction(settingsAction)
                
                self.presentViewController(alertController, animated: true) {}
                return
            }
        }
        
        self.checkAppRequirements()
        
        self.sequencePlaying = !self.sequencePlaying
        if self.sequencePlaying {
            
            self.beaconSequencer.startSequence()
            self.sequenceStatusView.backgroundColor = Helper.getColorGreen()
            sender.setTitle("Stop Sequence", forState: .Normal)
            
            self.activeSequenceHeightConstraint.constant = 40
            UIView.animateWithDuration(0.75, animations: {
                self.view.layoutIfNeeded()
            })
            self.animateActiveSequenceView()
            
            
        } else {
            self.beaconSequencer.stopSequence()
            self.sequenceStatusView.backgroundColor = Helper.getColorRed()
            sender.setTitle("Start Sequence", forState: .Normal)
            if let selectedRow = self.beaconTableView.indexPathForSelectedRow {
                self.beaconTableView.deselectRowAtIndexPath(selectedRow, animated: true)
            }
            self.activeSequenceHeightConstraint.constant = 0
            UIView.animateWithDuration(0.75, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func beaconDidProgress(beacon: Beacon, index: Int) {
        let indexPath = NSIndexPath(forItem: index, inSection: 0)
        self.beaconTableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Top)
        self.beaconTableView.delegate?.tableView!(self.beaconTableView, didSelectRowAtIndexPath: indexPath)
        self.advertiseBeacon(beacon)
    }
    
    func advertiseBeacon(beacon: Beacon) {
        
        self.peripheralManager.stopAdvertising()
        
        let region = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: beacon.UUID)!, major: UInt16(beacon.major), minor: UInt16(beacon.minor), identifier: "beaconWalker")
        
        let pd = NSDictionary(dictionary: region.peripheralDataWithMeasuredPower(nil)) as! [String: AnyObject]
        
        self.peripheralManager.startAdvertising(pd)
        
        
    }


}

extension ViewController {
    
    private func isBluetoothActive() -> Bool {
        return self.peripheralManager.state == .PoweredOn
    }
    
    // http://stackoverflow.com/questions/34861941/check-if-location-services-are-enabled-swift-ios-9
    private func areLocationServicesAllowed() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                print("Location Services: No access")
                return false
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("Location Services: Access")
                return true
            }
        } else {
            print("Location services are not enabled")
            return false
        }
    }
    
    private func animateActiveSequenceView() {
        let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
        colourAnim.fromValue = self.activeSequenceView.backgroundColor
        colourAnim.toValue = Helper.getColorYellow().CGColor
        colourAnim.duration = 2.0
        colourAnim.repeatCount = 5000
        colourAnim.autoreverses = true
        self.activeSequenceView.layer.addAnimation(colourAnim, forKey: "backgroundColorAnimation")
    }
    
    private func checkAppRequirements() {
        if self.isBluetoothActive() {
            self.bluetoothStatusView.backgroundColor = Helper.getColorGreenDark()
        } else {
            self.bluetoothStatusView.backgroundColor = Helper.getColorRed()
        }
        
        if self.areLocationServicesAllowed() {
            self.accessStatusView.backgroundColor = Helper.getColorGreenDark()
        } else {
            self.accessStatusView.backgroundColor = Helper.getColorRed()
        }
    }

}

