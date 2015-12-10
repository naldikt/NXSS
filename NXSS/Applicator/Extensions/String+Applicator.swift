//
//  String+Applicator.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/11/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import CoreGraphics

extension String {
    
    /**
        If not parsable, will return 0.
    */
    func toCGFloat() throws -> CGFloat {
        if let n = NSNumberFormatter().numberFromString(self) {
            let f = CGFloat(n)
            return f
        }
        throw NXSSError.Parse(msg: "String.toCGFloat() unable to parse", statement: self, line:nil)
    }
}