//
//  NXSSNavigationController.swift
//  NXSSDemo
//
//  Created by Nalditya Kusuma on 1/11/16.
//  Copyright © 2016 Nalditya Kusuma. All rights reserved.
//

import Foundation
import UIKit

/**
    Handles UINavigationControllerDelegate's page transition to apply nxss class to the navigation bar.
    This allows each UIViewController to specify their own navBar's nxssClass via its navigationItem property.
*/
public class NXSSNavigationController : UINavigationController , UINavigationControllerDelegate {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    
    // MARK: UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        setupNav(viewController)
    }
    
    // MARK: - Private
    
    func setupNav( viewController : UIViewController ) {
        
        // Find out the class to apply. This is either current navigationItem or whatever is attached to navigationBar.
        var classNameToApply : String? = navigationBar.nxssClass
        if let nxssClass = viewController.navigationItem.nxssClass {
            classNameToApply = nxssClass
        }

        // Always apply this nxssclass.
        
        let originalNXSSClass = navigationBar.nxssClass
        
        navigationBar.nxssClass = classNameToApply
        navigationBar.applyNXSS()
        
        navigationBar.nxssClass = originalNXSSClass
    }
    
    
}