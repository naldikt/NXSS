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
    
    
    override public func applyNXSS() {
        
        if !nxssStatesObserverApplied {
            nxssStatesObserverApplied = true
            
            // We'll apply this only once.
            self.addObserver(self, forKeyPath: "highlighted", options: [.New,.Old] , context: nil)
            self.addObserver(self, forKeyPath: "selected", options: [.New,.Old], context: nil)
            self.addObserver(self, forKeyPath: "enabled", options: [.New,.Old], context: nil)
        }
        
        super.applyNXSS()
        
    }
    
    override func applyNXSS_styleElement() throws {
        
        try super.applyNXSS_styleElement()
        
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UIControl", selectorType:.Element) {
            try applyDeclarations(declarations)
        }
        
    }
    
    /** Override how UIView does this. */
    override func applyNXSS_styleClass() throws {
        
        if highlighted {
            
//            NSLog("Apply Highlighted")
            try applyClassDeclarationsWithPseudoClass(.Highlighted)
            
        } else if selected {
            
//            NSLog("Apply Selected")
            try applyClassDeclarationsWithPseudoClass(.Selected)
            
        } else if !enabled {
            
//            NSLog("Apply Enabled")
            try applyClassDeclarationsWithPseudoClass(.Disabled)
            
        } else {
            
            // Normal
//            NSLog("Apply Normal")
            try applyClassDeclarationsWithPseudoClass(.Normal)
            
        }
        
    }
    
    private func applyClassDeclarationsWithPseudoClass( pseudoClass : PseudoClass ) throws {

        if let nxssClass = nxss, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType: .Class, pseudoClass: pseudoClass) {
            try applyDeclarations(declarations)
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
    
    
    private var nxssStatesObserverApplied : Bool {
        set {
            objc_setAssociatedObject(self, &NXSS_StatesObserverApplied, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &NXSS_StatesObserverApplied) as? Bool) ?? false
        }
    }
    
}