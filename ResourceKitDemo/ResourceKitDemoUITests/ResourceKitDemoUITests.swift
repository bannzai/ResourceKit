//
//  ResourceKitDemoUITests.swift
//  ResourceKitDemoUITests
//
//  Created by kingkong999yhirose on 2016/04/10.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import XCTest

class ResourceKitDemoUITests: XCTestCase {
        
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
    
    func testCollection_Custom_SecondCollection_SecondCustom_SecondCollection() {
        let app = XCUIApplication()
        app.tabBars.children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()
        app.collectionViews.images["ninniku"].tap()
        app.buttons["SecondCollectionViewController"].tap()
        app.collectionViews.cells.staticTexts["52"].tap()
        app.buttons["SecondCollectionViewController"].tap()
    }
    
    func testTable_Custom_SecondTable_SecondCustom_SecondTable() {
        let app = XCUIApplication()
        app.tables.children(matching: .cell).element(boundBy: 0).staticTexts["hello world 4"].tap()
        app.buttons["SecondTableViewController"].tap()
        app.tables.children(matching: .cell).element(boundBy: 1).staticTexts["Second"].tap()
        app.buttons["SecondTableViewController"].tap()
    }
    
    
}
