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
    
    // The class name. Set by xibs.
    @IBInspectable public var nxssClass : String? {
        set {
            objc_setAssociatedObject(self, &NXSS_ClassNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &NXSS_ClassNameKey) as? String
        }
    }
    
    public func applyNXSS()  {
        do {
            
            try applyNXSS_styleElement()
            try applyNXSS_styleClass()
            

        } catch let error {
            let msg = "UIView.applyNXSS failed with error:\n\(error)"
            NSLog(msg)
            assert(false,msg)
        }
    }
    
}

extension UIView : NXSSViewApplicator {
    
    func applyNXSS_styleElement() throws {
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UIView", selectorType:.Element) {
            try applyViewDeclarations(declarations)
        }
    }
    
    func applyNXSS_styleClass() throws  {
        if let nxssClass = nxssClass, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.Class, pseudoClass: nxssCurrentPseudoClass ) {
            try applyViewDeclarations(declarations)
        }
    }
    
    func applyViewDeclarations( declarations : Declarations ) throws {
        
        if let backgroundColor  = declarations["background-color"] {
            nxssRawBackgroundColor = backgroundColor
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
    
    var nxssCurrentPseudoClass : PseudoClass {
        return Applicator.getPseudoClass( self )
    }
    
    func nxssGetClassDeclarations( pseudoClass : PseudoClass ) -> Declarations? {
        if let  nxssClass = nxssClass , declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType: .Class, pseudoClass: pseudoClass) {
            return declarations
        } else {
            return nil
        }
    }
    
    func nxss_layoutSubviews() {

        self.nxss_layoutSubviews()

        if nxssFrameCircle {
            // Attempt to rectify the circle if there's any changes to the frame.
            // This expects the frame to still be circle.
            Applicator.applyCornerRadiusCircle( self.layer )
        }
        
        if let nxssRawBackgroundColor = nxssRawBackgroundColor {
            do {
                try Applicator.applyBackgroundColor(self, color: nxssRawBackgroundColor)
            } catch {
                NSLog("[NXSS] Cannot reapply backgroundColor \(nxssRawBackgroundColor)")
            }
        }
    }
    
    func nxss_didMoveToWindow() {
        if window != nil && !nxssAppliedOnViewLoaded {
            applyNXSS()
            nxssAppliedOnViewLoaded = true
        }
        self.nxss_didMoveToWindow()
    }
    
    var nxssAppliedOnViewLoaded : Bool {
        set {
            objc_setAssociatedObject(self, &NXSS_IsAppliedOnViewLoadedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &NXSS_IsAppliedOnViewLoadedKey) as? Bool) ?? false
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
    
    var nxssRawBackgroundColor : String? {
        set {
            objc_setAssociatedObject(self, &NXSS_RawBackgroundColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, &NXSS_RawBackgroundColorKey) as? String
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