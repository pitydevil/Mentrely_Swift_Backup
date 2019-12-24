//
//  AnxietyPopViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AnxietyPopViewController: UIViewController {
 
    @IBOutlet weak var AnxietyCard: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var AnxietyImageView: UIImageView!
    @IBOutlet weak var AnxietyTopImageView: UIImageView!
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
        var profileImage = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        AnxietyImageView.layer.cornerRadius = AnxietyImageView.layer.frame.height/2
        AnxietyCard.layer.cornerRadius  = 10
        AnxietyTopImageView.layer.cornerRadius = 10
        
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
                if let anxietyRoom = snapshotValue["AnxietyRoom"]  {
                    if anxietyRoom == "1" || Auth.auth().currentUser?.isAnonymous == true {
                        self.joinButton.isHidden = true
                    } else {
                        self.joinButton.isHidden = false
                    }
                }
            }
        }
        let messageUsersCount = Database.database().reference().child("users").child("registeredUsers").child("Messages4")
        messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                if snapshots.count == 1 {
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
        let messages2Ref = Database.database().reference().child("users").child("registeredUsers").child("Messages4").child(userUID!)
        messages2Ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": "1", "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": "1", "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    let anxietyController = DepressionViewController()
                    let presentingViewController = self.presentingViewController
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: {
                            presentingViewController!.performSegue(withIdentifier: "depressionSegue", sender: self)
                            
                            anxietyController.snackbar.animationType = .slideFromTopBackToTop
                            anxietyController.snackbar.animationDuration = 1.5
                            anxietyController.snackbar.topMargin    = 50
                            anxietyController.snackbar.shouldDismissOnSwipe = true
                            anxietyController.segueIndex = 3
                            anxietyController.navigationTitle = "Anxiety Group"
                            anxietyController.database = "Messages4"
                            anxietyController.snackbar.cornerRadius         = 15
                            anxietyController.snackbar.backgroundColor      = UIColor.purple
                            anxietyController.snackbar.messageTextColor     = UIColor.white
                            anxietyController.snackbar.message = "Welcome To Anxiety Support Group"
                            anxietyController.snackbar.show()
                        })
                    }
                }
        }

