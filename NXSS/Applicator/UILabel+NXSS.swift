//
//  UILabel+NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    override func applyNXSS() {
        super.applyNXSS()
        
        do {
            
            if let declarations = NXSS.sharedInstance.getStyleDeclarations("UILabel", selectorType: .Element) {
                try applyDeclarations( declarations )
            }
            
            if let nxssClass = nxss, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.Class) {
                try applyDeclarations( declarations )
            }

            
        } catch let error {
            NSLog("UILabel.applyNXSS failed with error:\n\(error)")
        }
    }
    
    
    private func applyDeclarations( declarations:Declarations ) throws {
        if let fontFamily  = declarations["font-family"] {
            
            var fontStyle:String?
            if let fontStyle_ =  declarations["font-style"] {
                fontStyle = fontStyle_
            }
            
            var fontSize:CGFloat?
            if let fontSize_ = declarations["font-size"] {
                fontSize = try fontSize_.toCGFloat()
            }
            
            Applicator.applyFont(self,fontFamily:fontFamily,fontStyle:fontStyle,fontSize:fontSize)
        }
    }
}