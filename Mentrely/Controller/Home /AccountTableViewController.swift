//
//  AccountTableViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 17/02/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import TTGSnackbar
import NVActivityIndicatorView
import TMPasscodeLock

class AccountTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate, NVActivityIndicatorViewable{

    @IBOutlet weak var logoutButton: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var emailCell: UITableViewCell!
    @IBOutlet weak var passwordCell: UITableViewCell!
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var emailText: UILabel!
    
    //Variables and constants for currentUser property
    fileprivate let imageView  = UIImagePickerController()
    fileprivate let interactor = Interactor()
    fileprivate var selectedMental   : String?
    fileprivate var selectedImage    : UIImage?
    fileprivate var namaUser         : String?
    fileprivate var userMental       : String?
    fileprivate var hyperUser        : String?
    fileprivate var selectedBipolar  : String?
    fileprivate var selectedDepression  : String?
    fileprivate var selectedOCD      : String?
    fileprivate var selectedAnxiety  : String?
    fileprivate var selectedPTSD     : String?
    fileprivate var userProfileImage : String?
    
    fileprivate let defaults = UserDefaults.standard
    
    let snackbar = TTGSnackbar(message: "Your password is changed", duration: .middle)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //initialView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        nameTextField.delegate = self
        emailCell.isUserInteractionEnabled = false
        profileCell.selectionStyle = .none
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        tapped.cancelsTouchesInView = false
        view.addGestureRecognizer(tapped)
        NotificationCenter.default.addObserver(self, selector: #selector(self.logOut), name: NSNotification.Name(rawValue: "signOut"), object: nil)
    }
    
    @objc private func logOut() {
        initialView()
    }
    
    fileprivate func initialView() {
        saveButton.isEnabled    = false
        saveButton.tintColor    = .clear
        profileImage.roundedCorner()
        if Auth.auth().currentUser != nil {
    
            emailLabel.text = Auth.auth().currentUser?.email
            nameTextField.isEnabled = true
            logoutButton.text = "Sign Out"
            logoutButton.textColor = UIColor.systemRed
            
            passwordCell.accessoryType = .disclosureIndicator
            passwordCell.isUserInteractionEnabled = true
            
            emailText.textColor = .black
            resetPasswordLabel.textColor = .black
    
            profileImage.isUserInteractionEnabled = true
            
            editButton.isEnabled = true
            editButton.setTitleColor(.systemBlue, for: .normal)
            
            let tapped = UITapGestureRecognizer(target: self, action: #selector(tappedProfile))
            profileImage.addGestureRecognizer(tapped)
            
            let userUID = Auth.auth().currentUser?.uid
            let ref     = Database.database().reference().child("users")
            _ = ref.child(userUID!).observe(DataEventType.value) { (snapshot) in
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
                    
                    self.nameTextField.text = username
                    self.userProfileImage = profileImage
                    self.profileImage.sd_setImage(with:URL(string: profileImage ?? ""), placeholderImage:UIImage(named: "loadingImage"))
                    self.profileImage.backgroundColor   = .white
                    self.profileImage.layer.borderColor = UIColor("#E0E0E0").cgColor
                    self.profileImage.layer.borderWidth = 3
              
                    self.namaUser        = username
                    self.selectedMental  = mental ?? ""
                    self.hyperUser       = hyper ?? "0"
                    self.selectedBipolar = bipolarRoom ?? "0"
                    self.selectedDepression = depressionRoom ?? "0"
                    self.selectedAnxiety = anxietyRoom ?? "0"
                    self.selectedOCD     = ocdRoom ?? "0"
                    self.selectedPTSD    = ptsdRoom ?? "0"
                    self.defaults.set(userUID!, forKey: "userUID")
                    self.defaults.set(username, forKey: "userName")
                }
            }
        }else {
            emailLabel.text   = ""
            logoutButton.text = "Login"
            logoutButton.textColor = .systemBlue
            
            nameTextField.text        = ""
            nameTextField.placeholder = "Sign In"
            nameTextField.isEnabled   = false
            
            profileImage.isUserInteractionEnabled = false
            profileImage.image = UIImage(named: "finalProfile")
            profileImage.layer.borderWidth = 0
            
            passwordCell.isUserInteractionEnabled = false
            passwordCell.accessoryType = .none
            
            emailText.textColor = .lightGray
            resetPasswordLabel.textColor = .lightGray
   
            editButton.isEnabled = false
            editButton.setTitleColor(.systemGray, for: .normal)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.snackbar.dismiss()
    }
    @objc func tappedProfile() {
        self.performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    //MARK: - IMAGE PICKER CONTROLLER ATAU CAMERA
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.dismiss(animated: true, completion: nil)
            self.profileImage.image = imagePicked
            self.showLoading(message: "Uploading", secondMessage: "Finishing Uploading")
            DispatchQueue.global(qos: .background).async {
               let imageName = UUID().uuidString
               let imageRef = Storage.storage().reference().child("userProfile").child(imageName)
                   var dataImage = Data()
                   dataImage = imagePicked.jpegData(compressionQuality: 0.2)!
                   imageRef.putData(dataImage, metadata: nil){ (metadata, error) in
                       if error != nil {
                           print(error!)
                       } else {
                           imageRef.downloadURL { (url, error) in
                               guard let downloadURL = url else { return }
                               let userUID = Auth.auth().currentUser?.uid
                               let ref = Database.database().reference().child("users").child(userUID!)
                               ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.selectedMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": downloadURL.absoluteString])
                            self.userProfileImage = downloadURL.absoluteString
                            self.profileImage.image = imagePicked
                            self.stopAnimating(nil)
                           }
                       }
                   }
                }
            }
        }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        imageView.delegate = self
        imageView.allowsEditing = true
          
