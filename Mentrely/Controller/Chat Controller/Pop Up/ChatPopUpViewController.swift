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
import UIColor_Hex_Swift
import NVActivityIndicatorView

class ChatPopUpViewController: UIViewController, NVActivityIndicatorViewable, UIGestureRecognizerDelegate {
 
    @IBOutlet var outerCard: UIView!
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var depressionCard: UIView!
    @IBOutlet weak var depressionImageView: UIImageView!
    @IBOutlet weak var thoughtDepressionImage: UIImageView!
    @IBOutlet weak var memberCounter: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var namaPenyakitLabel: UILabel!
    @IBOutlet weak var namaDokterPenyakit: UILabel!
    @IBOutlet weak var isiParagraphPenyakit: UITextView!
    
    private var backgroundImage : [UIImage] = [UIImage(named:"thoughtDepression")!,UIImage(named:"Hyper")!,UIImage(named:"Bipolar2")!,UIImage(named:"Anxiety")!,UIImage(named:"OCD-1")!,UIImage(named:"PTSD-1")!]
    private var profileImage    : [UIImage] = [UIImage(named: "depression-1")!, UIImage(named: "ADHD")!, UIImage(named: "Bipolar")!,  UIImage(named: "anxietyProfile")!, UIImage(named: "OCD")!, UIImage(named: "PTSDProfile")!,]
    private var namaPenyakit  = ["Depression", "Hyperactivity", "Bipolar", "Anxiety", "Obsessive Compulsive Disorder", "Post Traumatic Disorder"]
    private let childDatabase = ["Messages", "messages2", "messages3", "Messages4", "Messages5", "Messages6"]
    private let namaDoktor    = ["Dr. Andy", "Dr. Bianca", "Dr.Hermawan", "Dr. Agatha", "Dr. Aurel", "Dr. Stefan", "Dr. Puan"]
    private let isiPenyakit   = ["Depression (major depressive disorder) is a common and serious medical illness that negatively affects how you feel, the way you think and how you act. Fortunately, it is also treatable. Depression causes feelings of sadness and/or a loss of interest in activities once enjoyed. ", "Hyperactivity is a state of being unusually or abnormally active. It’s often difficult to manage for people around the person who’s hyperactive, such as teachers, employers, and parents. The symptoms appear before a person is twelve years old.", "Bipolar disorder, previously known as manic depression, is a mental disorder that causes periods of depression and periods of abnormally elevated mood. The elevated mood is significant and is known as mania, or hypomania if less severe and symptoms of psychosis are absent. ", "Anxiety disorders affect 40 million people in the United States. It is the most common group of mental illnesses in the country. However, only 36.9 percent of people with an anxiety disorder receive treatment.", "Obsessive-Compulsive Disorder (OCD) is a common, chronic and long-lasting disorder in which a person has uncontrollable, reoccurring thoughts (obsessions) and behaviors (compulsions) that he or she feels the urge to repeat over and over.", "Post-traumatic stress disorder (PTSD) is a mental health condition that's triggered by a terrifying event — either experiencing it or witnessing it. Symptoms may include flashbacks, nightmares and severe anxiety, as well as uncontrollable thoughts about the event."]

