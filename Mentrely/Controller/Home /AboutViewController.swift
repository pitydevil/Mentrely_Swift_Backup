//
//  AboutViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 11/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SVProgressHUD
import TTGSnackbar
import SDWebImage

class AboutViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var arrowButton: UIImageView!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var notificationSlider: UISwitch!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var mentalText: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var imageArrow: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    
    let snackbar = TTGSnackbar(message: "Your password is changed", duration: .short)
    let appVersion = "CFBundleShortVersionString"
    let defaults = UserDefaults.standard
    let mentalPicker = UIPickerView()
    let imageView = UIImagePickerController()
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
   
    let shareWithMail = "Get this awesome app, by contacting Mikhael_adiputra@yahoo.com"
    var mental = ["Autism", "Hyperactivity Disorder", "Post Traumatic Disease", "Bipolar Disorder", "Obsessive Compulsive Disorder", "Scizophrenia", "Depression"]
    var selectedMental : String = ""
    var selectedImage : UIImage?
    var namaUser = ""
    var userMental = ""
    var hyperUser = ""
    var selectedBipolar = ""
    var selectedDepression = ""
    var selectedOCD  = ""
    var selectedAnxiety = ""
    var selectedPTSD    = ""
    var userImage   = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        emailLabel.isHidden = true
        arrowImage.isHidden = false
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        activityIndicator.color = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initialView()
         self.view.layoutIfNeeded()
    }
    
    private func initialView() {
        // Version Label
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary[appVersion] as! String
        versionLabel.text = version
        profilePhoto.image = UIImage(named: "finalProfile")
        profilePhoto.contentMode = .scaleAspectFill
    
        // notification Toggler
        let hasilCheck = defaults.bool(forKey: "checkNotif")
        if hasilCheck == true {
            notificationSlider.setOn(true, animated: false)
        } else {
            notificationSlider.setOn(false, animated: false)
        }
        
        // Check User is exist or not
        if Auth.auth().currentUser != nil {
            self.activityIndicator.startAnimating()
            let userUID = Auth.auth().currentUser?.uid
            let ref     = Database.database().reference()
            let userReference = ref.child("users")
            _ = userReference.child(userUID!).observe(DataEventType.value) { (snapshot) in
                if let snapshotValue = snapshot.value as? [String:String] {
                    let username = snapshotValue["username"]
                    let mental   = snapshotValue["mental"]
                    let bipolarRoom = snapshotValue["BipolarRoom"]
                    let depressionRoom = snapshotValue["DepressionRoom"]
                    let hyper    = snapshotValue["HyperRoom"]
                    let anxietyRoom = snapshotValue["AnxietyRoom"]
                    let ocdRoom = snapshotValue["OCDRoom"]
                    let ptsdRoom = snapshotValue["PTSDRoom"]
                    let profileImage = snapshotValue["profileImage"]
                    self.defaults.set(username!, forKey: "userName")
                    self.userImage   = profileImage ?? ""
                    self.profilePhoto.sd_setImage(with:URL(string: profileImage ?? ""), placeholderImage:UIImage(named: "finalProfile"))
                    self.profilePhoto.backgroundColor   = UIColor.white
                    self.activityIndicator.stopAnimating()
                    self.namaUser   = username ?? (Auth.auth().currentUser?.email)!
                    self.mentalText.text = mental ?? ""
                    self.selectedMental  = mental ?? ""
                    self.hyperUser       = hyper ?? "0"
                    self.selectedBipolar = bipolarRoom ?? "0"
                    self.selectedDepression = depressionRoom ?? "0"
                    self.selectedAnxiety = anxietyRoom ?? "0"
                    self.selectedOCD     = ocdRoom ?? "0"
                    self.selectedPTSD    = ptsdRoom ?? "0"
                    self.mentalText.text = self.selectedMental
                    self.nameLabel.text =  self.namaUser
                    } else {
                        self.nameLabel.text = Auth.auth().currentUser?.email
                    }
                }
          
       
                emailLabel.text      = Auth.auth().currentUser?.email ?? "Guest User"
                editButton.isEnabled = true
                logOutButton.isEnabled = true
                logOutButton.tintColor = UIColor.red
                logOutButton.setTitle("Log out", for: .normal)
                inputPicker()
                createToolbar()
                mentalText.isEnabled = true
                editButton.tintColor = UIColor.systemBlue
               
                imageArrow.isHidden    = false
                resetButton.isEnabled = true
                resetButton.tintColor = UIColor.black
            
            
                let profileRecognizer = UITapGestureRecognizer(target: self, action: #selector(segueProfile))
                profilePhoto.addGestureRecognizer(profileRecognizer)
                profilePhoto.isUserInteractionEnabled = true
                profilePhoto.roundedCorner()
            
                let handleTapped = UITapGestureRecognizer(target: self, action: #selector(handlePicker))
                view.addGestureRecognizer(handleTapped)
            
        }else {
            self.profilePhoto.backgroundColor   = UIColor.white
            emailLabel.isHidden = true
            arrowImage.isHidden = true
            emailLabel.text      = ""
            nameLabel.text = "Sign In"
            editButton.isEnabled = false
            editButton.tintColor = UIColor.gray
            logOutButton.isEnabled = true
            logOutButton.setTitle("Login", for: .normal)
            logOutButton.tintColor = UIColor.blue
            mentalText.isEnabled = false
            mentalText.text      = ""
            imageArrow.isHidden  = true
            resetButton.isEnabled = true
            resetButton.tintColor = UIColor.lightGray
        }
    }
    
   
    private func inputPicker () {
        mentalPicker.delegate = self
        mentalText.inputView = mentalPicker
        mentalPicker.backgroundColor = UIColor.white
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
        mentalText.text = mental[row]
        selectedMental  = mental[row]
    }
    
    func createToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = UIColor.white
        
        toolbar.setItems([doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.barTintColor = UIColor("#D52192")
        mentalText.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
  
        if Auth.auth().currentUser != nil {
            let userUID = Auth.auth().currentUser?.uid
            let ref     = Database.database().reference()
            let userReference = ref.child("users")
            let newUserReference = userReference.child(userUID!)
       
            newUserReference.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.selectedMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": self.userImage])
        }
    }
    
    @objc func handlePicker(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        viewWillAppear(true)
         self.view.layoutIfNeeded()
    }
    
    
    //MARK: -PROFILE FULLSCREEN
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToProfile" {
                       if let nextViewController = segue.destination as? FullscreenViewController {
                           nextViewController.userUID = Auth.auth().currentUser?.uid ?? ""
                       }
               }
    }
    
    @objc func segueProfile(gesture: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    //MARK: -IMAGE PICKER CONTROLLER ATAU CAMERA
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        if let imagePicked = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
          
            self.dismiss(animated: true, completion: nil)
            self.profilePhoto.image = imagePicked
            SVProgressHUD.show(withStatus: "Loading")
            SVProgressHUD.setMinimumSize(CGSize(width: 50, height: 50))
            DispatchQueue.global(qos: .background).async {
               let imageName = UUID().uuidString
               let imageRef = Storage.storage().reference().child("userProfile").child(imageName)
                   var data = Data()
                   data = imagePicked.jpegData(compressionQuality: 0.2)!
                   imageRef.putData(data, metadata: nil){ (metadata, error) in
                       if error != nil {
                           print(error!)
                       } else {
                           imageRef.downloadURL { (url, error) in
                               guard let downloadURL = url else { return }
                               let userUID = Auth.auth().currentUser?.uid
                               let ref     = Database.database().reference()
                               let userReference = ref.child("users")
                               let newUserReference = userReference.child(userUID!)
                         
                               newUserReference.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.selectedMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": downloadURL.absoluteString])
                           }
                       }
                   }

                 DispatchQueue.main.async {
                      // UI updates must be on main thread
                    self.profilePhoto.image = imagePicked
                    SVProgressHUD.dismiss()
                    }
                }
            }
        }
    
    @IBAction func logOutButton(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let alert = UIAlertController(title: "Are you sure want to log out?", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
                do {
                    try Auth.auth().signOut()
                    if  self.defaults.string(forKey: "userName") != nil {
                        self.mentalText.text = ""
                    }
                    self.viewWillAppear(true)
                   self.view.layoutIfNeeded()
                } catch {
                    print(error)
                }
            }
            let cancel = UIAlertAction(title: "No", style: .destructive) { (UIAlertAction) in
                print("canceled")
                return
            }
            alert.addAction(action)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.performSegue(withIdentifier: "goToLogin", sender: self)
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        
        imageView.delegate = self
        imageView.allowsEditing = true
        
        let alert = UIAlertController(title: "Add an image", message: "Choose From", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Take a Photo", style: .default) { (UIAlertAction) in
            self.imageView.sourceType = .camera
            self.present(self.imageView, animated: true, completion: nil)
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            self.imageView.sourceType = .photoLibrary
            self.present(self.imageView, animated: true, completion: nil)
        }
        
        let deleteButton = UIAlertAction(title: "Delete Profile Photo", style: .destructive) { (UIAlertAction) in
            self.profilePhoto.image = UIImage(named: "finalProfile")
               let userUID = Auth.auth().currentUser?.uid
               let ref     = Database.database().reference()
               let userReference = ref.child("users")
               let newUserReference = userReference.child(userUID!)
         
               newUserReference.setValue(["email": Auth.auth().currentUser?.email, "username" : self.namaUser, "mental" : self.selectedMental, "DepressionRoom": self.selectedDepression, "HyperRoom": self.hyperUser,"BipolarRoom": self.selectedBipolar,"AnxietyRoom": self.selectedAnxiety, "OCDRoom": self.selectedOCD, "PTSDRoom": self.selectedPTSD,  "profileImage": "https://firebasestorage.googleapis.com/v0/b/mentrely.appspot.com/o/userProfile%2F00F9E2B0-4300-4C66-AF70-772359540257?alt=media&token=19b4f655-748f-4c56-9cdd-3d0cdc0ff9f7" ])
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            return
        }
        
        alert.addAction(camera)
        alert.addAction(photoLibrary)
        alert.addAction(deleteButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func notificationSettings(_ sender: AnyObject) {
        let data = defaults.bool(forKey: "checkNotif")
        if data == false {
            
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
                    self.viewWillAppear(true)
                }
                let no = UIAlertAction(title: "No", style: .destructive) { (UIAlertAction) in
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
                    self.viewWillAppear(true)
                }
                let no  = UIAlertAction(title: "No", style: .destructive) { (UIAlertAction) in
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
    
    @IBAction func tellAFriendButton(_ sender: Any) {
        let alert =  UIAlertController(title: "Share This App to", message: "", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Another Apps", style: .default) { (UIAlertAction) in
            
            let activityController =  UIActivityViewController(activityItems: [self.shareWithMail], applicationActivities: nil)
            
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
            let appURL = URL(string: "mailto:")!
            UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
        }
        let cancel  = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            return
        }
        alert.addAction(action)
        alert.addAction(message)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func checkEmailPressed(_ sender: Any) {
        if arrowImage.isHidden == false && emailLabel.isHidden == true {
            arrowImage.isHidden = true
            emailLabel.isHidden = false
            self.loadViewIfNeeded()
        } else {
            arrowImage.isHidden = false
            emailLabel.isHidden = true
            self.loadViewIfNeeded()
        }
    }
    
    @IBAction func resetPasswordPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToReset", sender: self)
    }
}
