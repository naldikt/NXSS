//
//  CPData.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 3/21/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

class CPData : CustomStringConvertible {
    
    private(set) var characters : CPCharView
    
    init() {
        self.characters = CPCharView()
        self.characters.reserveCapacity(150)
    }
    
    func append(c : CPChar) {
        self.characters.append(c)
    }
    
    func trimmedStringWithRange( startIndex : CPCharViewIndex , endIndex : CPCharViewIndex ) -> String {
        let s = self.stringWithRange(startIndex, endIndex: endIndex)
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func stringWithRange( startIndex : CPCharViewIndex , endIndex : CPCharViewIndex ) -> String {
        let range = startIndex ..< endIndex
        let string = String(characters[range])
        return string
    }
    
    var description : String {
        return "<CPData characters=|\(String(characters))|>"
    }
}