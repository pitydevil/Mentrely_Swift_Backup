//
//  scrollView.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 29/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import Foundation
import UIKit
import ESPullToRefresh

extension UIScrollView {

self..es.addPullToRefresh {
    [unowned self] in
    /// Do anything you want...
    /// ...
    /// Stop refresh when your job finished, it will reset refresh footer if completion is true
    self.tableView.es.stopPullToRefresh(completion: true)
    /// Set ignore footer or not
    self.tableView.es.stopPullToRefresh(completion: true, ignoreFooter: false)
}

}
