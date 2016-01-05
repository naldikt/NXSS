//
//  String+Core.swift
//  NXSS
//
//  Created by Nalditya Kusuma on 9/20/15.
//  Copyright (c) 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import CoreGraphics

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
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
    
    var first : Character? {
        if self.characters.count > 0 {
            return self[0]
        } else {
            return nil
        }
    }
    
    var last : Character? {
        if self.characters.count > 0 {
            return self[self.characters.count-1]
        } else {
            return nil
        }
    }
    
    mutating func removeLast() -> Character? {
        if self.characters.count > 0 {
            let lastIndex = self.characters.count-1
            let s : Character = self[lastIndex]
            self = self.substringToIndex(self.startIndex.advancedBy(lastIndex))
            return s
        } else {
            return nil
        }
    }
}
