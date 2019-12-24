//
//  HyperActivityPopViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 08/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HyperActivityPopViewController: UIViewController {

    @IBOutlet weak var hyperImageView: UIImageView!
    @IBOutlet weak var hyperTopImage: UIImageView!
    @IBOutlet var outerCard: UIView!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var hyperCard: UIView!
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
    var profileImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hyperCard.layer.cornerRadius = 10
        hyperImageView.layer.cornerRadius = hyperImageView.layer.frame.width/2
        hyperTopImage.layer.cornerRadius = 10
        let tapped = UITapGestureRecognizer(target: self, action: #selector(keyboardWillDismiss))
        outerCard.addGestureRecognizer(tapped)
        let userUID = Auth.auth().currentUser?.uid
          let ref = Database.database().reference().child("users").child(userUID!)
       
          
          ref.observe(DataEventType.value) { (snapshot) in
          if let snapshotValue = snapshot.value as? [String:String] {
              if let username = snapshotValue["username"] {
                self.userName = username
                  let selectedMental = snapshotValue["mental"]
                self.mental = selectedMental!
                  let depressionRoom = snapshotValue["DepressionRoom"]
                self.depression = depressionRoom!
                  let bipolarRoom    = snapshotValue["BipolarRoom"]
                self.bipolar = bipolarRoom!
                  let anxietyRoom = snapshotValue["AnxietyRoom"]
                self.anxiety = anxietyRoom!
                  let ocdRoom = snapshotValue["OCDRoom"]
                self.OCD = ocdRoom!
                  let ptsdRoom = snapshotValue["PTSDRoom"]
                self.PTSD = ptsdRoom!
                  let profileRoom = snapshotValue["profileImage"]
                self.profileImage = profileRoom!
              }
              }
          }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        let UID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let hyperRoom = ref.child("users").child(UID!)
        hyperRoom.observe(DataEventType.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String:String] {
                let hyperRoomValue = snapshotValue["HyperRoom"]
                if hyperRoomValue == "1" || Auth.auth().currentUser?.isAnonymous == true  {
                    self.joinButton.isHidden = true
                } else {
                    self.joinButton.isHidden = false
                }
            }
        }
        
        let messageUsersCount = ref.child("users").child("registeredUsers").child("messages2")
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
    
    @objc func keyboardWillDismiss (gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "depressionSegue" {
              if let nextViewController = segue.destination as? DepressionViewController {
                  nextViewController.database = "Messages2"
                  nextViewController.segueIndex = 1
                  nextViewController.navigationTitle = "\("Hyperactivity Support Group") )"
            }
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        let userUID = Auth.auth().currentUser?.uid
        let messages2Ref = Database.database().reference().child("users").child("registeredUsers").child("messages2").child(userUID!)
        messages2Ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  "1", "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
         let ref = Database.database().reference().child("users").child(userUID!)
            ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": self.depression, "HyperRoom" :  "1", "BipolarRoom": self.bipolar, "AnxietyRoom": self.anxiety, "OCDRoom": self.OCD, "PTSDRoom": self.PTSD, "profileImage":self.profileImage])
                    let hyperController = DepressionViewController()
                    let presentingViewController = self.presentingViewController
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: {
                        presentingViewController!.performSegue(withIdentifier: "depressionSegue", sender: self)
                            hyperController.snackbar.animationType = .slideFromTopBackToTop
                            hyperController.snackbar.animationDuration = 1.5
                            hyperController.snackbar.topMargin    = 50
                            hyperController.snackbar.shouldDismissOnSwipe = true
                            hyperController.snackbar.cornerRadius         = 15
                            hyperController.segueIndex = 1
                            hyperController.navigationTitle = "Hyperactivity Group"
                            hyperController.database = "messages2"
                            hyperController.snackbar.backgroundColor      = UIColor.purple
                            hyperController.snackbar.messageTextColor     = UIColor.white
                            hyperController.snackbar.message = "Welcome To Hyper Support Group"
                            hyperController.snackbar.show()
                    })
                }
            }
    }
            
