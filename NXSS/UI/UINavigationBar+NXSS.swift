//
//  UINavigationBar+NXSS.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/28/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    override func applyNXSS_styleElement() throws {
        
        try super.applyNXSS_styleElement()
        
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UINavigationBar", selectorType:.Element) {
            try applyNavBarDeclarations(declarations)
        }
    }
    
    override func applyNXSS_styleClass() throws {
        
        try super.applyNXSS_styleClass()
        
            NSLog("applyNXSS_styleClass \(nxssClass)")
        
        if let nxssClass = nxssClass, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.Class) {
            
            try applyNavBarDeclarations(declarations)
        }
        
        
    }
    

    func applyNavBarDeclarations( declarations:Declarations ) throws {
        
        try super.applyViewDeclarations( declarations )
        
        if let fontFamily : String =  declarations["font-family"], fontSize_ : String =  declarations["font-size"] {
            
            var fontStyle:String?
            if let fontStyle_ : String =  declarations["font-style"] {
                fontStyle = fontStyle_
            }
            
            let fontSize = try fontSize_.toCGFloat()
            
            let attrs = try Applicator.textFontAttributes(fontFamily, fontStyle:fontStyle, fontSize:fontSize)
            var titleTextAttrs = titleTextAttributes ?? Dictionary()
            titleTextAttrs += attrs
            titleTextAttributes = titleTextAttrs
        }

        if let color = declarations["color"] {
            let uiColor = try UIColor.fromNXSS(color)
            
            let attrs = try Applicator.textColorAttributes(uiColor)
            var titleTextAttrs = titleTextAttributes ?? Dictionary()
            titleTextAttrs += attrs
            titleTextAttributes = titleTextAttrs
        }
        
        if let color = declarations["tint-color"] {
            self.tintColor = try UIColor.fromNXSS(color)
        }
        
        if let color = declarations["bar-tint-color"] {
            self.barTintColor = try UIColor.fromNXSS(color)
        }
        
        if let translucentS = declarations["translucent"] {
            if let translucent = Applicator.stringToBool(translucentS) {
                self.translucent = translucent
            } else {
                throw NXSSError.Require(msg: "translucent value must either be true or false", statement: "translucent: \(translucentS)", line:nil)
            }
        }
        
        if let backgroundImage = declarations["background-image"] {
            if backgroundImage == "_" {
                self.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            } else {
                if let image = UIImage(named: backgroundImage) {
                    self.setBackgroundImage(image, forBarMetrics: .Default)
                } else {
                    throw NXSSError.Require(msg: "background-image is not found", statement: "background-image: \(backgroundImage)", line: nil)
                }
            }
        }
        
        if let shadowImage = declarations["shadow-image"] {
            if shadowImage == "_" {
                self.shadowImage = UIImage()
            } else {
                if let image = UIImage(named: shadowImage) {
                    self.shadowImage = image
                } else {
                    throw NXSSError.Require(msg: "shadow-image is not found", statement: "shadow-image: \(shadowImage)", line: nil)
                }
            }
        }
        
    }
    
}