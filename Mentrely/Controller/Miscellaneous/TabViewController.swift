//
//  TabViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
class TabViewController: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
       
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func set(selectedIndex index : Int) {
         _ = self.tabBarController(self, shouldSelect: self.viewControllers![index])
     }
    
}

extension TabViewController: UITabBarControllerDelegate  {
   func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }

        if fromView != toView {

            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: { (true) in

            })

            self.selectedViewController = viewController
        }

        return true
    }
}

