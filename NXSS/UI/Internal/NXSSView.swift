//
//  NXSSView.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/13/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation

public protocol NXSSView {
    
    /** Set the nxssClass to use */
    var nxssClass : String? { get set }
    
    /** ApplyNXSS calls _styleElement and _styleClass */
    func applyNXSS()
    
}

internal protocol NXSSViewApplicator {
    
    /** Style using the element */
    func applyNXSS_styleElement() throws
    
    /** Style using the styleClass */
    func applyNXSS_styleClass() throws

}