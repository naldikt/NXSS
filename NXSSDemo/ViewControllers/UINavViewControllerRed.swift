//
//  UINavViewControllerRed.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 1/11/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class UINavViewControllerRed : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.nxssClass = "uinavviewcontrollerred-navigationbar"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "close", style: .Done, target: self, action: "close:")
    }
    
    func close(sender:AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}