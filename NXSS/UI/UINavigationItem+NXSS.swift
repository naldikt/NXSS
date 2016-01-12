//
//  UINavigationItem+NXSS.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 1/11/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationItem {

    
    // This class is to be applied to the UINavigationBar when the navigationItem becomes active.
    // Only works in conjunction with NXSSNavigationController
    public var nxssClass : String? {
        set {
            objc_setAssociatedObject(self, &NXSS_ClassNameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &NXSS_ClassNameKey) as? String
        }
    }
    
    
}