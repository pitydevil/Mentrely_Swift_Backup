//
//  PTSDPopViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PTSDPopViewController: UIViewController {

  
    @IBOutlet weak var PTSDCard: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var PTSDImageView: UIImageView!
    @IBOutlet weak var PTSDTopImageView: UIImageView!
    @IBOutlet weak var memberCounter: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var outerCard: UIView!
    
    let userUID = Auth.auth().currentUser?.uid
    var depression = ""
    var hyper      = ""
    var bipolar    = ""
    var OCD        = ""
    var PTSD       = ""
    var userName   = ""
    var mental     = ""
    var anxiety    = ""
        var profileImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PTSDImageView.layer.cornerRadius = PTSDImageView.layer.frame.height/2
        PTSDCard.layer.cornerRadius  = 10
        PTSDTopImageView.layer.cornerRadius = 10
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(dismissPopUp))
        outerCard.addGestureRecognizer(tapped)
        let ref = Database.database().reference().child("users").child(userUID!)
             
              ref.observe(DataEventType.value) { (snapshot) in
                  if let snapshotValue = snapshot.value as? [String:String] {
                      if let username = snapshotValue["username"] {
                        self.userName = username
                          let selectedMental = snapshotValue["mental"]
                        self.mental = selectedMental ?? ""
                          let selectedHyper  = snapshotValue["HyperRoom"]
                        self.hyper = selectedHyper ?? ""
                          let bipolarRoom    = snapshotValue["BipolarRoom"]
                        self.bipolar = bipolarRoom ?? ""
                          let depressionRoom = snapshotValue["DepressionRoom"]
                        self.depression = depressionRoom ?? ""
                          let anxietyRoom = snapshotValue["AnxietyRoom"]
                        self.anxiety = anxietyRoom ?? ""
                          let ocdRoom = snapshotValue["OCDRoom"]
                        self.OCD = ocdRoom ?? ""
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
                if let ptsdRoom = snapshotValue["PTSDRoom"] {
                    if ptsdRoom == "1" {
                        self.joinButton.isHidden = true
                    } else {
                        self.joinButton.isHidden = false
                    }
                }
            }
        }
        let messageUsersCount = Database.database().reference().child("users").child("registeredUsers").child("Messages6")
        messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                if snapshots.count == 1 || Auth.auth().currentUser?.isAnonymous == true  {
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
        let messages2Ref = Database.database().reference().child("users").child("registeredUsers").child("Messages6").child(userUID!)
                 
            
        messages2Ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": "1", "profileImage":self.profileImage])
            ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": "1", "profileImage":self.profileImage])
            
            let ptsdController = DepressionViewController()
            let presentingViewController = self.presentingViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dismiss(animated: true, completion: {
                    presentingViewController!.performSegue(withIdentifier: "depressionSegue", sender: self)
                    
                    ptsdController.snackbar.animationType = .slideFromTopBackToTop
                    ptsdController.snackbar.animationDuration = 1.5
                    ptsdController.snackbar.topMargin    = 50
                    ptsdController.snackbar.shouldDismissOnSwipe = true
                    ptsdController.snackbar.cornerRadius         = 15
                    ptsdController.segueIndex = 5
                    ptsdController.navigationTitle = "PTSD Group"
                    ptsdController.database = "Messages6"
                    ptsdController.snackbar.backgroundColor      = UIColor.purple
                    ptsdController.snackbar.messageTextColor     = UIColor.white
                    ptsdController.snackbar.message = "Welcome To PTSD Support Group"
                    ptsdController.snackbar.show()
                })
            }
        }
    }
