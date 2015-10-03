//
//  String+NXSS.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/20/15.
//  Copyright (c) 2015 Rhapsody. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i])
    }
    
    func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    
    func stringByRemovingFirstOccurenceOfString( target : String ) -> String {
        
        var s = self
        
        if let range = s.rangeOfString(target) {
            s.removeRange(range)
        }
        
        return s
        
    }
}
