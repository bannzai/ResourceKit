//
//  XibTests.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import XCTest
@testable import ResourceKitDemo

class XibTests: XCTestCase {
    
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
    
    func testName() {
        XCTAssertTrue(CustomView.Xib().name == "CustomView")
    }
    
    func testView() {
        XCTAssertTrue(CustomView.Xib().view().isMemberOfClass(CustomView))
    }
}
