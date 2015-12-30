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
        
        if let color = declarations["tint-color"] {
            self.tintColor = try UIColor.fromNXSS(color)
        }
        
        if let color = declarations["bar-tint-color"] {
            self.barTintColor = try UIColor.fromNXSS(color)
        }
    }
    
}