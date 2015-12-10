//
//  Applicator.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/6/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class Applicator {
    
    // MARK: - UIView
    
    class func applyBackgroundColor( view : UIView, color : String ) throws {
        
        // If there's a linear gradient applied before, let's ensure we remove them.
        // Failing to do this would result to multiple gradients applied on top of each other.
        view.nxssLinearGradient?.removeFromSuperlayer()
        view.nxssLinearGradient = nil
        
        
        if color.hasPrefix("linear-gradient") {
            view.nxssLinearGradient = try CAGradientLayer.fromNXSSLinearGradient( view.layer , linearGradientString: color , frame : view.frame )
            
        } else {
            let parsedColor = try UIColor.fromNXSS(color)
            view.backgroundColor = parsedColor
        }
    }
    
    
    // MARK: - UILabel
    
    class func applyFont( label : UILabel , fontFamily:String, fontStyle:String?, fontSize:CGFloat?) {
        var size : CGFloat = label.font.pointSize
        if let s = fontSize {
            size = s
        }
        
        var fontName = "\(fontFamily)"
        if let fontStyle = fontStyle {
            fontName += "-" + fontStyle
        }
        
        
        let theFont = UIFont(name: fontName, size: size)
        label.font = theFont
    }
    
    
    // MARK: - CALayer
    
    class func applyBorderColor( layer : CALayer, color : String ) throws {
        layer.borderColor = try UIColor.fromNXSS(color).CGColor
    }
    
    class func applyBorderWidth( layer : CALayer, number : String ) throws {
        layer.borderWidth = try number.toCGFloat()
    }
    
    class func applyCornerRadius( layer : CALayer, number : String ) throws {
        applyCornerRadius( layer , number: try number.toCGFloat() )
    }

    class func applyCornerRadius( layer : CALayer, number : CGFloat ) {
        layer.cornerRadius = number
    }

    class func applyCornerRadiusCircle( layer : CALayer ) {
        applyCornerRadius( layer , number: layer.frame.size.width / 2 )
    }
    

}