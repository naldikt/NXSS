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
            - bounds                    The bounds of the view
    
        - return: The applied linear gradient.
    */
    class func fromNXSSLinearGradient( layer : CALayer , linearGradientString : String , bounds : CGRect ) throws -> CAGradientLayer {

        let (name,args) = try FunctionHeader.parse(linearGradientString)

        try NXSSError.throwIfNot( name == "linear-gradient" ,  msg: "applyLinearGradient requires string to be linear-gradient" ,  statement: linearGradientString , line:nil)
        try NXSSError.throwIfNot( args.count >= 3 , msg: "linear-gradient requires at least 3 arguments", statement: linearGradientString, line:nil)
        
        let directionStr = args[0]  // expected tobe: "to bottom" or "to right"
        let directionArr = directionStr.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        try NXSSError.throwIfNot(
            directionArr.count == 2 &&
            directionArr[0] == "to" &&
            (directionArr[1] == "bottom" || directionArr[1] == "right"),
            msg: "applyLinearGradient first arg needs to be either 'to bottom' or 'to right'", statement:directionStr, line:nil)
        
        let direction = directionArr[1]
        
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

        
        if direction == "bottom" {
            return try CAGradientLayer.gradientLayerToBottom(bounds, colors:colors)
        } else  {
            return try CAGradientLayer.gradientLayerToRight(bounds, colors:colors)
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

}