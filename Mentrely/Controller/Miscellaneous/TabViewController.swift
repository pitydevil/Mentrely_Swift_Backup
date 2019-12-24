//
//  TabViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController, UITabBarControllerDelegate {
    
fileprivate lazy var defaultTabBarHeight = { tabBar.frame.size.height }()
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
    }
}
