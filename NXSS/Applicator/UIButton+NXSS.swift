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
    
    override func applyNXSS() {
        super.applyNXSS()
        
        do {
            
            // For buttons we need to see the selector
            // Buttons can support Normal, Selected, Highlighted, Disabled.
//            
//            if let nxssClass = nxss, entries = NXSS.sharedInstance.getStyleEntries(nxssClass) {
//                
//                if let fontFamily : String =  entries["font-family"] , titleLabel = self.titleLabel {
//                    
//                    var fontStyle:String?
//                    if let fontStyle_ : String =  entries["font-style"] {
//                        fontStyle = fontStyle_
//                    }
//                    
//                    var fontSize:CGFloat?
//                    if let fontSize_ : String =  entries["font-size"] {
//                        fontSize = try fontSize_.toCGFloat()
//                    }
//                    
//                    Applicator.applyFont(titleLabel, fontFamily: fontFamily, fontStyle: fontStyle, fontSize: fontSize)
//                }
//                
//            }
//            
            
        } catch let error {
            NSLog("UILabel.applyNXSS failed with error:\n\(error)")
        }
    }
    
    
    
}