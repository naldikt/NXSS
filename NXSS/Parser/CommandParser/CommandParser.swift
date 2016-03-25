//
//  CommandParser.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 2/28/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation

/**
 
 CommandParser is the latest parsing mechanism developed with BFS algorithm.
 In the beginning it initializes CPPaths*, each is an instance with append(char) method which will report back whether or not CommandParser should go down its path.
 As CommandParser gets more character to process, the branches (CPPaths*) getting smaller until the point that there's one last standing or one of the CPPaths reports back Resolved state.
 
*/

class CommandParser {
    
    init() {
        self.data = CPData()
        paths = [
            CPPathStyleDeclaration(),
            CPPathMixinHeader(),
            CPPathRuleSetHeader(),
            CPPathScopeClosure(),
            CPPathExtend(),
            CPPathInclude(),
            CPPathImport()
        ]
    }
    
    func append(c : CPChar) -> CPPathResolution? {
        
        // We're going to filter out comments and prefix spaces here.
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
    
    private typealias CPPath = protocol<CPAppendable>
    
    private var paths : [CPPath] = []

    private enum AppendState {
        case Append
        case PossiblyStartSkip
        case Skip
        case PossiblyEndSkip
    }
    
    private var appendState : AppendState = .Append
    private var data : CPData
    
    private func doAppend(c : CPChar) -> CPPathResolution? {

        data.append(c)
        let insertIndex = data.characters.endIndex.predecessor()
        
        var newPaths : [CPPath] = []
        
        for path in paths {
            
            let result = path.append(c, atIndex: insertIndex , latestData:  data)
            switch result {
                
            case .InProgress:
                newPaths.append(path)
            case .Invalid:
                continue
            case .Resolved(let resolution):
                return resolution // Done
                
            }
        }
        
        paths = newPaths
        if paths.count == 0 {
            return nil // Gives up. There's no parser matching this line.
        }
        
        return .InProgress
    }

}