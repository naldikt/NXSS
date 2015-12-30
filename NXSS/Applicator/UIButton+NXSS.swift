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
            try applyDeclarations(declarations, forPseudoClass:.Normal)
        }
        
    }
    
    override func applyNXSS_styleClass() throws {
        
        try super.applyNXSS_styleClass()
        
        if let declarations = nxssGetClassDeclarations(nxssCurrentPseudoClass) {
            try applyDeclarations(declarations, forPseudoClass: nxssCurrentPseudoClass)
        }

    }

    
    private func applyDeclarations( declarations : Declarations, forPseudoClass pseudoClass : PseudoClass ) throws {
        
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
        
        let uiControlState = Applicator.toUIControlState(pseudoClass)
        
        if let color = declarations["color"] {
            self.setTitleColor(try UIColor.fromNXSS(color), forState: uiControlState)
        }

        if let string = declarations["string"] {
            self.setTitle(string, forState: uiControlState)
        }
    }
    


}