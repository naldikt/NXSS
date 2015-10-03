//
//  Swizzler.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation
import UIKit

class Swizzler {
    
    /**
        Start swizzling some methods.
    */
    class func swizzle() {
        
        xImp( UIView.self , methodName: "willMoveToSuperview:" )
//        xImp( UILabel.self , methodName: "willMoveToSuperview:" )
        
    }
    
    
    /**
        Exchange implementation of methodName with nxss_methodName.
        See nxss_methodName implemented in Views folder.
    */
    private class func xImp(  theClass : AnyClass , methodName : String ) {
    
        let originalSelector = Selector(methodName)
        let swizzledSelector = Selector("nxss_\(methodName)")
        
        let originalMethod = class_getInstanceMethod(theClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector)
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
}