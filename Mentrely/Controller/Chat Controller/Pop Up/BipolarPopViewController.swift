//
//  BipolarPopViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class BipolarPopViewController: UIViewController {

    @IBOutlet weak var bipolarCard: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var bipolarImageView: UIImageView!
    @IBOutlet weak var bipolarTopImageView: UIImageView!
    @IBOutlet weak var memberCounter: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var outerCard: UIView!
     var depression = ""
     var hyper      = ""
     var bipolar    = ""
     var anxiety    = ""
     var OCD        = ""
     var PTSD       = ""
     var userName   = ""
     var mental     = ""
        var profileImage = ""
     let userUID = Auth.auth().currentUser?.uid

    
    override func viewDidLoad() {
        super.viewDidLoad()
        bipolarImageView.layer.cornerRadius = bipolarImageView.layer.frame.height/2
        bipolarCard.layer.cornerRadius  = 10
        bipolarTopImageView.layer.cornerRadius = 10
 
        let tapped = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        outerCard.addGestureRecognizer(tapped)
        let ref = Database.database().reference().child("users").child(userUID!)
              
              ref.observe(DataEventType.value) { (snapshot) in
                  if let snapshotValue = snapshot.value as? [String:String] {
                      if let username = snapshotValue["username"] {
                        self.userName = username
                          let selectedMental = snapshotValue["mental"]
                        self.mental = selectedMental  ?? ""
                          let depressionRoom = snapshotValue["DepressionRoom"]
                        self.depression = depressionRoom ?? ""
                          let selectedHyper  = snapshotValue["HyperRoom"]
                        self.hyper = selectedHyper ?? ""
                          let anxietyRoom = snapshotValue["AnxietyRoom"]
                        self.anxiety = anxietyRoom ?? ""
                          let ocdRoom = snapshotValue["OCDRoom"]
                        self.OCD = ocdRoom ?? ""
                          let ptsdRoom = snapshotValue["PTSDRoom"]
                        self.PTSD = ptsdRoom ?? ""
                          let profileRoom = snapshotValue["profileImage"]
                        self.profileImage = profileRoom!
                }
            }
        }
    }
    
    @objc func dismissPopUp(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        let ref = Database.database().reference().child("users").child(userUID!)
        ref.observe(DataEventType.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String:String] {
                if let bipolarRoom = snapshotValue["BipolarRoom"] {
                    if bipolarRoom == "1" {
                        self.joinButton.isHidden = true
                    } else {
                        self.joinButton.isHidden = false
                }
            }
        }
    }
        let messageUsersCount = Database.database().reference().child("users").child("registeredUsers").child("messages3")
        messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                if snapshots.count == 1 || Auth.auth().currentUser?.isAnonymous == true {
                    self.memberCounter.text = "\(snapshots.count) Member"
                } else if snapshots.count == 0 {
                    self.memberCounter.text  = "0 Member"
                } else {
                    self.memberCounter.text = "\(snapshots.count) Members"
                }
            }
        })
    }
    
    
        @IBAction func joinPressed(_ sender: Any) {
            let ref = Database.database().reference().child("users").child(userUID!)
            let messages2Ref = Database.database().reference().child("users").child("registeredUsers").child("messages3").child(userUID!)
            messages2Ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": "1", "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": "1", "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    let bipolarController =  DepressionViewController()
                    let presentingViewController = self.presentingViewController
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: {
                            presentingViewController!.performSegue(withIdentifier: "depressionSegue", sender: self)
                            bipolarController.snackbar.animationType = .slideFromTopBackToTop
                            bipolarController.snackbar.animationDuration = 1.5
                            bipolarController.snackbar.topMargin    = 50
                            bipolarController.snackbar.shouldDismissOnSwipe = true
                            bipolarController.snackbar.cornerRadius         = 15
                            bipolarController.snackbar.backgroundColor      = UIColor.purple
                            bipolarController.snackbar.messageTextColor     = UIColor.white
                            bipolarController.segueIndex = 2
                            bipolarController.navigationTitle = "Bipolar Group"
                            bipolarController.database = "messages3"
                            bipolarController.snackbar.message = "Welcome To Bipolar Support Group"
                            bipolarController.snackbar.show()
                        })
                    }
                }
            }

