//
//  UIView+NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation
import UIKit

var textAnimationStringsObjectKey: UInt8 = 0

/*
When I override ADView, I don't see override is called.
When I override ADView2, I do see

*/
extension UIView {
    
    func nxss_willMoveToWindow(newWindow:UIWindow?) {
        if !nxssApplied {
            applyNXSS()
            nxssApplied = true
        }
        self.nxss_willMoveToWindow(newWindow)
    }
    
    func applyNXSS() {
        
    }
 
    
    var nxssApplied : Bool {
        set {
            objc_setAssociatedObject(self, &NXSS_IsAppliedKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return (objc_getAssociatedObject(self, &NXSS_IsAppliedKey) as? Bool) ?? false
        }
    }

}