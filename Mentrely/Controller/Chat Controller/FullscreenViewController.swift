//
//  FullscreenViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 20/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class FullscreenViewController: UIViewController {
    

    @IBOutlet weak var profileImage: UIImageView!
    var userUID = ""

    override func viewWillAppear(_ animated: Bool) {
        
         _ = Database.database().reference().child("users").child(userUID).observe(DataEventType.value) { (snapshot) in
                   if let postDict = snapshot.value as? [String:Any] {
                       let profileImage = postDict["profileImage"] as! String
                    self.profileImage.sd_setImage(with:URL(string: profileImage ),placeholderImage:UIImage(named: "finalProfile"))
                 }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidDisappear(_ animated: Bool) {
       self.navigationController?.navigationBar.isHidden = false
    }
    

  
    @IBAction func dismissButton(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion:nil)
    }

}
