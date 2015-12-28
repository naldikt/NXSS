//
//  UIButton+NXSS.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/19/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {

    
    override func applyNXSS_styleElement() throws {
        
        try super.applyNXSS_styleElement()
        
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UIButton", selectorType:.Element) {
            try applyDeclarations(declarations)
        }
        
    }
    

    
    override func applyDeclarations( declarations : Declarations ) throws {
        
        try super.applyDeclarations(declarations)
        
        self.titleLabel?.backgroundColor = UIColor.clearColor()
        
        if let fontFamily : String =  declarations["font-family"] , titleLabel = self.titleLabel {
            
            var fontStyle:String?
            if let fontStyle_ : String =  declarations["font-style"] {
                fontStyle = fontStyle_
            }
            
            var fontSize:CGFloat?
            if let fontSize_ : String =  declarations["font-size"] {
                fontSize = try fontSize_.toCGFloat()
            }
            
            Applicator.applyFont(titleLabel, fontFamily: fontFamily, fontStyle: fontStyle, fontSize: fontSize)
        }
        
        if let color = declarations["color"] {
            self.titleLabel?.textColor = try UIColor.fromNXSS(color)
        }
        
        if let textAlign = declarations["text-align"] {
            
            var align : UIControlContentHorizontalAlignment = .Center
            
            switch textAlign {
            case "left": align = .Left
            case "right": align = .Right
            case "center": align = .Center
            case "fill": align = .Fill
            default:
                throw NXSSError.Parse(msg: "UIButton.applyDeclarations: text-align has invalid value.", statement: "text-align:\(textAlign)", line: nil)
            }
            
            self.contentHorizontalAlignment = align
        }
        
        if let string = declarations["string"] {
            self.titleLabel?.text = string
        }
    }
    


}