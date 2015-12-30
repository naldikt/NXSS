//
//  UINavigationBarViewController.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/28/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class UINavigationBarViewController : UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.nxssClass = "uinavigationbar-bar"
        self.navigationItem.title = "Red Bar, White Button"
        
        let closeButton = UIButton(frame: CGRectMake(0,0,50,50))
        closeButton.nxssClass = "uinavigationbar-close-button"
        closeButton.addTarget(self, action: "closeButtonTapped:", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)

    }
    
    func closeButtonTapped(sender:AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}