//
//  Beacon.swift
//  beaconWalker
//
//  Created by Peter.Alt on 9/20/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import Foundation

class Beacon {
    
    let major: Int
    let minor: Int
    let UUID: String
    let alias: String
    let uniqueID: String?
    let duration: Double
    
    var TTL: Float = 5
    
    var isActive : Bool = true
    
    var hasBeenSequenced : Bool = false
    
    init(major: Int, minor: Int, uniqueID: String?, UUID: String?, alias: String, duration: Double?) {
        self.major = major
        self.minor = minor
        if UUID != nil {
            self.UUID = UUID!
        } else {
            self.UUID = Helper.Settings.beaconDefaultUUID
        }
        
        if duration != nil {
            self.duration = duration!
        } else {
            self.duration = Helper.Settings.beaconDefaultDuration
        }
        
        self.uniqueID = uniqueID
        self.alias = alias
    }
    
    private static let testFilePath = NSBundle.mainBundle().pathForResource("beacons_test", ofType: "json")
    
    private static let urlForTest : NSURL = NSURL.fileURLWithPath(testFilePath!)
    
    private static let session: NSURLSession = NSURLSession.sharedSession()
    
    static var beacons : [Beacon] = []
    
    func isEqualTo(beacon: Beacon) -> Bool {
        return (beacon.major == self.major && beacon.minor == self.minor && beacon.UUID == self.UUID)
    }
    
}

    extension Beacon {
        
        static func load(forTesting: Bool = false, filePath: NSURL?, completion: ([Beacon]) -> Void) {
            
            var url : NSURL!
            
            if forTesting {
                url = self.urlForTest
            } else {
                url = filePath
            }
            
            let task = session.dataTaskWithURL(url, completionHandler: { data, _,_ in
                var beacons : [Beacon] = []
                
                var jsonDictionary : NSDictionary
                do {
                    jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as! NSDictionary
                    if let devices = jsonDictionary["devices"] as? NSArray {
                        for device in devices {
                            if let major = device.valueForKey("major") as? Int, minor = device.valueForKey("minor") as? Int, alias = device.valueForKey("alias") as? String {
                                let beacon = Beacon(major: major, minor: minor, uniqueID: device.valueForKey("uniqueId") as? String, UUID: device.valueForKey("UUID") as? String, alias: alias, duration: device.valueForKey("duration") as? Double)
                                beacons.append(beacon)
                            }
                        }
                    }
                } catch {
                    print(error)
                }
                self.beacons = beacons
                completion(beacons)
            })
            task.resume()
        }
        
        static func createDemoFile() {
            // Copying a demo JSON file on first launch
            let bundlePath = NSBundle.mainBundle().pathForResource("beacons_test", ofType: "json")
            let destPath = Helper.getDocumentsDirectory().stringByAppendingString(Helper.Settings.beaconDemoFileName)
            
            if !NSFileManager.defaultManager().fileExistsAtPath(destPath) {
                do {
                    try NSFileManager.defaultManager().copyItemAtPath(bundlePath!, toPath: destPath)
                } catch {
                    print(error)
                }
            }
        }
    }
