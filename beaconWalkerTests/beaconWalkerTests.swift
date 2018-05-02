//
//  beaconWalkerTests.swift
//  beaconWalkerTests
//
//  Created by Peter.Alt on 9/20/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class beaconWalkerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadingBeaconCount() {
        let _ = Beacon.load(true, filePath: nil, completion: { beacons in
            XCTAssertEqual(beacons.count, 3)
        })
    }
    
    func testLoadingBeaconDefinitions() {
        let _ = Beacon.load(true, filePath:nil, completion: { beacons in
            for beacon in beacons {
                
                // required attributes
                XCTAssertNotNil(beacon.alias)
                XCTAssertNotNil(beacon.major)
                XCTAssertNotNil(beacon.minor)
                
                
                // uniqueID is optional
                if beacon.major == 46453 {
                    XCTAssertNotNil(beacon.uniqueID)
                } else if beacon.major == 54733 {
                    XCTAssertNil(beacon.uniqueID)
                }
                
                // testing custom UUID
                if beacon.uniqueID == "et3h" {
                    XCTAssertEqual(beacon.UUID, "0299ed07-62a8-4766-9787-63d80972b295")
                }
                
                // testing fall-back default UUID
                if beacon.major == 54733 {
                    XCTAssertEqual(beacon.UUID, Helper.Settings.beaconDefaultUUID)
                }
                
                // testing custom duration
                if beacon.uniqueID == "OlDU" {
                    XCTAssertEqual(beacon.duration, 4.75)
                }
                
                // testing fall-back default duration
                if beacon.uniqueID == "et3h" {
                    XCTAssertEqual(beacon.duration, Helper.Settings.beaconDefaultDuration)
                }
            }
        })
    }
    
    func testBeaconIsEqualTo() {
        let beaconA = Beacon(major: 1111, minor: 2222, uniqueID: "ABC", UUID: nil, alias: "BeaconA", duration: nil)
        let beaconB = Beacon(major: 2222, minor: 3333, uniqueID: nil, UUID: nil, alias: "BeaconB", duration: 7.0)
        
        let beaconAClone = Beacon(major: 1111, minor: 2222, uniqueID: nil, UUID: nil, alias: "BeaconAClone", duration: 5.0)
        
        XCTAssertFalse(beaconA.isEqualTo(beaconB))
        XCTAssertTrue(beaconA.isEqualTo(beaconAClone))
    }
    
    
}
