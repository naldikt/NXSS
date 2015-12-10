//
//  StringQueue.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/26/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation


/**
	Implementation of this class may not be efficient.
	We may need to make it more memory efficient in the future?
    See if we can also reuse Queue class.
*/
class StringQueue {
    
    private let string : String
    private var index : Int = 0
    
    init( string : String ) {
        self.string = string
    }
    
    /** Check if there's next. */
    func hasNext() -> Bool {
        return index < string.characters.count
    }
    
    /** If there's no next, will crash. */
    func peek() -> String {
        return string[index]
    }
    
    /** If there's no next, will crash. */
    func pop() -> String {
        return string[index++]
    }
}