//
//  ReenterViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 11/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import UIColor_Hex_Swift
import NVActivityIndicatorView

class ReenterViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {
    
    @IBOutlet weak var currentPasswordTextfield: UITextField!
    @IBOutlet weak var passwordCheckerLabel: UILabel!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var errorLog: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeButton.layer.cornerRadius = 3
        
        passwordTextField.setDiaryBottomBorder()
        newPasswordTextField.setDiaryBottomBorder()
        currentPasswordTextfield.setDiaryBottomBorder()
        
        currentPasswordTextfield.tag = 0
        passwordTextField.tag = 1
        newPasswordTextField.tag = 2
        
        currentPasswordTextfield.delegate = self
        passwordTextField.delegate = self
        newPasswordTextField.delegate = self
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(gesture:)))
        view.addGestureRecognizer(tapped)
        
    }
   

    
    @objc func keyboardWillChange(_ notification : Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        let keyboardHeight = keyboardRect.height
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name ==  UIResponder.keyboardWillChangeFrameNotification {
            if #available(iOS 11, *) {
                view.frame.origin.y = -50
            } else  {
                view.frame.origin.y = -50
            }
        } else {
            if #available(iOS 11.0, *) {
                view.frame.origin.y = 0
            } else {
                view.frame.origin.y = 0
            }
        }
    }
    
    @objc func dismissKeyboard(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
          nextField.becomeFirstResponder()
       } else {
          if newPasswordTextField.text?.count != 0 && passwordTextField.text?.count != 0 {
                verifyPressed(self)
            }
       }
       return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newPasswordTextField {
            if textField.text?.count != 0 && passwordTextField.text?.count != 0 {
                  passwordStringComparator()
            }
        } else if textField == passwordTextField {
            if newPasswordTextField.text?.count != 0 && passwordTextField.text?.count != 0{
                passwordStringComparator()
            }
        }else {
            return
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTextField {
            if newPasswordTextField.text?.count != 0{
                passwordCheckerLabel.textColor = UIColor.systemGray
                passwordCheckerLabel.text = "Enter a password"
            }
        }
    }
    
    func passwordStringComparator() {
        if newPasswordTextField.text == passwordTextField.text {
            passwordCheckerLabel.text = "Password match!"
            passwordCheckerLabel.textColor = UIColor.systemGreen
        }else {
            passwordCheckerLabel.text = "Password don't match!"
            passwordCheckerLabel.textColor = UIColor.systemRed
        }
    }
   
    @IBAction func verifyPressed(_ sender: Any) {
        if passwordTextField.text == newPasswordTextField.text && passwordTextField.text?.count != 0 && newPasswordTextField.text?.count != 0 && currentPasswordTextfield.text?.count != 0 {
                let email = EmailAuthProvider.credential(withEmail: (Auth.auth().currentUser?.email)!, password: currentPasswordTextfield.text!)
                self.currentPasswordTextfield.isEnabled = false
                self.passwordTextField.isEnabled = false
                self.newPasswordTextField.isEnabled = false
                self.showLoading(message: "Updating Account", secondMessage: "Finishing..")
            Auth.auth().currentUser?.reauthenticate(with: email, completion: { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .invalidEmail:
                        print("invalid email")
                        self.errorLog.text = "Invalid Email"
                        self.passwordTextField.isEnabled = true
                        self.newPasswordTextField.isEnabled = true
                        self.currentPasswordTextfield.isEnabled = true
                        self.stopAnimating()
                    case .networkError:
                        print("Network error")
                        self.errorLog.text = "No Internet Conection"
                        self.passwordTextField.isEnabled = true
                        self.newPasswordTextField.isEnabled = true
                        self.currentPasswordTextfield.isEnabled = true
                        self.stopAnimating()
                    case .userNotFound:
                        print("no user")
                        self.errorLog.text = "User Not found"
                        self.passwordTextField.isEnabled = true
                        self.newPasswordTextField.isEnabled = true
                        self.currentPasswordTextfield.isEnabled = true
                        self.stopAnimating()
                    case .wrongPassword:
                        print("error password")
                        self.errorLog.text = "Wrong Password"
                        self.passwordTextField.isEnabled = true
                        self.newPasswordTextField.isEnabled = true
                        self.currentPasswordTextfield.isEnabled = true
                        self.stopAnimating()
                    case .emailAlreadyInUse:
                        self.errorLog.text = "Email is already in use"
                        self.passwordTextField.isEnabled = true
                        self.newPasswordTextField.isEnabled = true
                        self.currentPasswordTextfield.isEnabled = true
                        self.stopAnimating()
                    default:
                        print("Create User Error: \(error?.localizedDescription ?? "")")
                        self.passwordTextField.isEnabled = true
                        self.newPasswordTextField.isEnabled = true
                        self.currentPasswordTextfield.isEnabled = true
                        self.stopAnimating()
                    }
                }
                
            } else {
                Auth.auth().currentUser?.updatePassword(to: self.newPasswordTextField.text!, completion: { (error) in
                    if error != nil {
                        print(error!)
                    } else {
                        self.stopAnimating()
                        self.dismiss(animated: true) {
                            let presentingController = AccountTableViewController()
                            presentingController.snackbar.animationType = .slideFromTopBackToTop
                            presentingController.snackbar.show()
                        }
                    }
                })
             }
         })
    } else {
          let alert = UIAlertController(title: "Fields can't be empty", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
    }
}
    
    @IBAction func dismissButton(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
    }
    
    private func showLoading(message: String, secondMessage : String) {
      let size = CGSize(width: 60, height: 60)
        startAnimating(size, message: message, type: .ballRotateChase, color: UIColor.white, textColor: UIColor.white)
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
             NVActivityIndicatorPresenter.sharedInstance.setMessage(secondMessage)
         }
    }
    
}

