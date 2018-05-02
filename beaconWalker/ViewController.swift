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
import MobileCoreServices

class ViewController: UIViewController, BeaconSequenceDelegate {
    
    @IBOutlet weak var beaconTableView: UITableView!
    
    @IBOutlet weak var sequenceStatusView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    
    
    @IBOutlet weak var startSequenceButton: UIButton!
    
    @IBOutlet weak var activeSequenceView: UIView!
    @IBOutlet weak var activeSequenceHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var currentFileLabel: UILabel!
    
    
    fileprivate var sequencePlaying = false
    fileprivate var beaconSequencer : BeaconSequence!
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate let peripheralManager = CBPeripheralManager()
    fileprivate let btManager = CBCentralManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.activeSequenceHeightConstraint.constant = 0
        
        self.versionLabel.text = Helper.getVersion()
        self.currentFileLabel.text = "Select Sequence"
        
//        Beacon.createDemoFile()
        Helper.saveDemoFileOnFirstAppStart()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let documentPickerController = UIDocumentPickerViewController(documentTypes: [String(kUTTypeJSON)], in: .import)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }
    
    @IBAction func activateSingleBeaconOnDoubleTap(_ sender: AnyObject) {
        
        if (sender.state == UIGestureRecognizerState.ended) {
         
            let touchLocation = sender.location(in: sender.view)
            let indexPath = self.beaconTableView.indexPathForRow(at: touchLocation)
            let cell = self.beaconTableView.cellForRow(at: indexPath!) as! beaconCell
            
            self.beaconTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            
            self.startSingleBeaconAdvertisement(cell.beacon, index: indexPath!.item)
            
            print("Found Cell: \(cell.beacon.alias)")
            
        }
        
    }
    
    @IBAction func tapViewToToggleSequence(_: AnyObject) {
        self.startSequenceButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func toggleSequence(_ : AnyObject) {
        
        self.checkAppRequirements()
        
        if !(Beacon.beacons.count > 0) {
            return
        }
        
        self.sequencePlaying = !self.sequencePlaying
        if self.sequencePlaying {
            self.startSequence()
        } else {
            self.stopSequence()
        }
    }
    
    func startSingleBeaconAdvertisement(_ beacon: Beacon, index: Int) {
        
        self.beaconSequencer.stopSequence()
        
        for cell in self.beaconTableView.visibleCells as! [beaconCell] {
            cell.resetDurationProgress()
            cell.layer.backgroundColor = UIColor.clear.cgColor
        }
        
        self.checkAppRequirements()
        
        self.sequenceStatusView.backgroundColor = Helper.getColorGreen()
        self.startSequenceButton.setTitle("Stop Advertisement", for: UIControlState())
        
        self.activeSequenceHeightConstraint.constant = 40
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        })
        self.beaconDidProgress(beacon, index: index)
        self.sequencePlaying = true
    }
    
    func startSequence() {
        self.beaconSequencer.startSequence()
        self.sequenceStatusView.backgroundColor = Helper.getColorGreen()
        self.startSequenceButton.setTitle("Stop Sequence", for: UIControlState())
        
        self.activeSequenceHeightConstraint.constant = 40
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        })
        self.animateActiveSequenceView()
        
        UIApplication.shared.isIdleTimerDisabled = true

    }
    
    func stopSequence() {
        self.beaconSequencer.stopSequence()
        self.sequenceStatusView.backgroundColor = Helper.getColorRed()
        self.startSequenceButton.setTitle("Start Sequence", for: UIControlState())
        if let selectedRow = self.beaconTableView.indexPathForSelectedRow {
            self.beaconTableView.deselectRow(at: selectedRow, animated: true)
        }
        self.activeSequenceHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.75, animations: {
            self.view.layoutIfNeeded()
        })
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func beaconDidProgress(_ beacon: Beacon, index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        self.beaconTableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        self.beaconTableView.delegate?.tableView!(self.beaconTableView, didSelectRowAt: indexPath)
        self.advertiseBeacon(beacon)
    }
    
    func advertiseBeacon(_ beacon: Beacon) {
        
        self.peripheralManager.stopAdvertising()
        
        let region = CLBeaconRegion(proximityUUID: UUID(uuidString: beacon.UUID)!, major: UInt16(beacon.major), minor: UInt16(beacon.minor), identifier: "beaconWalker")
        
        let pd = NSDictionary(dictionary: region.peripheralData(withMeasuredPower: nil)) as! [String: AnyObject]
        
        self.peripheralManager.startAdvertising(pd)
        
        
    }


}

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.currentFileLabel.text = (url.deletingPathExtension().lastPathComponent)

        let _ = Beacon.load(filePath: url, completion: { beacons in
            print("beacons loaded: \(beacons.count)")
            DispatchQueue.main.async {
                self.beaconTableView.reloadData()
                self.beaconSequencer = BeaconSequence(beacons: beacons, delegate: self)

            }
        })
    }
    
}

extension ViewController {
    
    fileprivate func isBluetoothActive() -> Bool {
        return self.btManager.state == .poweredOn
    }
    
    // http://stackoverflow.com/questions/34861941/check-if-location-services-are-enabled-swift-ios-9
    fileprivate func areLocationServicesAllowed() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                print("Location Services: No access")
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location Services: Access")
                return true
            }
        } else {
            print("Location services are not enabled")
            return false
        }
    }
    
    fileprivate func animateActiveSequenceView() {
        let colourAnim = CABasicAnimation(keyPath: "backgroundColor")
        colourAnim.fromValue = self.activeSequenceView.backgroundColor
        colourAnim.toValue = Helper.getColorYellow().cgColor
        colourAnim.duration = 2.0
        colourAnim.repeatCount = 5000
        colourAnim.autoreverses = true
        self.activeSequenceView.layer.add(colourAnim, forKey: "backgroundColorAnimation")
    }
    
    fileprivate func checkAppRequirements() {
        
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if !Helper.Platform.isSimulator {
            
            if !self.isBluetoothActive() || !self.areLocationServicesAllowed() {
                print("something isn't right, we need permissions")
                let alertController = UIAlertController(title: "Please verify settings", message: "This app requires Bluetooth to be enabled and access to Location Services (while in use only).\nPlease verify settings and try again.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                }
                alertController.addAction(cancelAction)
                
                let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
                    UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                }
                alertController.addAction(settingsAction)
                
                self.present(alertController, animated: true) {}
                return
            }
        }
        
    }
    
}