          let alert = UIAlertController(title: "Add an image", message: "Choose From", preferredStyle: .actionSheet)
          let camera = UIAlertAction(title: "Take a Photo", style: .default) { (UIAlertAction) in
              self.imageView.sourceType = .camera
              self.profileImage.layer.borderWidth = 3
              self.present(self.imageView, animated: true, completion: nil)
          }
          let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
              self.imageView.sourceType = .photoLibrary
              self.profileImage.layer.borderWidth = 3
              self.present(self.imageView, animated: true, completion: nil)
          }
            
          let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
               self.imageView.sourceType = .savedPhotosAlbum
               self.profileImage.layer.borderWidth = 3
               self.present(self.imageView, animated: true, completion: nil)
          }
               
          let deleteButton = UIAlertAction(title: "Delete Profile Photo", style: .destructive) { (UIAlertAction) in
                 self.profileImage.image = UIImage(named: "finalProfile")
                 self.profileImage.layer.borderWidth = 0
                 let userUID = Auth.auth().currentUser?.uid
                 let ref = Database.database().reference().child("users").child(userUID!)
           
                 ref.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.selectedMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": "https://firebasestorage.googleapis.com/v0/b/mentrely.appspot.com/o/userProfile%2F00F9E2B0-4300-4C66-AF70-772359540257?alt=media&token=19b4f655-748f-4c56-9cdd-3d0cdc0ff9f7" ])
          }
        
          
          let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
              return
          }
          alert.addAction(camera)
          alert.addAction(photoLibrary)
          alert.addAction(savedPhotosAction)
          alert.addAction(deleteButton)
          alert.addAction(cancelButton)
          
          self.present(alert, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) == passwordCell {
            if TMPasscodeLock.isPasscodeSet == true {
                let passcodeLockController = TMPasscodeLockController(style: .basic, state: .enter)
                     passcodeLockController.delegate = self
                passcodeLockController.presentIn(viewController: self, animated: true)
            }else {
                self.performSegue(withIdentifier: "goToReset", sender: self)
            }
        }else if tableView.cellForRow(at: indexPath) == logoutCell  {
            if Auth.auth().currentUser != nil {
                 let alert = UIAlertController(title: "Sign Out?", message: "Your current session will be lost", preferredStyle: .alert)
                 let action = UIAlertAction(title: "Yes", style: .cancel) { (UIAlertAction) in
                     do {
                         try Auth.auth().signOut()
                         self.namaUser = ""
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userChangedWithout"), object: nil)
                         NotificationCenter.default.post(name: NSNotification.Name("signOut"), object: nil)
                     } catch {
                         print(error.localizedDescription)
                     }
                 }
                 let cancel = UIAlertAction(title: "No", style: .destructive) { (UIAlertAction) in
                     return
                 }
                 alert.addAction(cancel)
                 alert.addAction(action)
                 self.present(alert, animated: true, completion: nil)
             } else {
                 self.performSegue(withIdentifier: "goToLogin", sender: self)
              
             }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    private func showLoading(message: String, secondMessage : String) {
     let size = CGSize(width: 40, height: 40)
         startAnimating(size, message: message, type: .ballRotateChase, color: UIColor.white, textColor: UIColor.white)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NVActivityIndicatorPresenter.sharedInstance.setMessage(secondMessage)
        }
   }
    
    //MARK: -Table View Delegate and DataSource
      override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
          return CGFloat.leastNormalMagnitude
      }
    
    //MARK: TextField Delegate Function
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled    = false
        saveButton.tintColor    = nil
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled    = false
        saveButton.tintColor    = .clear
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if nameTextField.text == namaUser! {
            saveButton.isEnabled = false
        }else {
            saveButton.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveUsername()
        return true
    }
    
    //MARK: -UITAPGESTURE RECOGNIZER FOR MAIN VIEW
    @objc func handleTapped() {
        nameTextField.resignFirstResponder()
        nameTextField.text = self.namaUser
    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        if nameTextField.text?.count != 0 {
           showLoading(message: "Hang on", secondMessage: "Almost there..")
                saveUsername()
        }else {
            let alert = UIAlertController(title: "", message: "Username can't be empty", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(dismiss)
            present(alert, animated: true, completion: nil)
        }
    }
    fileprivate func saveUsername() {
        let userUID = Auth.auth().currentUser?.uid
           let ref = Database.database().reference().child("users").child(userUID!)
         
             ref.setValue(["email": Auth.auth().currentUser?.email, "username" : nameTextField.text!, "mental" : self.selectedMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userProfileImage])
                 self.stopAnimating()
                 self.nameTextField.resignFirstResponder()
    }
    

    //MARK: - PROFILE FULLSCREEN
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "goToLogin" {
                   if let nextViewController = segue.destination as? LoginViewController {
                      nextViewController.condition = 1
                  }
              } else if segue.identifier == "goToProfile" {
                   if let nextViewController = segue.destination as? FullscreenViewController {
                    nextViewController.userUID = Auth.auth().currentUser?.uid ?? ""
                    nextViewController.transitioningDelegate = self
                    nextViewController.interactor = interactor
                }
            }
         }
    }

extension AccountTableViewController : TMPasscodeLockControllerDelegate, UIViewControllerTransitioningDelegate {
    
    //MARK: TMP Passcode Delegate
    func passcodeLockController(passcodeLockController: TMPasscodeLockController, didFinishFor state: TMPasscodeLockState) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.performSegue(withIdentifier: "goToReset", sender: self)
        }
    }
    
    func passcodeLockControllerDidCancel(passcodeLockController: TMPasscodeLockController) {
        return
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
          return DismissAnimator()
    }
      
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
          return interactor.hasStarted ? interactor : nil
    }
}
