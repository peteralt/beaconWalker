//
//  beaconWalkerUITests.swift
//  beaconWalkerUITests
//
//  Created by Peter Alt on 10/5/16.
//  Copyright © 2016 Philadelphia Museum of Art. All rights reserved.
//

import XCTest

class beaconWalkerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDemoFilePopUp() {
        
        XCTAssertTrue(XCUIApplication().sheets["Choose your data file"].buttons["beacons_demo"].exists)
        XCTAssertEqual(XCUIApplication().sheets["Choose your data file"].buttons["beacons_demo"].label, "beacons_demo")
        
    }
    
    func testDisplayFileChooser() {
        
        let app = XCUIApplication()
        let chooseYourDataFileSheet = app.sheets["Choose your data file"]
        chooseYourDataFileSheet.buttons["Cancel"].tap()
        app.buttons["Folder"].tap()
        XCTAssertTrue(chooseYourDataFileSheet.exists)
        XCTAssertEqual(chooseYourDataFileSheet.buttons["beacons_demo"].label, "beacons_demo")
        
    }
    
}
