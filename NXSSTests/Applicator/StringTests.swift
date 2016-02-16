//
//  StringTests.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/16/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation
import XCTest
@testable import NXSS

class StringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testToCGFloat()  {
        
        let a = try! "11.5".toCGFloat()
        XCTAssert( 11.5 == a , "Parsing decimal just failed")
        
        let b = try! " 11.2".toCGFloat()
        XCTAssert( 11.2 == b , "Parsing decimal just failed")
        
        let c = try! "11.9 ".toCGFloat()
        XCTAssert( 11.9 == c , "Parsing decimal just failed")

    }
    
}