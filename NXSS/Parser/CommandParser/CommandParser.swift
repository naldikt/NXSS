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
        parsers = [
            CPResultExtend(),
            CPResultInclude(),
            CPResultImport(),
            CPResultStyleDeclaration(),
            CPResultRuleSetHeader(),
            CPResultMixinHeader(),
            CPResultBlockClosure()
        ]
    }

    func append(c : Character) -> CPResultType? {
        /*
        if runState( c ) {
            characters.append(c)
        }
        
        if state == .RunParsers {
          */
            // Let's run the parser!
            var newParsers : [protocol<CPAppendable,CPResultTypeResolvable>] = []
            for parser in parsers {
                switch parser.append(c) {
                case .InProgress: newParsers.append(parser)
                case .Invalid:  continue
                case .Resolved: return parser.resolveType()   // Done.
                }
            }
            
            parsers = newParsers
            if parsers.count == 0 {
                return nil // Gave up.
            }
            
//        }

        return .InProgress
    }
    

    
    // MARK: Private
    
    private var parsers : [protocol<CPAppendable,CPResultTypeResolvable>] = []

//    private var state : CPState = .ScanForLeadingSpace

//    private var characters : [Character] = []
    
    /** @return whether should honor the character. */
    /*
    private func runState( newChar : Character ) -> Bool {
        
        let prevChar = characters.last
        
        switch state {
        case .ScanForLeadingSpace:
//            let isMember = NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(newChar)
            let isUselessChar = (newChar == " " || newChar == "\n" || newChar == "\r" || newChar == "\t")
            if isUselessChar {

            } else {
                state = .RunParsers
                runState( newChar )
            }
            
        case .RunParsers:
            if newChar == "*" && prevChar == "/" {
                state = .SkipForComment
                characters.removeLast()
                
            } else {
                // We're good!
                return true
            }
            
        case .SkipForComment:
            if newChar == "/" && prevChar == "*" {
                state = .RunParsers // Done
                characters.removeLast()
            }
        }
        
        return false
        
    }
*/
}