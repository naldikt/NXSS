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
            let linearGradient = try CAGradientLayer.fromNXSSLinearGradient( view.layer , linearGradientString: color , bounds : view.bounds )
            view.layer.insertSublayer(linearGradient, atIndex: 0)
            view.nxssLinearGradient = linearGradient
            
        } else {
            let parsedColor = try UIColor.fromNXSS(color)
            view.backgroundColor = parsedColor
        }
    }
    
    
    
    // MARK: - UILabel
    
    class func applyFont( label : UILabel , fontFamily:String, fontStyle:String?, fontSize:CGFloat?) throws {
        var size : CGFloat = label.font.pointSize
        if let s = fontSize {
            size = s
        }
        
        let fontName = createFontName( fontFamily , fontStyle: fontStyle)
        
        
        guard let theFont = UIFont(name: fontName, size: size) else {
            throw NXSSError.Require(msg: "Font does not exist", statement: fontName, line: nil)
        }
        label.font = theFont
    }
    
    // MARK: - Fonts
    
    class func textFontAttributes( fontFamily:String, fontStyle:String?, fontSize:CGFloat) throws -> [String:AnyObject] {
        
        let fontName = createFontName( fontFamily , fontStyle: fontStyle)
        
        guard let font = UIFont(name: fontName, size: fontSize) else {
            throw NXSSError.Require(msg: "Cannot create UIFont", statement: "UIFont(name: \(fontName), size: \(fontSize))", line: nil)
        }
        
        return [NSFontAttributeName:font]
    }
    
    class func textColorAttributes( color : UIColor ) throws -> [String:AnyObject] {
        return [NSForegroundColorAttributeName: color]
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
    
    // MARK: Utilities
    
    /** Convert "true" and "false" into boolean. */
    class func stringToBool( input : String ) -> Bool? {
        if input == "true" {
            return true
        } else if input == "false" {
            return false
        } else {
            return nil
        }
    }
    
    // Return UIControlState associated with the given pseudoClass.
    class func toUIControlState( pseudoClass : PseudoClass ) -> UIControlState {
        switch pseudoClass {
        case .Normal: return .Normal
        case .Highlighted: return .Highlighted
        case .Selected: return .Selected
        case .Disabled: return .Disabled
        }
    }
    
    // - discussion: Why can't we just have an extension method i.e. "getPseudoClass" declared in UIView, and override it in UIControl?
    // Because then you'd get error: declarations in extension cannot override yet
    // What I'm doing here is a workaround until Apple decides to change it.
    class func getPseudoClass( instance : UIView ) -> PseudoClass {
        
        if let control = instance as? UIControl {
            
            if control.highlighted {
                
                return .Highlighted
                
            } else if control.selected {
                
                return .Selected
                
            } else if !control.enabled {
                
                return .Disabled
                
            } else {
                return .Normal
            }
            
            
        } else {
            // Anything above UIControl doesn't really have pseudoClass.
            return .Normal
        }
        
    }
    
    //MARK: - Private
    
    private class func createFontName( fontFamily : String , fontStyle:String?) -> String {
        var fontName = "\(fontFamily)"
        if let fontStyle = fontStyle {
            fontName += "-" + fontStyle
        }
        return fontName
    }
}