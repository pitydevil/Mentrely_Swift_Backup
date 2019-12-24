//
//  DepressionPopUpViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 08/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class DepressionPopUpViewController: UIViewController {
 
    

    @IBOutlet var outerCard: UIView!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var depressionCard: UIView!
    @IBOutlet weak var depressionImageView: UIImageView!
    @IBOutlet weak var thoughtDepressionImage: UIImageView!
    @IBOutlet weak var memberCounter: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    var depression = ""
    var hyper      = ""
    var bipolar    = ""
    var anxiety    = ""
    var OCD        = ""
    var PTSD       = ""
    var userName   = ""
    var mental     = ""
    var profilePhoto = ""
    let listTabel = ListTableViewController()
    let userUID = Auth.auth().currentUser?.uid

    
    override func viewWillAppear(_ animated: Bool) {
       
        let ref = Database.database().reference()
        let depressionMessageRoom = ref.child("users").child(userUID!)
        depressionMessageRoom.observe(DataEventType.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String:String] {
                let depressionRoomValue = snapshotValue["DepressionRoom"]
                if depressionRoomValue == "1" || Auth.auth().currentUser?.isAnonymous == true {
                    self.joinButton.isHidden = true
                } else {
                    self.joinButton.isHidden = false
                }
            }
            
        let messageUsersCount = ref.child("users").child("registeredUsers").child("Messages")
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
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        depressionImageView.layer.cornerRadius = depressionImageView.frame.height/2
        depressionCard.layer.cornerRadius = 10
        thoughtDepressionImage.layer.cornerRadius = 10
//        cell.photoTokoh.layer.cornerRadius = 5
//       cell.photoTokoh.layer.masksToBounds = true
//       cell.photoTokoh.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let tapped = UITapGestureRecognizer(target: self, action: #selector(KeyboardWillHandle))
        outerCard.addGestureRecognizer(tapped)
        
      
        let ref = Database.database().reference().child("users").child(userUID!)
        ref.observe(DataEventType.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String:String] {
                if let username = snapshotValue["username"] {
                    self.userName = username
                    let selectedMental = snapshotValue["mental"]
                    self.mental        = selectedMental!
                    let selectedHyper  = snapshotValue["HyperRoom"]
                    self.hyper         = selectedHyper!
                    let bipolarRoom    = snapshotValue["BipolarRoom"]
                    self.bipolar       = bipolarRoom!
                    let anxietyRoom    = snapshotValue["AnxietyRoom"]
                    self.anxiety       = anxietyRoom!
                    let ocdRoom        = snapshotValue["OCDRoom"]
                    self.OCD           = ocdRoom!
                    let ptsdRoom       = snapshotValue["PTSDRoom"]
                    self.PTSD          = ptsdRoom!
                    let profilePhotoURL = snapshotValue["profileImage"]
                    self.profilePhoto = profilePhotoURL!
                }
            }
        }
    }
    
    @objc func KeyboardWillHandle(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true) {
            self.listTabel.tableView.reloadData()
        }
    }

        @IBAction func joinPressed(_ sender: Any) {
                let ref       = Database.database().reference().child("users").child(userUID!)
                let messageUsers = Database.database().reference().child("users").child("registeredUsers").child("Messages").child(userUID!)
        
            messageUsers.setValue(["email": Auth.auth().currentUser?.email ?? "", "username": self.userName, "mental": self.mental, "DepressionRoom": "1", "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profilePhoto])
            ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": "1", "HyperRoom" :  self.hyper, "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage": self.profilePhoto])
                    let depressionController  = DepressionViewController()
                    let parentController = self.presentingViewController
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: {
                            parentController!.performSegue(withIdentifier: "depressionSegue", sender: self)
                             depressionController.snackbar.animationType = .slideFromTopBackToTop
                             depressionController.snackbar.animationDuration = 1.5
                             depressionController.snackbar.topMargin    = 50
                             depressionController.snackbar.shouldDismissOnSwipe = true
                             depressionController.snackbar.cornerRadius         = 15
                             depressionController.snackbar.backgroundColor      = UIColor.purple
                             depressionController.snackbar.messageTextColor     = UIColor.white
                             depressionController.snackbar.show()
                })
            }
        }
    }
