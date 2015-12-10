//
//  UIColor+Applicator.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/3/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func fromNXSS( string : String ) throws -> UIColor {
        
        if string[0] == "#" {
            // Hex
            return UIColor(hex:string)
            
        } else if string.hasPrefix("rgb") {
            
            // Let's see if there's any alpha involved.
            // This one is either e.g. rgb(1,1,1) or rgba(255,255,255,1)
        
            let (name,args) = try FunctionHeader.parse(string)
        
            let red = try args[0].toCGFloat() / 255.0
            let blue = try args[1].toCGFloat() / 255.0
            let green = try  args[2].toCGFloat() / 255.0
            let alpha = args.count == 4 ? try args[3].toCGFloat() : 1.0
            
            if name == "rgba" {
                assert(args.count == 4 , "UIColor.nxssColor: 'rgba' is mentioned but there is no alpha specified: \(string)")
            }
            
            return UIColor(red:red,green:green,blue:blue,alpha:alpha)
                
            
        } else if string == "black" {
            return UIColor.blackColor()
            
        } else if string == "darkGray" {
            return UIColor.darkGrayColor()
            
        } else if string == "lightGray" {
            return UIColor.lightGrayColor()
            
        } else if string == "white" {
            return UIColor.whiteColor()
            
        } else if string == "gray" {
            return UIColor.grayColor()
            
        } else if string == "red" {
            return UIColor.redColor()
            
        } else if string == "green" {
            return UIColor.greenColor()
            
        } else if string == "blue" {
            return UIColor.blueColor()
            
        } else if string == "cyan" {
            return UIColor.cyanColor()
            
        } else if string == "yellow" {
            return UIColor.yellowColor()
            
        } else if string == "magenta" {
            return UIColor.magentaColor()
            
        } else if string == "orange" {
            return UIColor.orangeColor()
            
        } else if string == "purple" {
            return UIColor.purpleColor()
            
        } else if string == "brown" {
            return UIColor.brownColor()
            
        } else if string == "clear" {
            return UIColor.clearColor()
        }
        
        throw NXSSError.Parse(msg: "UIColor.fromNXSS unable to parse", statement: string, line:nil)
        
    }
    
}

// MARK: - Hex

extension UIColor {
    /**
        Convenience init with Hex and Alpha=1.0
        - parameters:
            - hex     With or without pound '#' prefix
    */
    public convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
    
    /**
        Convenience init with Hex and Alpha
        - parameters:   
            - hex     With or without pound '#' prefix
    */
    public convenience init(hex: String, alpha: CGFloat) {
        
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count == 6) {
            
            let rString = cString.substringToIndex(cString.startIndex.advancedBy(2))
            let gString = cString.substringFromIndex(cString.startIndex.advancedBy(2)).substringToIndex(cString.startIndex.advancedBy(2))
            let bString = cString.substringFromIndex(cString.startIndex.advancedBy(4)).substringToIndex(cString.startIndex.advancedBy(2))
            
            var rI:CUnsignedInt = 0, gI:CUnsignedInt = 0, bI:CUnsignedInt = 0;
            NSScanner.localizedScannerWithString(rString).scanHexInt(&rI)
            NSScanner.localizedScannerWithString(gString).scanHexInt(&gI)
            NSScanner.localizedScannerWithString(bString).scanHexInt(&bI)
            
            let red : CGFloat = CGFloat(rI) / 255.0
            let green : CGFloat = CGFloat(gI) / 255.0
            let blue : CGFloat = CGFloat(bI) / 255.0
            self.init(red:red,green:green,blue:blue,alpha:alpha)
            
        }
        else
        {
            print("Error: UIColor does not receive valid hex characters \(hex)", terminator: "")
            self.init()
        }
    }
}