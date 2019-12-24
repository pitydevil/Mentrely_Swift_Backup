//
//  ReenterViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 11/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseAuth
import UIColor_Hex_Swift

class ReenterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var errorLog: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissButton.layer.cornerRadius = 10
        changeButton.layer.cornerRadius   = 5
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
        newPasswordTextField.setBottomBorder()
        changeButton.backgroundColor = UIColor("#D52192")
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(gesture:)))
        view.addGestureRecognizer(tapped)
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Current Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        newPasswordTextField.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        
//        NotificationCenter.default.addObserver(self,  selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self,  selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self,  selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//
    }
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
//    }
    
    @objc func keyboardWillChange(_ notification : Notification) {
//        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
//        let keyboardHeight = keyboardRect.height
//        if notification.name == UIResponder.keyboardWillShowNotification || notification.name ==  UIResponder.keyboardWillChangeFrameNotification {
//            if #available(iOS 11, *) {
//                view.frame.origin.y = -keyboardHeight/8
//            } else  {
//                view.frame.origin.y = -keyboardHeight/8
//            }
//        } else {
//            if #available(iOS 11.0, *) {
//                view.frame.origin.y = 0
//            } else {
//                view.frame.origin.y = 0
//            }
//        }
    }
    
    @objc func dismissKeyboard(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        view.frame.origin.y = 0
        return true
    }
    
    
    @IBAction func verifyPressed(_ sender: Any) {
   
        let email = EmailAuthProvider.credential(withEmail: emailTextField.text!, password: passwordTextField.text!)
        if emailTextField.text?.count != 0 && passwordTextField.text?.count != 0 && newPasswordTextField.text?.count != 0
        {
            if newPasswordTextField.text! == passwordTextField.text! {
                let alert = UIAlertController(title: "You cannot reuse the same password", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
            
            SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.show(withStatus: "Loading")
            self.emailTextField.isEnabled = false
            self.passwordTextField.isEnabled = false
            self.newPasswordTextField.isEnabled = false
        Auth.auth().currentUser?.reauthenticate(with: email, completion: { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        print("invalid email")
                        self.errorLog.text = "Invalid Email"
                        SVProgressHUD.dismiss()
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                    case .networkError:
                        print("Network error")
                        self.errorLog.text = "No Internet Conection"
                        SVProgressHUD.dismiss()
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                    case .userNotFound:
                        print("no user")
                        self.errorLog.text = "User Not found"
                        SVProgressHUD.dismiss()
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                    case .wrongPassword:
                        print("error password")
                        self.errorLog.text = "Wrong Password"
                        SVProgressHUD.dismiss()
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                        
                    case .emailAlreadyInUse:
                        self.errorLog.text = "Email is already in use"
                        SVProgressHUD.dismiss()
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                    default:
                        print("Create User Error: \(error!)")
                        self.emailTextField.isEnabled = true
                        self.passwordTextField.isEnabled = true
                        SVProgressHUD.dismiss()
                    }
                }
                
            } else {
                
                Auth.auth().currentUser?.updatePassword(to: self.newPasswordTextField.text!, completion: { (error) in
                    if error != nil {
                        print(error!)
                    } else {
                       
                        SVProgressHUD.dismiss()
                        self.dismiss(animated: true) {
                            let presentingController = AboutViewController()
                            presentingController.snackbar.animationType = .slideFromBottomBackToBottom
                            presentingController.snackbar.show()
                        }
                    }
                })
             }
         })
    } else {
          let alert = UIAlertController(title: "Fields can't be empty", message: "", preferredStyle: .alert)
          let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
    }
}
    
    @IBAction func dismissButton(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
    }
    
}

