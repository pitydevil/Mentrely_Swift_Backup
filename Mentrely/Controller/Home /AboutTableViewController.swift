//
//  AboutTableViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 05/02/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import TTGSnackbar
import SDWebImage
import TMPasscodeLock
import NVActivityIndicatorView
import UIColor_Hex_Swift
import MessageUI

class AboutTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable,  MFMailComposeViewControllerDelegate,  TMPasscodeLockControllerDelegate{

    @IBOutlet weak var passcodeCell: UITableViewCell!
    @IBOutlet weak var notificationCell: UITableViewCell!
    @IBOutlet weak var articleCell: UITableViewCell!
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var notificationSlider: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var mentalText: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var diaryLabel: UILabel!
    @IBOutlet weak var tellAFriendCell: UITableViewCell!
    @IBOutlet weak var versionCell: UITableViewCell!
    @IBOutlet weak var aboutCell: UITableViewCell!
    
    fileprivate let appVersion = "CFBundleShortVersionString"
    fileprivate let defaults = UserDefaults.standard
    fileprivate let mentalPicker = UIPickerView()
    fileprivate let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    fileprivate let shareWithMail = "Having problems with your psychology? Get Mentrely now only by contacting Mikhael_adiputra@yahoo.com"
    fileprivate var mental = ["Autism", "Hyperactivity Disorder", "Post Traumatic Disease", "Bipolar Disorder", "Obsessive Compulsive Disorder", "Scizophrenia", "Depression"]
    fileprivate var selectedMental: String = ""
    fileprivate var selectedImage: UIImage?
    fileprivate var namaUser: String?
    fileprivate var hyperUser: String?
    fileprivate var selectedBipolar: String?
    fileprivate var selectedDepression: String?
    fileprivate var selectedOCD: String?
    fileprivate var selectedAnxiety: String?
    fileprivate var selectedPTSD: String?
    fileprivate var userImage: String?

    
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            initialView()
            diaryLabel.text = TMPasscodeLock.isPasscodeSet ? "On" : "Off"
        }
    
        override func viewDidLoad() {
           super.viewDidLoad()
          
           initialView()
           inputPicker()
           createToolbar()
     
           notificationCell.selectionStyle = .none
        
           versionCell.isUserInteractionEnabled = false
            let view = UIView()
            view.backgroundColor = .white
            profileCell.selectedBackgroundView = view
            mentalText.backgroundColor = .lightText
            
           let barButton = UIBarButtonItem(customView: activityIndicator)
           navigationItem.setRightBarButton(barButton, animated: true)
           activityIndicator.color = UIColor.white
           tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: CGFloat.leastNormalMagnitude))
       }

       private func initialView() {
           // Version Label
           let dictionary = Bundle.main.infoDictionary!
           let version = dictionary[appVersion] as! String
           versionLabel.text = version
           profilePhoto.contentMode = .scaleAspectFill
           
           // Notification Toggler
           let hasilCheck = defaults.bool(forKey: "checkNotif")
           if hasilCheck == true {
               notificationSlider.setOn(true, animated: false)
           } else {
               notificationSlider.setOn(false, animated: false)
           }

           // Check User existance
           if Auth.auth().currentUser != nil {
               activityIndicator.startAnimating()
               let userUID = Auth.auth().currentUser?.uid
               let ref     = Database.database().reference()
               let userReference = ref.child("users")
               _ = userReference.child(userUID!).observe(DataEventType.value) { (snapshot) in
                   if let snapshotValue = snapshot.value as? [String:String] {
                       let username = snapshotValue["username"] ?? ""
                       let mental   = snapshotValue["mental"]
                       let bipolarRoom = snapshotValue["BipolarRoom"]
                       let depressionRoom = snapshotValue["DepressionRoom"]
                       let hyper    = snapshotValue["HyperRoom"]
                       let anxietyRoom = snapshotValue["AnxietyRoom"]
                       let ocdRoom = snapshotValue["OCDRoom"]
                       let ptsdRoom = snapshotValue["PTSDRoom"]
                       let profileImage = snapshotValue["profileImage"]
                       
                       self.userImage   = profileImage ?? ""
                       self.profilePhoto.sd_setImage(with:URL(string: profileImage ?? ""), placeholderImage:UIImage(named: "loadingImage"))
                       self.profilePhoto.backgroundColor   = UIColor.white
                       self.profilePhoto.layer.borderColor = UIColor("#E0E0E0").cgColor
                       self.profilePhoto.layer.borderWidth = 3
                       self.activityIndicator.stopAnimating()
                       self.namaUser        = username
                       self.mentalText.text = mental ?? ""
                       self.selectedMental  = mental ?? ""
                       self.hyperUser       = hyper ?? "0"
                       self.selectedBipolar = bipolarRoom ?? "0"
                       self.selectedDepression = depressionRoom ?? "0"
                       self.selectedAnxiety = anxietyRoom ?? "0"
                       self.selectedOCD     = ocdRoom ?? "0"
                       self.selectedPTSD    = ptsdRoom ?? "0"
                       self.mentalText.text = mental ?? "0"
                       self.nameLabel.text  = self.namaUser
                       self.defaults.set(userUID!, forKey: "userUID")
                       self.defaults.set(username, forKey: "userName")
                       } else {
                           self.nameLabel.text = Auth.auth().currentUser?.email
                       }
                   }
                   mentalText.isEnabled = true
                   profilePhoto.roundedCorner()
            
                   let handleTapped = UITapGestureRecognizer(target: self, action: #selector(handlePicker))
                   handleTapped.cancelsTouchesInView = false
                   view.addGestureRecognizer(handleTapped)
           }else {
               activityIndicator.stopAnimating()
               profilePhoto.image = UIImage(named: "finalProfile")
               profilePhoto.backgroundColor = UIColor.white
               profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
               profilePhoto.layer.borderWidth = 0
               
               nameLabel.text        = "Sign In"
               mentalText.isEnabled  = false
               mentalText.text       = ""
               selectedMental        = ""
           }
       }
    
       fileprivate func inputPicker () {
           mentalPicker.delegate = self
           mentalText.inputView = mentalPicker
           mentalPicker.backgroundColor = UIColor("#EDEDED")
       }
       
       //MARK: -- PICKER VIEW DELEGATE
       func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return mental.count
       }
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return mental[row]
       }
       
       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           if pickerView == mentalPicker {
               mentalText.text = mental[row]
           }
       }
       
       private func createToolbar() {
           let toolbar = UIToolbar()
           toolbar.sizeToFit()
           
           let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
           doneButton.tintColor = UIColor.white
           
           toolbar.setItems([doneButton], animated: true)
           toolbar.isUserInteractionEnabled = true
           toolbar.barTintColor = UIColor("#FF9300")
           mentalText.inputAccessoryView = toolbar
       }
       
       @objc func donePressed() {
           view.endEditing(true)
           let userUID = Auth.auth().currentUser?.uid
           let ref     = Database.database().reference().child("users").child(userUID!)

           ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : mentalText.text, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])
           selectedMental = mentalText.text!
       }
       
       @objc func handlePicker(gesture: UITapGestureRecognizer) {
            mentalText.text = selectedMental
            view.endEditing(true)
       }
       
       //MARK: - PROFILE FULLSCREEN
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "goToLogin" {
                 if let nextViewController = segue.destination as? LoginViewController {
                    nextViewController.condition = 1
                }
            }
       }
       
       @IBAction func notificationSettings(_ sender: AnyObject) {
           let kondisiNotifikasi = defaults.bool(forKey: "checkNotif")
           if kondisiNotifikasi == false {
               let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
               if notificationType?.rawValue == 0 {
                   print("Disabled")
                   self.notificationSlider.setOn(true, animated: true)
                   let alert = UIAlertController(title: "", message: "Turn On Mentrely's Notification in System Preferences", preferredStyle: .alert)
                   let action = UIAlertAction(title: "OK", style: .default) { (UIALertAction) in
                       self.notificationSlider.setOn(false, animated: true)
                   }
                   alert.addAction(action)
                   self.present(alert, animated: true, completion: nil)
                   
               } else {
                   let alert = UIAlertController(title: "Turn On Notifications?", message: "", preferredStyle: .alert)
                   let yes   = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                       
                       self.defaults.set(true, forKey: "checkNotif")
                       self.notificationSlider.setOn(true, animated: true)
                   }
                   let no = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
                       self.notificationSlider.setOn(false, animated: true)
                       self.defaults.set(false, forKey: "checkNotif")
                       return
                   }
                   alert.addAction(yes)
                   alert.addAction(no)
                   self.present(alert, animated: true, completion: nil)
               }
           } else {
               let notificationType = UIApplication.shared.currentUserNotificationSettings?.types
               if notificationType?.rawValue == 0 {
                   print("Disabled")
                   self.notificationSlider.setOn(false, animated: true)
                   let alert = UIAlertController(title: "", message: "Turn On Mentrely's Notification in System Preferences", preferredStyle: .alert)
                   let action = UIAlertAction(title: "OK", style: .default) { (UIALertAction) in
                       self.notificationSlider.setOn(true, animated: true)
                   }
                   alert.addAction(action)
                   self.present(alert, animated: true, completion: nil)
               } else {
                   let alert = UIAlertController(title: "Turn Off Notifications?", message: "", preferredStyle: .alert)
                   let yes   = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                       
                       self.defaults.set(false, forKey: "checkNotif")
                       self.notificationSlider.setOn(false, animated: true)
                   }
                   let no  = UIAlertAction(title: "No", style: .cancel) { (UIAlertAction) in
                       self.notificationSlider.setOn(true, animated: true)
                       self.defaults.set(false, forKey: "checkNotif")
                       return
                   }
                   alert.addAction(yes)
                   alert.addAction(no)
                   self.present(alert, animated: true, completion: nil)
               }
           }
       }
    
        //MARK: -Table View Delegate and DataSource
        override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return CGFloat.leastNormalMagnitude
        }
             
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
             if tableView.cellForRow(at: indexPath) == articleCell {
               let articleDefaults = "articleSelection"
               var article = defaults.value(forKey: articleDefaults) as? String ?? "Motivational"
                if article == "mentalhealth" {
                    article = "Mental Health"
                }
                let alert = UIAlertController(title: "Choose your Article Preference", message: "Currently Selected: \(article )", preferredStyle: .actionSheet)
                    let motivational = UIAlertAction(title: "Motivational", style: .default) { (uialertaction) in
                        self.defaults.set("Motivational", forKey: articleDefaults)
                    }
                    let depression = UIAlertAction(title: "Mental Health", style: .default) { (uialertaction) in
                        self.defaults.set("mentalhealth", forKey: articleDefaults)
                    }
                    let psychology = UIAlertAction(title: "Psychology", style: .default) { (uialertaction) in
                        self.defaults.set("Psychology", forKey: articleDefaults)
                    }
                    let news = UIAlertAction(title: "Love", style: .default) { (uialertaction) in
                         self.defaults.set("Love", forKey: articleDefaults)
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (uialertaction) in
                        return
                    }
                    
                    if article == "Motivational" {
                        motivational.isEnabled = false
                    }else if article == "Mental Health"{
                        depression.isEnabled = false
                    }else if article == "Psychology"{
                        psychology.isEnabled = false
                    }else if article == "Love"{
                        news.isEnabled = false
                    }
                alert.addAction(motivational)
                alert.addAction(depression)
                alert.addAction(psychology)
                alert.addAction(news)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                
             }else if tableView.cellForRow(at: indexPath) == profileCell{
                self.performSegue(withIdentifier: "goToAccount", sender: self)
             }else if tableView.cellForRow(at: indexPath) == passcodeCell {
                if TMPasscodeLock.isPasscodeSet {
                      performSegue(withIdentifier: "Passcode", sender: nil)
                  } else {
                   let alert = UIAlertController(title: "Setup Passcode", message: "If you forget your passcode, you'll have to delete and Reinstall Mentrely.", preferredStyle: .alert)
                   let action = UIAlertAction(title: "Turn On", style: .default) { (UIAlertAction) in
                       let passcodeLockController = TMPasscodeLockController(style: .basic, state: .set)
                       passcodeLockController.delegate = self
                       passcodeLockController.presentIn(viewController: self, animated: true)
                   }
                   let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                   alert.addAction(action)
                   alert.addAction(cancel)
                   self.present(alert, animated: true, completion: nil)
               }
             }else if tableView.cellForRow(at: indexPath) == tellAFriendCell {
                let alert =  UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                      let action = UIAlertAction(title: "Other", style: .default) { (UIAlertAction) in
                        let activityController =  UIActivityViewController(activityItems: [""], applicationActivities: nil)
                          
                          activityController.completionWithItemsHandler = { (nil, completed, _, error) in
                              if completed  {
                                  print("completed")
                              } else {
                                  print("error sharing to another apps")
                              }
                          }
                          self.present(activityController, animated: true, completion: nil)
                      }
                      let message = UIAlertAction(title: "Mail", style: .default) { (UIAlertAction) in
                           let mailVC = MFMailComposeViewController()
                            mailVC.mailComposeDelegate = self
                            mailVC.setToRecipients([])
                            mailVC.setSubject("")
                            mailVC.setMessageBody("Get Mentrely by contacting mikhael_adiputra@yahoo.com", isHTML: false)

                         self.present(mailVC, animated: true, completion: nil)
                      }
                      let cancel  = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                          return
                      }
                    alert.addAction(message)
                    alert.addAction(action)
                    alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
           tableView.deselectRow(at: indexPath, animated: true)
        }
    
    //MARK: -TMP Passcode Delegate
   func passcodeLockControllerDidCancel(passcodeLockController: TMPasscodeLockController) {
        return
    }
   func passcodeLockController(passcodeLockController: TMPasscodeLockController, didFinishFor state: TMPasscodeLockState) {
        diaryLabel.text = TMPasscodeLock.isPasscodeSet ? "On" : "Off"
        performSegue(withIdentifier: "Passcode", sender: nil)
   }
   func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
          dismiss(animated: true, completion: nil)
   }
}
