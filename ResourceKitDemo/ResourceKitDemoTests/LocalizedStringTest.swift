//
//  LocalizedStringTest.swift
//  ResourceKitDemo
//
//  Created by kingkong999yhirose on 2016/05/05.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import XCTest
@testable import ResourceKitDemo

class LocalizedStringTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testLocalizedString() {
        XCTAssertTrue(NSLocalizedString("hello world 4", comment: "") == String.Localized.hello_world_4)
        XCTAssertTrue(NSLocalizedString("hello.world 05", comment: "") == String.Localized.hello_world_05)
    }

}
