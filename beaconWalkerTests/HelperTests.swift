//
//  HelperTests.swift
//  beaconWalkerTests
//
//  Created by Peter Alt on 5/1/18.
//  Copyright © 2018 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class HelperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreatingDemoFile() {
        
        let destPath = Helper.getDocumentsDirectory().path + Helper.Settings.beaconDemoFileName
        
        // remove the file if it exists
        if FileManager.default.fileExists(atPath: destPath) {
            do {
                try FileManager.default.removeItem(atPath: destPath)
            } catch {
                print(error)
            }
        }
        
        // verify it's gone
        XCTAssertFalse(FileManager.default.fileExists(atPath: destPath))
        // create it
        Helper.saveDemoFileToDocumentsDirectory()
        // verify it's there
        XCTAssertTrue(FileManager.default.fileExists(atPath: destPath))
    }
    
}
