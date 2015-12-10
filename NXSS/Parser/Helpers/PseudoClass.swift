//
//  PseudoClass.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 11/10/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation


/**
 Valid pseudo-class in NXSS.
 These are based on "selector-states" of UIButton.
*/
public enum PseudoClass : String {
    case Normal = "normal"
    case Highlighted = "highlighted"
    case Selected = "selected"
    case Disabled = "disabled"
}