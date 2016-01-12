//
//  UINavViewControllerTransparent.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 1/11/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class UINavViewControllerTransparent : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.nxssClass = "uinavviewcontrollertransparent-navigationbar"
    }
}