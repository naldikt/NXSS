//
//  CommandParser.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/28/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

enum CPResultType {
    case InProgress         // The append is still in progress and has no definitive result.
    case Extend(selector:String, selectorType:SelectorType, pseudoClass:PseudoClass)
    case Include(selector:String, argumentValues:[String])
    case Import(fileName:String)
    case StyleDeclaration(key:String, value:String)
    case RuleSetHeader(selector:String, selectorType:SelectorType, pseudoClass:PseudoClass)
    case MixinHeader(selector:String, argumentNames:[String])
    case BlockClosure
}

enum CPState {
    case ScanForLeadingSpace
    case RunParsers
    case SkipForComment

}

class CommandParser {
    
    init() {
        
        // Orders matter. The first resolved wins.
        parsers = [
            CPResultExtend(),
            CPResultInclude(),
            CPResultImport(),
            CPResultMixinHeader(),
            CPResultRuleSetHeader(),
            CPResultStyleDeclaration(),
            CPResultBlockClosure()
        ]
    }

    func append(c : Character) -> CPResultType? {
        
        switch appendState {
        case .Append:
            if c == "/" {
                appendState = .PossiblyStartSkip
                
            } else if isFirstCharacter &&
                (c == " " || c == "\t" || c == "\n" || c == "\r") {
                    
                    // Intentionally skip
                    
            } else {
                return doAppend(c)
            }
        case .PossiblyStartSkip:
            if c == "*" {
                appendState = .Skip
            } else {
                appendState = .Append
                
                // Attempt to restore
                if let cpAppendResult = doAppend("/") {
                    return cpAppendResult
                }
                return doAppend(c)
                
//                characters.append("/")
//                let ret1 = characterAppended("/")
//                if ret1 == .InProgress {
//                    characters.append(c)
//                    return characterAppended(c)
//                } else {
//                    return ret1
//                }
            }
        case .Skip:
            if c == "*" {
                appendState = .PossiblyEndSkip
            }
        case .PossiblyEndSkip:
            if c == "/" {
                appendState = .Append
            } else if c == "*" {
                // still same state
            } else {
                // Still skipping!
                appendState = .Skip
                //                characters.append("*")
                //                appendState = .Skip
                //                return characterAppended("*")
            }
        }
        
        return .InProgress
    }
    

    
    // MARK: Private
    
    private var parsers : [protocol<CPAppendable,CPResultTypeResolvable>] = []

    
    private enum AppendState {
        case Append
        case PossiblyStartSkip
        case Skip
        case PossiblyEndSkip
    }
    
    private var appendState : AppendState = .Append
    private var isFirstCharacter : Bool = true
    
    private func doAppend(c : Character) -> CPResultType? {
        // Let's run the parser!
        isFirstCharacter = false
        var newParsers : [protocol<CPAppendable,CPResultTypeResolvable>] = []
        for parser in parsers {
            switch parser.append(c) {
            case .InProgress: newParsers.append(parser)
            case .Invalid:  continue
            case .Resolved:
                //                print("We've got a winnder: \(parser)")
                return parser.resolveType()   // Done.
                
            }
        }
        
        parsers = newParsers
        if parsers.count == 0 {
            return nil // Gave up.
        }
        
        return .InProgress
    }

}