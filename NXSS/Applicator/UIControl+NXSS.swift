//
//  UIControl+NXSS.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/13/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

extension UIControl {
    
    
    
    // MARK: - Private
    
    override func applyNXSS_styleElement() throws {
        
        try super.applyNXSS_styleElement()
        
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UIControl", selectorType:.Element) {
            // We'll assume this is for Normal. In the future it may make sense to actually add state ability to elements.
            try applyDeclarations(declarations , forPseudoClass : .Normal)
        }
        
    }
    
    override func applyNXSS_styleClass() throws {
        
        try super.applyNXSS_styleClass()
        
        if let declarations = nxssGetClassDeclarations(nxssCurrentPseudoClass) {
            try applyDeclarations(declarations, forPseudoClass: nxssCurrentPseudoClass)
        }

    }
    
    /** This is called when state has changed. */
    private func applyDeclarations( declarations : Declarations , forPseudoClass pseudoClass : PseudoClass )  throws {
        
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
        
    }
    
    override func nxss_didMoveToWindow() {
        super.nxss_didMoveToWindow()
        
        if window != nil {
            self.addObserver(self, forKeyPath: "highlighted", options: [.New,.Old] , context: nil)
            self.addObserver(self, forKeyPath: "selected", options: [.New,.Old], context: nil)
            self.addObserver(self, forKeyPath: "enabled", options: [.New,.Old], context: nil)
        } else {
            self.removeObserver(self, forKeyPath: "highlighted")
            self.removeObserver(self, forKeyPath: "selected")
            self.removeObserver(self, forKeyPath: "enabled")
        }
    }
    


    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let change = change, old = change["old"] as? Bool, new = change["new"] as? Bool where
            (keyPath == "highlighted" || keyPath == "selected" || keyPath == "enabled") &&
                old != new
        {
            try! applyNXSS_styleClass()
        }
    }
    
    
}