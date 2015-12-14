//
//  ViewController.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 10/3/15.
//  Copyright © 2015 Nalditya Kusuma. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var button: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Handler
    
    @IBAction func buttonTapped(sender:UIButton) {
        sender.selected = !sender.selected
    }
}

