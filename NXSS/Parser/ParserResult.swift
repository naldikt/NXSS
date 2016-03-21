//
//  ParserResult.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 3/20/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

protocol ParserResult {
    var ruleSets : [String:CompiledRuleSet] { get }
    var variables : Declarations { get }
    var mixins : [String:CompiledMixin] { get }
}

