//
//  UIViewViewController.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 12/22/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

class UIViewViewController : UIViewController {
    
    @IBOutlet weak var scrollView : UIScrollView?
    @IBOutlet weak var containerView :UIView?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let scrollView = scrollView , containerView = containerView {
            scrollView.contentSize = CGSizeMake(  scrollView.contentSize.width , containerView.frame.size.height )
        }

    }
}