//
//  VariableParseTests.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 3/23/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

import XCTest
@testable import NXSS

class VariableParseTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func startNXSS(fileName:String) {
        NXSS.sharedInstance.useFile(fileName, bundle: NSBundle(forClass: self.dynamicType ))
    }
    
    func testReading() {
        startNXSS("variableparse_reading")
        XCTAssert(NXSS.sharedInstance.getVariableValue("name1")! == "value1")
        XCTAssert(NXSS.sharedInstance.getVariableValue("name2")! == "value2")
        XCTAssert(NXSS.sharedInstance.getVariableValue("name3")! == "value 3")
        XCTAssert(NXSS.sharedInstance.getVariableValue("noDollarSign") == nil)
        XCTAssert(NXSS.sharedInstance.getVariableValue("insideOtherScope") == nil)
        XCTAssert(NXSS.sharedInstance.getVariableValue("empty") == nil)
    }
    
    func testColor() {
        startNXSS("variableparse_color")
        XCTAssert(NXSS.sharedInstance.getUIColor("color1")! == UIColor.redColor())
        XCTAssert(NXSS.sharedInstance.getUIColor("color2")! == UIColor(red: 255, green: 255, blue: 255, alpha: 1))
        XCTAssert(NXSS.sharedInstance.getUIColor("color3")! == UIColor(hex: "#AABBCC"))
        XCTAssert(NXSS.sharedInstance.getUIColor("invalidColor") == nil)
        XCTAssert(NXSS.sharedInstance.getUIColor("invalidColorEmpty") == nil)
    }
}