    var userName = ""
    var mental   = ""
    var snapshot = 0
    var indexpath  = 0
    let userUID = Auth.auth().currentUser?.uid

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        self.depressionImageView.image = self.profileImage[self.indexpath]
        self.thoughtDepressionImage.image = self.backgroundImage[self.indexpath]
        self.namaPenyakitLabel.text = self.namaPenyakit[indexpath]
        self.namaDokterPenyakit.text = self.namaDoktor[self.indexpath]
        self.isiParagraphPenyakit.text = self.isiPenyakit[indexpath]
        let ref = Database.database().reference()
        switch indexpath {
        case 0:
        let depressionMessageRoom = ref.child("users").child(userUID!)
        depressionMessageRoom.observe(DataEventType.value) { (snapshot) in
            if let snapshotValue = snapshot.value as? [String:String] {
                let depressionRoomValue = snapshotValue["DepressionRoom"]
                if depressionRoomValue == "1"  {
                    self.joinButton.isHidden = true
                } else {
                    self.joinButton.isHidden = false
                }
            }
        }
        break
        case 1:
        let ref = Database.database().reference()
          let hyperRoom = ref.child("users").child(userUID!)
          hyperRoom.observe(DataEventType.value) { (snapshot) in
              if let snapshotValue = snapshot.value as? [String:String] {
                  let hyperRoomValue = snapshotValue["HyperRoom"]
                  if hyperRoomValue == "1"  {
                      self.joinButton.isHidden = true
                  } else {
                      self.joinButton.isHidden = false
                  }
              }
          }
        break
        case 2:
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
        break
        case 3:
            let ref = Database.database().reference().child("users").child(userUID!)
            ref.observe(DataEventType.value) { (snapshot) in
                if let snapshotValue = snapshot.value as? [String:String] {
                    if let anxietyRoom = snapshotValue["AnxietyRoom"]  {
                        if anxietyRoom == "1" {
                            self.joinButton.isHidden = true
                        } else {
                            self.joinButton.isHidden = false
                        }
                    }
                }
            }
        break
        case 4:
        let ref = Database.database().reference().child("users").child(userUID!)
             ref.observe(DataEventType.value) { (snapshot) in
                 if let snapshotValue = snapshot.value as? [String:String] {
                     if let OCDRoom = snapshotValue["OCDRoom"] {
                         if OCDRoom == "1" {
                             self.joinButton.isHidden = true
                         } else {
                             self.joinButton.isHidden = false
                         }
                     }
                 }
            }
        break
        case 5:
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
        break
        default:
        print("tidak ada")
        break
        }
        let messageUsersCount = ref.child("users").child("registeredUsers").child(childDatabase[indexpath])
        messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                self.snapshot = snapshots.count
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        depressionImageView.roundedCorner()
        depressionCard.corner10()
        thoughtDepressionImage.cornerImage10()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapped(gesture:)))
        gesture.delegate = self
        outerCard.addGestureRecognizer(gesture)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.outerCard {
            return false
        }

        return true
    }
    
    @objc func handleTapped(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let ref = Database.database().reference()
        ref.removeAllObservers()
    }
    
 
    @IBAction func joinPressed(_ sender: Any) {
        showLoading(message: "Loading", secondMessage: "Hold On")
        joinButton.isHidden = true
        let depressionController  = ChatViewController()
        let presentingViewController = self.presentingViewController
        let ref = Database.database().reference().child("users").child(self.userUID!)
        let messageUsers = Database.database().reference().child("users").child("registeredUsers").child(self.childDatabase[self.indexpath]).child(self.userUID!)
               ref.observe(DataEventType.value) { (snapshot) in
                   if let snapshotValue = snapshot.value as? [String:String] {
                       if let username = snapshotValue["username"] {
                           self.userName = username
                           let mental = snapshotValue["mental"]
                           self.mental = mental!
                           let profilePhotoURL = snapshotValue["profileImage"]
                           let selectedHyper  = snapshotValue["HyperRoom"]
                           let bipolarRoom    = snapshotValue["BipolarRoom"]
                           let anxietyRoom    = snapshotValue["AnxietyRoom"]
                           let ocdRoom        = snapshotValue["OCDRoom"]
                           let ptsdRoom       = snapshotValue["PTSDRoom"]
                           let depressionRoom = snapshotValue["DepressionRoom"]
                         
        DispatchQueue.main.asyncAfter(deadline:.now() + 1) {
            switch self.indexpath {
               case 0:
                     messageUsers.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": "1", "HyperRoom" :  selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                     ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": "1", "HyperRoom" :  selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                     depressionController.navigationTitle = "Depression Group (\(self.snapshot+1))"
                     self.stopAnimating(nil)
               break
               case 1:
                         messageUsers.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : "1", "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
            
                         ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : "1", "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                            
                            depressionController.segueIndex = 1
                            depressionController.navigationTitle = "Hyperactivity Group (\(self.snapshot+1))"
                            depressionController.database = "messages2"
                            depressionController.snackbar.message = "Welcome To Hyper Support Group"
                            self.stopAnimating(nil)
               break
               case 2:
                    messageUsers.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": "1", "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                      ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": "1", "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                          
                            depressionController.segueIndex = 2
                            depressionController.navigationTitle = "Bipolar Group (\(self.snapshot+1))"
                            depressionController.database = "messages3"
                            depressionController.snackbar.message = "Welcome To Bipolar Support Group"
                            self.stopAnimating(nil)

               break
               case 3:
                      messageUsers.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": "1", "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                      ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": "1", "OCDRoom": ocdRoom!, "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                    
                            depressionController.segueIndex = 3
                            depressionController.navigationTitle = "Anxiety Group (\(self.snapshot+1))"
                            depressionController.database = "Messages4"
                            depressionController.snackbar.message = "Welcome To Anxiety Support Group"
                            self.stopAnimating(nil)
               break
               case 4:
                    messageUsers.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": "1", "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
                    ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": "1", "PTSDRoom": ptsdRoom!, "profileImage":profilePhotoURL!])
              
                            depressionController.segueIndex = 4
                            depressionController.navigationTitle = "OCD Group *\(self.snapshot+1))"
                            depressionController.database = "Messages5"
                            depressionController.snackbar.message = "Welcome To OCD Support Group"
                            self.stopAnimating(nil)
                                
               break
               case 5:
                     messageUsers.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": "1", "profileImage":profilePhotoURL!])
                     ref.setValue(["email": Auth.auth().currentUser?.email!, "username": self.userName, "mental": self.mental, "DepressionRoom": depressionRoom!, "HyperRoom" : selectedHyper!, "BipolarRoom": bipolarRoom!, "AnxietyRoom": anxietyRoom!, "OCDRoom": ocdRoom!, "PTSDRoom": "1", "profileImage":profilePhotoURL!])
                   
                            depressionController.segueIndex = 5
                            depressionController.navigationTitle = "PTSD Group (\(self.snapshot+1))"
                            depressionController.database = "Messages6"
                            depressionController.snackbar.message = "Welcome To PTSD Support Group"
                            self.stopAnimating(nil)
               break
               default:
                print("tidak ada")
                self.joinButton.isHidden = false
               break
                           }
                     }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.dismiss(animated: true, completion: {
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "firstTime"), object: nil)
               presentingViewController!.performSegue(withIdentifier: "depressionSegue", sender: self)
                depressionController.snackbar.animationType = .slideFromTopBackToTop
                
           })
        }
    }
    
    private func showLoading(message: String, secondMessage : String) {
        let size = CGSize(width: 30, height: 30)
           startAnimating(size, message: message, type: .squareSpin, color: UIColor.white, textColor: UIColor.white)
           DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
               NVActivityIndicatorPresenter.sharedInstance.setMessage(secondMessage)
        }
    }
 }
