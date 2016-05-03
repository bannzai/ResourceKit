//
//  StoryboardTests.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import XCTest
@testable import ResourceKitDemo

class ViewControllerFromStoryboardTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPerformanceExample() {
        self.measureBlock {
        }
    }
    
    func testInitialViewController() {
        XCTAssertTrue(ViewController.initialViewController().isMemberOfClass(ViewController))
    }
    
    func testInstanceFromViewController() {
        XCTAssertTrue(ViewController.instanceFromInstanceFromOverride().isMemberOfClass(ViewController))
    }
    
    func testSegueIdentifier() {
        XCTAssertTrue(ViewController.Segue.showSecondTable == "ShowSecondTable")
    }
}
