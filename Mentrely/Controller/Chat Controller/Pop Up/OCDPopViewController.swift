//
//  OCDPopViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class OCDPopViewController: UIViewController {

  
    @IBOutlet weak var OCDCard: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var bipolarImageView: UIImageView!
    @IBOutlet weak var bipolarTopImageView: UIImageView!
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
        bipolarImageView.layer.cornerRadius = bipolarImageView.layer.frame.height/2
        OCDCard.layer.cornerRadius  = 10
        bipolarTopImageView.layer.cornerRadius = 10
        
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
                       let selectedAnxiety = snapshotValue["AnxietyRoom"]
                    self.anxiety = selectedAnxiety ?? ""
                       let bipolarRoom    = snapshotValue["BipolarRoom"]
                    self.bipolar = bipolarRoom ?? ""
                       let depressionRoom = snapshotValue["DepressionRoom"]
                    self.depression = depressionRoom ?? ""
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
                if let OCDRoom = snapshotValue["OCDRoom"] {
                    if OCDRoom == "1" || Auth.auth().currentUser?.isAnonymous == true  {
                        self.joinButton.isHidden = true
                    } else {
                        self.joinButton.isHidden = false
                    }
                }
            }
        }
        
        let messageUsersCount = Database.database().reference().child("users").child("registeredUsers").child("Messages5")
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
        let messages2Ref = Database.database().reference().child("users").child("registeredUsers").child("Messages5").child(userUID!)
        messages2Ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": "1", "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": "1", "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    
                    let OCDController = DepressionViewController()
                    let presentingViewController = self.presentingViewController
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: {
                            presentingViewController?.performSegue(withIdentifier: "depressionSegue", sender: self)
                            
                            OCDController.snackbar.animationType = .slideFromTopBackToTop
                            OCDController.snackbar.animationDuration = 1.5
                            OCDController.snackbar.topMargin    = 50
                            OCDController.snackbar.shouldDismissOnSwipe = true
                            OCDController.snackbar.cornerRadius         = 15
                            OCDController.segueIndex = 4
                            OCDController.navigationTitle = "OCD Group"
                            OCDController.database = "Messages5"
                            OCDController.snackbar.backgroundColor      = UIColor.purple
                            OCDController.snackbar.messageTextColor     = UIColor.white
                            OCDController.snackbar.message = "Welcome To OCD Support Group"
                            OCDController.snackbar.show()
                        })
                    }
                }
            }
