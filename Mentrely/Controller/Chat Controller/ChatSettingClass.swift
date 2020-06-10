//
//  ChatSettingClass.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 06/01/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class ChatSettingClass: UIViewController, NVActivityIndicatorViewable, UIGestureRecognizerDelegate{

    @IBOutlet weak var notificationChatSetting: UISwitch!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var ChatSettingView: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!

    var indexpath = 0
    private let childDatabase = ["Messages", "messages2", "messages3", "Messages4", "Messages5", "Messages6"]
    private let userUID = Auth.auth().currentUser?.uid
    private var selectedImage   : UIImage?
    private var namaUser        : String?
    private var userMental      : String?
    private var hyperUser       : String?
    private var selectedBipolar : String?
    private var selectedDepression  : String?
    private var selectedOCD     : String?
    private var selectedAnxiety : String?
    private var selectedPTSD    : String?
    private var userImage       : String?
    private var selectedArticle : String?
    
    override func viewWillAppear(_ animated: Bool) {
        view.isOpaque = false
        
        UIView.animate(withDuration: 0.3, delay: 0.35, options: .transitionCrossDissolve ,animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
              }, completion: {(true) in
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
        ChatSettingView.layer.borderWidth = 0.5
        ChatSettingView.layer.borderColor = UIColor.lightGray.cgColor
        ChatSettingView.setLayer()
        ChatSettingView.corner10()
      
        let tapped = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        tapped.delegate = self
        view.addGestureRecognizer(tapped)
        
        notificationSwitch.setOn(false, animated: false)
        definesPresentationContext = true
        let ref = Database.database().reference().child("users").child(self.userUID!)
           ref.observe(DataEventType.value) { (snapshot) in
             if let snapshotValue = snapshot.value as? [String:String] {
                 if let userName = snapshotValue["username"] {
                     let mental = snapshotValue["mental"]!
                     let profilePhotoURL = snapshotValue["profileImage"]
                     let selectedHyper  = snapshotValue["HyperRoom"]
                     let bipolarRoom    = snapshotValue["BipolarRoom"]
                     let anxietyRoom    = snapshotValue["AnxietyRoom"]
                     let ocdRoom        = snapshotValue["OCDRoom"]
                     let ptsdRoom       = snapshotValue["PTSDRoom"]
                     let depressionRoom = snapshotValue["DepressionRoom"]
                        self.namaUser   = userName
                        self.userMental  = mental
                        self.hyperUser      = selectedHyper ?? "0"
                        self.selectedBipolar = bipolarRoom ?? "0"
                        self.selectedDepression = depressionRoom ?? "0"
                        self.selectedAnxiety = anxietyRoom ?? "0"
                        self.selectedOCD     = ocdRoom ?? "0"
                        self.selectedPTSD    = ptsdRoom ?? "0"
                        self.userImage = profilePhotoURL ?? ""
                        ref.removeAllObservers()
                }
            }
        }
    }
    func observerTest() {
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        let ref = Database.database().reference().child("users").child(self.userUID!)
        ref.removeAllObservers()
    }
    @objc func handleTapped(sender: UITapGestureRecognizer) {
       UIView.animate(withDuration: 0.1, delay: 0.01, options: .curveEaseIn ,animations: {
            self.view.backgroundColor = UIColor.clear
          }, completion: { (true) in
           // let depressionView = DepressionViewController()
                self.dismiss(animated: true) {
                    //depressionView.createFloatingButton()
                }
          })
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != self.view {
            return false
        }
        return true
    }
    
    private func dismissingBackgroundView() {
        let navigationController = self.presentingViewController as? UINavigationController
        UIView.animate(withDuration: 0.2, delay: 0.01, options: .curveEaseIn ,animations: {
          self.view.backgroundColor = UIColor.clear
                print("masuk")
        }, completion: { (true) in
              self.dismiss(animated: true) {
                navigationController?.popToRootViewController(animated: true)
              }
        })
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Are You Sure?", message: "You won't be able to recover the chat history", preferredStyle: .alert)
        let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yes = UIAlertAction(title: "Yes", style: .destructive) { (UIAlertAction) in
            print(self.indexpath)
            self.showLoading(message: "Loading", secondMessage: "Hang In There")
            let messageUsers = Database.database().reference().child("users").child("registeredUsers").child(self.childDatabase[self.indexpath]).child(self.userUID!)
            let ref = Database.database().reference().child("users").child(self.userUID!)
        
              switch self.indexpath {
                 case 0:
                        messageUsers.removeValue()
                        ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.userMental, "DepressionRoom": "0", "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])
                        self.stopAnimating(nil)
                        self.dismissingBackgroundView()
                 break
                 case 1:
                        messageUsers.removeValue()
                        ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.userMental, "DepressionRoom": self.selectedDepression, "HyperRoom": "0","BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])
                        self.stopAnimating(nil)
                        self.dismissingBackgroundView()
                 break
                 case 2:
                         messageUsers.removeValue()
                         ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.userMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": "0","AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])
                         self.stopAnimating(nil)
                         self.dismissingBackgroundView()
                 break
                 case 3:
                        messageUsers.removeValue()
                        ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.userMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": "0", "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])
                         self.stopAnimating(nil)
                         self.dismissingBackgroundView()
                 break
                 case 4:
                        messageUsers.removeValue()
                        ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.userMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": "0", "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])

                        self.stopAnimating(nil)
                        self.dismissingBackgroundView()
                 break
                 case 5:
                        messageUsers.removeValue()
                        ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.userMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": "0",  "profileImage": self.userImage])
                        self.stopAnimating(nil)
                        self.dismissingBackgroundView()
                break
                
             default:
                self.stopAnimating(nil)
             break
            }
            print("out")
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutSwitch(_ sender: Any) {
        
    }
    
    private func showLoading(message: String, secondMessage : String) {
           let size = CGSize(width: 30, height: 30)
               startAnimating(size, message: message, type: .squareSpin, color: UIColor.white, textColor: UIColor.white)
              DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                  NVActivityIndicatorPresenter.sharedInstance.setMessage(secondMessage)
              }
       }
}
