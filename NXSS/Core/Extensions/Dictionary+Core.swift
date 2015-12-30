//
//  Dictionary+Core.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 11/15/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

extension Dictionary { 
}

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}