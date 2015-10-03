//
//  NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/15/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

public class NXSS {
    
    /** Shared Instance */
    public static var sharedInstance : NXSS {
        dispatch_once(&NXSS.initToken) {
            NXSS._instance = NXSS()
        }
        return _instance!
    }
    
    /**
        Start NXSS.
        :param: fileName     Give the file name to start watching.
    */
    public func useFile( fileName : String ) {
        
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType:"nxss")!
        let data     = NSData(contentsOfFile:filePath)
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        
        let parser = Parser(stringQueue: StringQueue(string:string))
        self.styleClasses = try! parser.parse()
        
        
    }
    
    
    // MARK: - Private
    
    private static var initToken = dispatch_once_t()
    private static var _instance : NXSS?
    
    private var styleClasses: [String:StyleClass] = Dictionary()
    
    init () {
        Swizzler.swizzle()
    }
    
}