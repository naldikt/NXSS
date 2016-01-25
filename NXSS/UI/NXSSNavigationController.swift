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

public enum NXSSNavigationBackButton {
    case Default    // Stick with whatever is assigned. Do not intervene.
    case EmptyText  // Assigns a new UINavigationItem with empty title so you'd see only chevron as the back button.
}

public class NXSSNavigationController : UINavigationController , UINavigationControllerDelegate {

    /* Assigns the back button style. */
    public init( backButtonStyle: NXSSNavigationBackButton ) {
        self.backButtonStyle = backButtonStyle
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        /* By default we're using the top view controller's status bar style. */
        return viewControllers.last
    }
    
    // MARK: UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        
        if self.backButtonStyle == .EmptyText {
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Done, target: nil, action: nil)
        }

        setupNav(viewController)
        
    }
    
    // MARK: - Private

    private var backButtonStyle : NXSSNavigationBackButton = .Default
    
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