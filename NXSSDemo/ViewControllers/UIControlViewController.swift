//
//  UIControlViewController.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/22/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class UIControlViewController : UIViewController {
    
    @IBOutlet weak var controlButton:UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlButton?.titleLabel?.numberOfLines = 0
    }
    
    // MARK: - IBAction
    
    @IBAction func controlButtonTapped(sender:UIButton) {
        sender.selected = !sender.selected
    }
    
}