//
//  NXSSError.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/6/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

public enum NXSSError : ErrorType , CustomStringConvertible {
    /** 
        `msg` should be short message explaining what went wrong.
        `line` should be the line that went wrong (if applicable).
    */
    case Parse(msg : String , statement:String?, line : Int?)               // Parsing Error.
    case Require(msg : String, statement:String?, line : Int?)              // Failed some requirements.
    
    /**
        Creates a new error by forcing the line number to be the one you specified.
    */
    static func overrideLine( error : NXSSError , line : Int ) -> NXSSError {
        switch error {
        case .Parse(let msg, let statement, _):
            return .Parse(msg:msg,statement:statement,line:line)
        case .Require(let msg, let statement, _):
            return .Require(msg:msg,statement:statement,line:line)
        }
    }
    
    
    /**
        If condition is not fulfilled, will throw .Require error.
    */
    static func throwIfNot( condition : Bool , msg : String , statement : String?=nil , line : Int?=nil ) throws {
        if !condition {
            throw NXSSError.Require(msg: msg, statement:statement, line: line)
        }
    }
    
    /**
        If object is nil, will throw .Require error.
        Otherwise returns the object.
    */
    static func throwIfNil < T : AnyObject > ( object : T? , msg : String , statement : String?=nil , line:Int? = nil ) throws -> T {
        if let object = object {
            return object
        } else {
            throw NXSSError.Require(msg: msg, statement:statement, line: line)
        }
    }
    
    
    public var description : String {
        switch self {
        case .Parse(let msg, let statement, let line):
            var s = "[NXSS] Parse Error: \(msg)\n"
            s += "Statement: \(statement)\n"            
            s += "Line: \(line)\n"
            return s
        case .Require(let msg, let statement , let line):
            var s = "[NXSS] Require Error: \(msg)\n"
            s += "Statement: \(statement)\n"
            s += "Line: \(line)\n"
            return s
        }
    }
    
}