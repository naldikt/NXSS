//
//  UIView+NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation
import UIKit

extension UIView : NXSSView {
    
    public func applyNXSS() {
        do {
            
            try applyNXSS_styleElement()
            try applyNXSS_styleClass()
            

        } catch let error {
            NSLog("UIView.applyNXSS failed with error:\n\(error)")
        }
    }
    
}

extension UIView : NXSSViewApplicator {
    
    internal func applyNXSS_styleElement() throws {
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UIView", selectorType:.Element) {
            try applyDeclarations(declarations)
        }
    }
    
    internal func applyNXSS_styleClass() throws  {
        if let nxssClass = nxss, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.Class) {
            try applyDeclarations(declarations)
        }
    }
    
    internal func applyDeclarations( declarations : Declarations ) throws {
        
        if let backgroundColor  = declarations["background-color"] {
            try Applicator.applyBackgroundColor(self, color: backgroundColor)
        }
        
        if let borderColor  =  declarations["border-color"] {
            try Applicator.applyBorderColor( layer , color: borderColor)
        }
        
        if let borderWidth  =  declarations["border-width"] {
            try Applicator.applyBorderWidth( layer , number: borderWidth )
        }
        
        if let cornerRadius =  declarations["corner-radius"] {
            if cornerRadius == "circle" {
                nxssFrameCircle = true
                Applicator.applyCornerRadiusCircle( layer )
            } else {
                nxssFrameCircle = false
                try Applicator.applyCornerRadius( layer , number: cornerRadius )
            }
        }
        
    }
}


extension UIView  {


    // MARK: - Protected
    
    var nxss_frame : CGRect {
        set {
            self.nxss_frame = newValue
            
            if nxssFrameCircle {
                // Attempt to rectify the circle if there's any changes to the frame.
                // This expects the frame to still be circle.
                Applicator.applyCornerRadiusCircle( self.layer )
            }
        }
        get {
            return self.nxss_frame
        }
    }
    
    func nxss_didMoveToWindow() {
        if window != nil && !nxssApplied {
            applyNXSS()
            nxssApplied = true
        }
        self.nxss_didMoveToWindow()
    }
    
    var nxssApplied : Bool {
        set {
            objc_setAssociatedObject(self, &NXSS_IsAppliedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &NXSS_IsAppliedKey) as? Bool) ?? false
        }
    }
    
    // The class name. Set by xibs.
    var nxss : String? {
        set {
            objc_setAssociatedObject(self, &NXSS_ClassNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &NXSS_ClassNameKey) as? String
        }
    }
    
    var nxssLinearGradient : CALayer? {
        set {
            objc_setAssociatedObject(self, &NXSS_LinearGradientKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, &NXSS_LinearGradientKey) as? CALayer
        }
    }

    // Whether we should attempt to make the frame a circle.
    var nxssFrameCircle : Bool {
        set {
            objc_setAssociatedObject(self, &NXSS_FrameCircle, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &NXSS_FrameCircle) as? Bool) ?? false
        }
    }
}