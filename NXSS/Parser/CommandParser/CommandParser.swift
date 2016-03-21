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

typealias CParser = protocol<CPAppendable,CPResultTypeResolvable>

class CParserData : CustomStringConvertible {
    private(set) var characters : String.CharacterView
    
    // This is the start index of the last character
//    private(set) var lastCharacterIndex : String.CharacterView.Index
    
    init() {
        self.characters = String.CharacterView()
        self.characters.reserveCapacity(150)
//        self.lastCharacterIndex = characters.startIndex
    }
    
    func append(c : Character) {
        self.characters.append(c)
//        self.lastCharacterIndex = self.characters.endIndex.predecessor()  //
    }
    
    func trimmedStringWithRange( startIndex : String.CharacterView.Index , endIndex : String.CharacterView.Index ) -> String {
        let s = self.stringWithRange(startIndex, endIndex: endIndex)
        return s.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func stringWithRange( startIndex : String.CharacterView.Index , endIndex : String.CharacterView.Index ) -> String {
        let range = Range(start: startIndex, end: endIndex)
        let string = String(characters[range])
//        print("*** string |\(string)|")
        return string
    }
    
    var description : String {
        return "<CParserData characters=|\(String(characters))|>"
    }
}

class CommandParser {
    
    init( pastResult : CPResultType? = nil ) {
        
        self.data = CParserData()
        parsers = CommandParser.defaultParsers()
        
        /*
        // Orders matter. The first resolved wins.
        if let pastResult = pastResult {
            
            switch pastResult {
            case .InProgress,
                .StyleDeclaration,
                .BlockClosure:
                
                parsers = CommandParser.defaultParsers()
                
            case .Extend,
                .Include:
                
                parsers = [CPResultStyleDeclaration(),CPResultInclude(),CPResultExtend(),CPResultBlockClosure()]
                
            case .Import:
                
                parsers = [CPResultRuleSetHeader(),CPResultMixinHeader(),CPResultStyleDeclaration()]
                
            case .MixinHeader,
                .RuleSetHeader:
                
                parsers = [CPResultStyleDeclaration(),CPResultInclude(),CPResultExtend(),CPResultBlockClosure()]
            }
            
        } else {
            parsers = CommandParser.defaultParsers()
        }
*/
    }
    
    class func defaultParsers() -> [CParser] {
        return [
            CPResultStyleDeclaration(),
            CPResultMixinHeader(),
            CPResultRuleSetHeader(),
            CPResultBlockClosure(),
            CPResultExtend(),
            CPResultInclude(),
            CPResultImport()
        ]
    }

    func append(c : Character) -> CPResultType? {
        
        switch appendState {
        case .Append:
            if c == "/" {
                appendState = .PossiblyStartSkip
                
            } else if data.characters.count == 0 &&
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
            }
        }
        
        return .InProgress
    }
    

    
    // MARK: Private
    
    private var parsers : [CParser] = []

    
    private enum AppendState {
        case Append
        case PossiblyStartSkip
        case Skip
        case PossiblyEndSkip
    }
    
    private var appendState : AppendState = .Append
    private var data : CParserData
    
    private func doAppend(c : Character) -> CPResultType? {
        // Let's run the parser!
        data.append(c)
        var newParsers : [protocol<CPAppendable,CPResultTypeResolvable>] = []
        for parser in parsers {
            switch parser.characterAppended(c, currentData:  data) {
            case .InProgress: newParsers.append(parser)
            case .Invalid:  continue
            case .Resolved:
                //                print("We've got a winnder: \(parser)")
                return parser.resolveType( data)   // Done.
                
            }
        }
        
        parsers = newParsers
        if parsers.count == 0 {
            return nil // Gave up.
        }
        
        return .InProgress
    }

}