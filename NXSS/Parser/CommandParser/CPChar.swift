//
//  CPChar.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 3/21/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

// Decided to alias these in case we found another structure that is more efficient than UnicodeScalarView.

typealias CPChar = UnicodeScalar
typealias CPCharView = String.UnicodeScalarView
typealias CPCharViewIndex = String.UnicodeScalarView.Index

func getCPChars( string : String ) -> CPCharView {
    return string.unicodeScalars
}

func stringToCPChars( string : String ) -> [CPChar] {
    var ret : [CPChar] = []
    for k in getCPChars(string) {
        ret.append(k)
    }
    return ret
}
