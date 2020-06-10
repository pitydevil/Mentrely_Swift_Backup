//
//  LoadingViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 15/01/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import FirebaseAuth
import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        if Reachability.isConnectedToNetwork() == true {
          if Auth.auth().currentUser != nil {
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
              NotificationCenter.default.post(name: NSNotification.Name(rawValue: "message"), object: nil)
              print("keakses")
          }else {
              print("Not Signed In")
          }
      }else {
          print("Not Connected to Network")
      }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.performSegue(withIdentifier: "goToMain", sender: self)
    }
}
