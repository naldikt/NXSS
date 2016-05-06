//
//  CAGradientLayer+Applicator.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/6/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension CAGradientLayer {
    
    /**
        Multiple colors are to be distributed evenly.
     
        - parameters:
            - linearGradientString      Either linear-gradient( to bottom , topColor , nextColor, ... )  or   linear-gradient( to right , leftColor , nextColor,... )
                    The valid directions:   to bottom , to right , to bottom right, to right bottom
            - bounds                    The bounds of the view
    
        - return: The applied linear gradient.
    */
    class func fromNXSSLinearGradient( layer : CALayer , linearGradientString : String , bounds : CGRect ) throws -> CAGradientLayer {

        let (name,args) = try FunctionHeader.parse(linearGradientString)

        try NXSSError.throwIfNot( name == "linear-gradient" ,  msg: "applyLinearGradient requires string to be linear-gradient" ,  statement: linearGradientString , line:nil)
        try NXSSError.throwIfNot( args.count >= 3 , msg: "linear-gradient requires at least 3 arguments", statement: linearGradientString, line:nil)
        
        
        let directionStr = args[0]  // expected tobe: "to bottom" or "to right"
        let directionArr = directionStr.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        try NXSSError.throwIfNot(directionArr.count >= 1 && directionArr[0] == "to", msg: "The first word must be 'to'", statement:directionStr,line:nil)
        
        var colors : [UIColor] = []
        for i in 1..<args.count {
            let stringColor = args[i]
            do {
                let color = try UIColor.fromNXSS(stringColor)
                colors.append(color)
            } catch {
                throw NXSSError.Parse(msg: "Cannot parse color \(stringColor) as part of linear-gradient", statement: linearGradientString, line: nil)
            }
        }
        
        
        
        if directionArr.count == 2 {
            if directionArr[1] == "bottom" {
                return try CAGradientLayer.gradientLayerToBottom(bounds, colors:colors)
            } else if directionArr[1] == "right" {
                return try CAGradientLayer.gradientLayerToRight(bounds, colors:colors)
            } else {
                throw NXSSError.Parse(msg: "This direction should either be 'to bottom' or 'to right'", statement: directionStr, line: nil)
            }
        } else if directionArr.count == 3 {
            if (directionArr[1] == "bottom" && directionArr[2] == "right") {
                return try CAGradientLayer.gradientLayerToBottomRight(bounds, colors: colors)
            } else if (directionArr[1] == "bottom" && directionArr[2] == "left") {
                return try CAGradientLayer.gradientLayerToBottomLeft(bounds, colors: colors)
            } else {
                throw NXSSError.Parse(msg: "This direction should either be 'to bottom right' or 'to bottom left'", statement: directionStr, line: nil)
            }
        } else {
            throw NXSSError.Parse(msg:"This sentence is supposed to contain valid direction e.g. to bottom", statement:directionStr, line:nil)
        }

        
    }
    
    class func gradientLayerToBottom( bounds : CGRect , colors : [UIColor] )  throws -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPointMake(0.5,0.0)
        layer.endPoint = CGPointMake(0.5,1.0)
        layer.colors = colors.map { $0.CGColor }
        return layer
    }
    
    class func gradientLayerToRight( bounds : CGRect , colors : [UIColor] )  throws -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPointMake(0.0,0.5)
        layer.endPoint = CGPointMake(1.0,0.5)
        layer.colors = colors.map { $0.CGColor }
        return layer
    }
    
    class func gradientLayerToBottomRight( bounds : CGRect , colors : [UIColor] )  throws -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPointMake(0.0,0.0)
        layer.endPoint = CGPointMake(1.0,1.0)
        layer.colors = colors.map { $0.CGColor }
        return layer
    }
    
    class func gradientLayerToBottomLeft( bounds : CGRect , colors : [UIColor] )  throws -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPointMake(1.0,0.0)
        layer.endPoint = CGPointMake(0.0,1.0)
        layer.colors = colors.map { $0.CGColor }
        return layer
    }

}