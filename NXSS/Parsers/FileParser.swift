//
//  FileParser.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/20/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

class FileParser {
    
    /**
        :param:     The file name WITHOUT extension.
                    (The extension is always expected to be nxss)
    */
    init ( fileName : String ) {
        self.fileName = fileName
    }
    
    /**
        Start parsing the file. 
        :return:
            A tuple:
            1.  root context
            2.  the mapping of contextName to the Context.
    */
    func parse()
        /*-> ( rootContext:Context , maps:[String:String]  )*/
    {
        
        
        
    }
    
    
    // MARK: - Private
    
    private let fileName : String
    
    
    /**
        Read the file.
        This is temporary method - at some point we need to optimize this ie. what happens if it's huge file?
    */
    private func readFile() -> String {
        
        // TODO: Need to make this line by line reading.
        let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType:"nxss")!
        let data     = NSData(contentsOfFile:filePath)
        let string = NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
        return string
    }

}
