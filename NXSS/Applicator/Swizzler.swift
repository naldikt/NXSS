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
        
        xImp( UIView.self , methodName: "didMoveToWindow" )
        xImp( UIView.self , methodName: "frame" )
        
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
        
        
        if class_addMethod(theClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) {
            class_replaceMethod(theClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    }
    
}