//
//  UIViewController+NXSS.swift
//  Skyway
//
//  Created by Nalditya Kusuma on 1/21/16.
//  Copyright © 2016 Rhapsody International. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController : NXSSView {
    
    // The class name. Set by xibs.
    public var nxssClass : String? {
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

extension UIViewController {
    
    func applyNXSS_styleElement() throws {
        if let declarations =  NXSS.sharedInstance.getStyleDeclarations("UIViewController", selectorType:.UIKitElement) {
            try applyDeclarations(declarations)
        }
    }
    
    func applyNXSS_styleClass() throws  {
        if let nxssClass = nxssClass, declarations = NXSS.sharedInstance.getStyleDeclarations(nxssClass, selectorType:.NXSSClass, pseudoClass: .Normal ) {
            try applyDeclarations(declarations)
        }
    }
    
    func applyDeclarations( declarations : Declarations ) throws {
        
        if let rawBarStyle = declarations["preferred-status-bar-style"] {
            
            let statusBarStyle = rawBarStyle.lowercaseString
            
            if statusBarStyle == "default" {
                nxssPreferredStatusBarStyle = .Default
            } else if statusBarStyle == "lightcontent" {
                nxssPreferredStatusBarStyle = .LightContent
            } else {
                throw NXSSError.Require(msg: "preferred-status-bar-style value is not valid", statement: rawBarStyle, line: nil)
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
    }
}



// MARK: - Protected

extension UIViewController  {
    
    var nxssPreferredStatusBarStyle : UIStatusBarStyle? {
        set {
            let valToSave = newValue?.rawValue ?? -99  // On non existence return some invalid value such as negative number so reconstruction will fail.
            objc_setAssociatedObject(self, &NXSS_PreferredStatusBarStyleKey,  valToSave , .OBJC_ASSOCIATION_ASSIGN )
        }
        get {
            if let val = objc_getAssociatedObject(self, &NXSS_PreferredStatusBarStyleKey) as? Int {
                if let ret = UIStatusBarStyle(rawValue: val) {
                    return ret
                }
            }
            return nil
            
        }
    }

}

extension UIViewController {
    
    func nxss_viewDidLoad() {
        self.nxss_viewDidLoad()
        applyNXSS()
    }
    
    func nxss_preferredStatusBarStyle() -> UIStatusBarStyle {
        let originalRet = self.nxss_preferredStatusBarStyle()
        if let nxssPreferredStatusBarStyle = nxssPreferredStatusBarStyle {
            if originalRet != .Default {
                NSLog("[NXSS] WARNING: You specified preferred-status-bar-style but you also override preferredStatusBarStyle() manually.  We're ignoring the value from manual code and returning the one specified in NXSS.")
            }
            return nxssPreferredStatusBarStyle
        } else {
            return originalRet
        }
    }
    
}