//
//  Helper.swift
//  beaconWalker
//
//  Created by Peter.Alt on 10/3/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    //MARK: Settings
    
    struct Settings {
        static let beaconDemoFileName = "/beacons_demo.json"
        static let beaconDefaultUUID = "f7826da6-4fa2-4e98-8024-bc5b71e0893e"
        static let beaconDefaultDuration : Double = 5.0
    }
    
    //MARK: Colors
    
    // color scheme: https://color.adobe.com/Summer-Twilight-color-theme-8675918/edit/?copy=true&base=2&rule=Custom&selected=0&name=Copy%20of%20Summer%20Twilight&mode=rgb&rgbvalues=0.23137254901960785,0.34901960784313724,0.41568627450980394,0.25882352941176473,0.4627450980392157,0.4627450980392157,0.24705882352941178,0.6039215686274509,0.5098039215686274,0.6313725490196078,0.803921568627451,0.45098039215686275,0.9254901960784314,0.8588235294117647,0.3764705882352941&swatchOrder=0,1,2,3,4
    fileprivate static let colorRed = "E14E52"
    fileprivate static let colorGreen = "A1CD73"
    fileprivate static let colorGrey = "E2E5ED"
    fileprivate static let colorGreenDark = "3F9A82"
    fileprivate static let colorYellow = "ECDB60"
    
    static func getColorRed() -> UIColor {
        return self.hexStringToUIColor(self.colorRed)
    }
    
    static func getColorGreen() -> UIColor {
        return self.hexStringToUIColor(self.colorGreen)
    }
    
    static func getColorGrey() -> UIColor {
        return self.hexStringToUIColor(self.colorGrey)
    }
    
    static func getColorGreenDark() -> UIColor {
        return self.hexStringToUIColor(self.colorGreenDark)
    }
    
    static func getColorYellow() -> UIColor {
        return self.hexStringToUIColor(self.colorYellow)
    }

    // http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
    fileprivate static func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
        }
        // replace with count for latest SWIFT version
        if (cString.characters.count != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //MARK: Version Info
    
    static func getBuildVersion() -> String {
        let appInfo = Bundle.main.infoDictionary as Dictionary<String,AnyObject>!
        let bundleVersion      = appInfo?["CFBundleVersion"] as! String
        return bundleVersion
    }
    
    static func getVersion() -> String {
        let appInfo = Bundle.main.infoDictionary as Dictionary<String,AnyObject>!
        let shortVersionString = appInfo?["CFBundleShortVersionString"] as! String
        return shortVersionString
    }
    
    //MARK: Filesystem
    
    static func getDocumentsDirectory() -> String {
        let dir = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir.path
    }
    
    static func getAllJSONFiles() -> [URL]? {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            return directoryContents.filter{ $0.pathExtension == "json" }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    //MARK: Simulator detection
    
    struct Platform {
        
        static var isSimulator: Bool {
            return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        }
        
    }
}
