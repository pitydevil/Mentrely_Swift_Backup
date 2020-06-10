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

class ProfileViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mentalText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var outerCard: UIView!
    @IBOutlet weak var innerCard: UIView!
    
    private let interactor = Interactor()
    var userUID : String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
       _ = Database.database().reference().child("users").child(userUID ?? "").observe(DataEventType.value) { (snapshot) in
             if let postDict = snapshot.value as? [String:Any] {
                   let profileImage = postDict["profileImage"] as? String
                   let mental = postDict["mental"] as? String
                   let name   = postDict["username"] as? String
                   self.profileImageView.sd_setImage(with:URL(string: profileImage ?? "" ),placeholderImage:UIImage(named: "finalProfile"))
                   self.mentalText.text = mental
                   self.usernameText.text = name
           }
       }
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.backgroundColor = UIColor.black
        profileImageView.roundedCorner()
        
        let handleTapped = UITapGestureRecognizer(target: self, action: #selector(handleTouch))
        handleTapped.delegate = self
        handleTapped.numberOfTapsRequired = 1
        outerCard.addGestureRecognizer(handleTapped)
    }
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.outerCard
        {
            return false
        }
        return true
    }
   
    @objc func handleTouch(_ sender:UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func profileTapped(gesture: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "goToFullscreen", sender: self)
    }
      
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullscreen" {
            if let nextViewController = segue.destination as? FullscreenViewController {
                nextViewController.userUID = userUID ?? ""
                nextViewController.interactor = interactor
                nextViewController.transitioningDelegate = self
            }
        }
    }
    
    @IBAction func dismissButton(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension ProfileViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
      
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
