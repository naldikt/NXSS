//
//  ClassContext.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/27/15.
//  Copyright © 2015 Rhapsody. All rights reserved.
//

import Foundation

class ClassContext : Context {
    
    /**
        Turn this into a StyleClass
    */
    func compile() -> StyleClass {
        NSLog("About to compile ClassContext")
        let ret = StyleClass(name:name!,entries:resolveEntries())
        return ret
    }
    
}