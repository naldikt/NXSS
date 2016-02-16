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
        
        struct StringToCGFloatNumberFormatter_Static {
            static var onceToken: dispatch_once_t = 0
            static var numberFormatter: NSNumberFormatter? = nil
        }
        
        dispatch_once(&StringToCGFloatNumberFormatter_Static.onceToken) {
            StringToCGFloatNumberFormatter_Static.numberFormatter = NSNumberFormatter()
            if let numberFormatter = StringToCGFloatNumberFormatter_Static.numberFormatter {
                numberFormatter.decimalSeparator = "."
            }
        }
        
        let trimmedSelf = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if let numberFormatter = StringToCGFloatNumberFormatter_Static.numberFormatter , n = numberFormatter.numberFromString(trimmedSelf) {
            let f = CGFloat(n)
            return f
        }
        throw NXSSError.Parse(msg: "String.toCGFloat() unable to parse", statement: self, line:nil)
    }
}