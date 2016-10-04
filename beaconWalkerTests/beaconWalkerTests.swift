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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testLoadingBeaconCount() {
        let _ = Beacon.load(true, filePath: nil, completion: { beacons in
            XCTAssertEqual(beacons.count, 3)
        })
    }
    
    func testLoadingBeaconDefinitions() {
        let _ = Beacon.load(true, filePath:nil, completion: { beacons in
            for beacon in beacons {
                XCTAssertNotNil(beacon.alias)
                XCTAssertNotNil(beacon.major)
                XCTAssertNotNil(beacon.minor)
                XCTAssertNotNil(beacon.uniqueID)
                if beacon.uniqueID == "OlDU" {
                    XCTAssertEqual(beacon.duration, 4.75)
                } else if beacon.uniqueID == "x0lw" {
                    XCTAssertEqual(beacon.duration, 2.0)
                }
            }
        })
    }
    
    
}
