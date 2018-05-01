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
    
    fileprivate static let testFilePath = Bundle.main.path(forResource: "beacons_test", ofType: "json")
    
    fileprivate static let urlForTest : URL = URL(fileURLWithPath: testFilePath!)
    
    fileprivate static let session: URLSession = URLSession.shared
    
    static var beacons : [Beacon] = []
    
    func isEqualTo(_ beacon: Beacon) -> Bool {
        return (beacon.major == self.major && beacon.minor == self.minor && beacon.UUID == self.UUID)
    }
    
}

    extension Beacon {
        
        static func load(_ forTesting: Bool = false, filePath: URL?, completion: @escaping ([Beacon]) -> Void) {
            
            var url : URL!
            
            if forTesting {
                url = self.urlForTest
            } else {
                url = filePath
            }
            
            let task = session.dataTask(with: url, completionHandler: { data, _,_ in
                var beacons : [Beacon] = []
                
                var jsonDictionary : NSDictionary
                do {
                    jsonDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! NSDictionary
                    if let devices = jsonDictionary["devices"] as? NSArray {
                        for device in devices {
                            if let major = (device as AnyObject).value(forKey: "major") as? Int, let minor = (device as AnyObject).value(forKey: "minor") as? Int, let alias = (device as AnyObject).value(forKey: "alias") as? String {
                                let beacon = Beacon(major: major, minor: minor, uniqueID: (device as AnyObject).value(forKey: "uniqueId") as? String, UUID: (device as AnyObject).value(forKey: "UUID") as? String, alias: alias, duration: (device as AnyObject).value(forKey: "duration") as? Double)
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
            let bundlePath = Bundle.main.path(forResource: "beacons_test", ofType: "json")
            let destPath = Helper.getDocumentsDirectory() + Helper.Settings.beaconDemoFileName
            
            Helper.saveDemoFileOnFirstAppStart()
            
            
            if !FileManager.default.fileExists(atPath: destPath) {
                do {
                    try FileManager.default.copyItem(atPath: bundlePath!, toPath: destPath)
                    
                } catch {
                    print(error)
                }
            }
        }
    }
