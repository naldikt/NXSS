//
//  UILabel+NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation
import UIKit

extension UILabel  {
    
    override func applyNXSS_styleElement() throws {
        
        try super.applyNXSS_styleElement()
        
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UILabel", selectorType:.Element) {
            try applyLabelDeclarations(declarations)
        }
        
    }
    
    
    override func applyNXSS_styleClass() throws {
        
        try super.applyNXSS_styleClass()
        
        if let nxssClass = nxssClass, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.Class) {
            try applyLabelDeclarations(declarations)
        }
        
    }


    private func applyLabelDeclarations( declarations:Declarations ) throws {
        
        if let fontFamily  = declarations["font-family"] {
            
            var fontStyle:String?
            if let fontStyle_ =  declarations["font-style"] {
                fontStyle = fontStyle_
            }
            
            var fontSize:CGFloat?
            if let fontSize_ = declarations["font-size"] {
                fontSize = try fontSize_.toCGFloat()
            }
            
            try Applicator.applyFont(self,fontFamily:fontFamily,fontStyle:fontStyle,fontSize:fontSize)
        }
        
        if let color = declarations["color"] {
            self.textColor = try UIColor.fromNXSS(color)
        }
        
        if let textAlign = declarations["text-align"] {
            
            var align : NSTextAlignment = .Center
            
            switch textAlign {
            case "left": align = .Left
            case "right": align = .Right
            case "center": align = .Center
            case "justified": align = .Justified
            case "natural": align = .Natural
            default:
                throw NXSSError.Parse(msg: "UILabel.applyDeclarations: text-align has invalid value.", statement: "text-align:\(textAlign)", line: nil)
            }
            
            self.textAlignment = align
        }
        
        if let string = declarations["string"] {
            self.text = string
        }
        
    }
}