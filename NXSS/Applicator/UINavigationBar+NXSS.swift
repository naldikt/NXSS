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
            try applyDeclarations(declarations)
        }
    }
    
    override func applyNXSS_styleClass() throws {
        
        try super.applyNXSS_styleClass()
        
        if let nxssClass = nxssClass, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.Class) {
            try applyDeclarations(declarations)
        }

        
    }
    

    private func applyDeclarations( declarations:Declarations ) throws {
        
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
        
    }
    
}