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
        - parameters:
            - linearGradientString      Either linear-gradient( to bottom , topColor , bottomColor )  or   linear-gradient( to right , leftColor , rightColor )
            - bounds                    The bounds of the view
    
        - return: The applied linear gradient.
    */
    class func fromNXSSLinearGradient( layer : CALayer , linearGradientString : String , bounds : CGRect ) throws -> CAGradientLayer {

        let (name,args) = try FunctionHeader.parse(linearGradientString)

        try NXSSError.throwIfNot( name == "linear-gradient" ,  msg: "applyLinearGradient requires string to be linear-gradient" ,  statement: linearGradientString , line:nil)
        try NXSSError.throwIfNot( args.count == 3 , msg: "linear-gradient requires 3 arguments", statement: linearGradientString, line:nil)
        
        let directionStr = args[0]  // expected tobe: "to bottom" or "to right"
        let directionArr = directionStr.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        try NXSSError.throwIfNot(
            directionArr.count == 2 &&
            directionArr[0] == "to" &&
            (directionArr[1] == "bottom" || directionArr[1] == "right"),
            msg: "applyLinearGradient first arg needs to be either 'to bottom' or 'to right'", statement:directionStr, line:nil)
        
        let direction = directionArr[1]
        let firstColor : String = args[1]
        let secondColor : String = args[2]
        
        if direction == "bottom" {
            return try CAGradientLayer.gradientLayerFromTop(firstColor, toBottom: secondColor, bounds: bounds)
        } else  {
            return try CAGradientLayer.gradientLayerFromLeft(firstColor, toRight: secondColor, bounds: bounds)
        }

    }
    
    
    class func gradientLayerFromTop( topColor : String , toBottom bottomColor : String , bounds : CGRect ) throws -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPointMake(0.5,0.0)
        layer.endPoint = CGPointMake(0.5,1.0)
        
        let topColor : UIColor = try UIColor.fromNXSS(topColor)
        let bottomColor : UIColor = try UIColor.fromNXSS(bottomColor)

        layer.colors = [ topColor.CGColor , bottomColor.CGColor ]
        return layer
    }
    
    class func gradientLayerFromLeft( leftColor : String , toRight rightColor : String , bounds : CGRect ) throws -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = bounds
        layer.startPoint = CGPointMake(0.0,0.5)
        layer.endPoint = CGPointMake(1.0,0.5)
        
        let leftColor : UIColor = try UIColor.fromNXSS(leftColor)
        let rightColor : UIColor = try UIColor.fromNXSS(rightColor)
        
        layer.colors = [ leftColor.CGColor , rightColor.CGColor ]
        return layer
    }
}