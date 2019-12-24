//
//  ProfileViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 21/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var mentalText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!

    var userUID = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileImageView.backgroundColor = UIColor.black
        profileImageView.roundedCorner()
        let handleTapped = UITapGestureRecognizer(target: self, action: #selector(handleTouch))
        view.addGestureRecognizer(handleTapped)
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true
    }
    @objc func profileTapped(gesture: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "goToFullscreen", sender: self)
    }
    @objc func handleTouch(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           _ = Database.database().reference().child("users").child(userUID).observe(DataEventType.value) { (snapshot) in
              if let postDict = snapshot.value as? [String:Any] {
                    let profileImage = postDict["profileImage"] as! String
                    let mental = postDict["mental"] as! String
                    let name   = postDict["username"] as! String
                    self.profileImageView.sd_setImage(with:URL(string: profileImage ),placeholderImage:UIImage(named: "finalProfile"))
                    self.mentalText.text = mental
                    self.usernameText.text = name
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullscreen" {
            if let nextViewController = segue.destination as? FullscreenViewController {
                nextViewController.userUID = userUID
            }
        }
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
