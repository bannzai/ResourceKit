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
        self.measure {
        }
    }
    
    func testInitialViewController() {
        XCTAssertTrue(ViewController.initialViewController().isMember(of: ViewController.classForCoder()))
    }
    
    func testInstanceFromViewController() {
        XCTAssertTrue(ViewController.instanceFromInstanceFromOverride().isMember(of: ViewController.classForCoder()))
    }
    
    func testSegueIdentifier() {
        XCTAssertTrue(ViewController.Segue.showSecondTable == "ShowSecondTable")
    }
}
