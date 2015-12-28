//
//  UILabelViewController.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/22/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class UILabelViewController : UIViewController {
    @IBOutlet weak var  testLabel : UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testLabel?.text = ""
//        stringWithHexString
    }
    
//    func stringWithHexString(hex: String) -> String
//    {
//        var hex = hex
//        var s: String = ""
//        while(hex.characters.count > 0) {
//            var c: String = hex.substringToIndex(advance(hex.startIndex, 2))
//            hex = hex.substringFromIndex(advance(hex.startIndex, 2))
//            var ch: UInt32 = 0
//            NSScanner(string: c).scanHexInt(&ch)
//            s = s.stringByAppendingString(String(format: "%c", ch))
//        }
//        return s
//    }
//    
}