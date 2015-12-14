//
//  UIControlTests.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/13/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import XCTest
@testable import NXSS

class UIControlTests: XCTestCase {
    
    private var control:UIControl = UIControl()
    
    override func setUp() {
        super.setUp()
        
        NXSS.sharedInstance.useFile("UIControlTests",bundle: NSBundle(forClass: self.dynamicType ))
        
        control = UIButton()
        control.nxss = "SButton"

    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testElementInheritance() {
        control.applyNXSS()
        XCTAssert( control.layer.cornerRadius == 1 , "Must be equal")
        XCTAssert( control.layer.borderWidth == 1 , "Must be equal")
    }
    
    func testNormal() {
        assertNormal()
    }
    
    func testSelected() {
        control.selected = true
        assertSelected()
    }
    
    func testHighlighted() {
        control.highlighted = true
        assertHighlighted()
    }
    
    func testDisabled() {
        control.enabled = false
        assertDisabled()
    }
    
    func testCombination() {
        control = UIButton()
        control.nxss = "SButton"
        
        // Normal
        assertNormal()
        
        // Highlighted
        control.highlighted = true
        assertHighlighted()
        
        // Selected
        control.highlighted = false
        control.selected = true
        assertSelected()
        
        // Highlighted
        control.selected = false
        control.highlighted = true
        assertHighlighted()
        
        // Normal
        control.highlighted = false
        assertNormal()
        
    }
    
    private func assertNormal() {
        control.applyNXSS()
        XCTAssert( control.backgroundColor == UIColor.blueColor() , "Must be equal")
    }
    
    private func assertHighlighted() {
        control.applyNXSS()
        XCTAssert( control.backgroundColor == UIColor.greenColor() , "Must be equal")
    }
    
    private func assertSelected() {
        control.applyNXSS()
        XCTAssert( control.backgroundColor == UIColor.redColor() , "Must be equal")
    }
    
    private func assertDisabled() {
        control.applyNXSS()
        XCTAssert( control.backgroundColor == UIColor.grayColor() , "Must be equal")
    }
}