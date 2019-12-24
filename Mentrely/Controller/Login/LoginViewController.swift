//
//  LoginViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 07/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
import GoogleSignIn
import TTGSnackbar
import TwitterKit

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate {
 
    @IBOutlet weak var mentrelyLabel: UILabel!
    @IBOutlet weak var errorLog: UILabel!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var dismissedButton: UIButton!
    @IBOutlet weak var loginCard: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var keyImage: UIImageView!
   

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.delegate = self
        emailText.delegate    = self
        passwordText.tag = 1
        emailText.tag = 0
        GIDSignIn.sharedInstance()?.delegate = self
        loginButton.setRoundedButton()
        dismissedButton.layer.cornerRadius = 10
        dismissedButton.layer.shadowRadius = 0.5
        dismissedButton.layer.shadowOpacity = 0.5
        dismissedButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        
        profileImage.roundedCorner()
        profileImage.shadow1Px()
        
        keyImage.roundedCorner()
        keyImage.shadow1Px()
       
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
     
        // TAP GESTURE
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(self.handleTapped))
        tapped.numberOfTouchesRequired = 1
        tapped.addTarget(self,action:#selector(self.handleTapped))
        view.addGestureRecognizer(tapped)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        errorLog.text = ""
        emailText.setSignUp()
        emailText.attributedPlaceholder = NSAttributedString(string: "Email",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordText.setSignUp()
        passwordText.attributedPlaceholder = NSAttributedString(string: "Password",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit {
        //stop events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillChange(_  notification: Notification ) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let keyboardHeight = keyboardRect.height/2
        
        if notification.name == UIResponder.keyboardWillShowNotification  {
            
            if #available(iOS 11.0, *) {
                
                view.frame.origin.y = -keyboardHeight + view.safeAreaInsets.bottom/2
            } else {
                view.frame.origin.y = -keyboardHeight/2
            }
        } else {
            
            if #available(iOS 11.0, *) {
                view.frame.origin.y = 0
            } else {
                view.frame.origin.y = 0
            }
        }
    }
    
    @objc func handleTapped(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Try to find next responder
            if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
               nextField.becomeFirstResponder()
            } else {
               textField.resignFirstResponder()
            }
            // Do not add a line break
            return false
    }

    
    @IBAction func loginPressed(_ sender: AnyObject) {
            emailText.isEnabled = false
            passwordText.isEnabled = false
        
        if let email = emailText.text, let pass = passwordText.text {
            
            if email.count == 0 {
                self.errorLog.text = "Fill The Email Space"
                SVProgressHUD.dismiss()
                emailText.isEnabled = true
                passwordText.isEnabled = true
            }
                
            else if pass.count == 0 {
                self.errorLog.text = "Fill The Email Space"
                SVProgressHUD.dismiss()
                emailText.isEnabled = true
                passwordText.isEnabled = true
            }
            
    if email.count > 0 && pass.count >= 0 {
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.show(withStatus: "Signing in")
        
        Auth.auth().signIn(withEmail:email, password: pass) { (user, error) in
            
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .invalidEmail:
                        print("invalid email")
                        self.errorLog.text = "Invalid Email"
                        self.emailText.isEnabled = true
                        self.passwordText.isEnabled = true
                       
                        SVProgressHUD.dismiss()
                    case .networkError:
                        print("Network error")
                        self.errorLog.text = "No Internet Conection"
                        SVProgressHUD.dismiss()
                        self.emailText.isEnabled = true
                        self.passwordText.isEnabled = true
                    case .userNotFound:
                        print("no user")
                          self.errorLog.text = "User Not found"
                        SVProgressHUD.dismiss()
                        self.emailText.isEnabled = true
                        self.passwordText.isEnabled = true
                    case .wrongPassword:
                        print("error password")
                        self.errorLog.text = "Wrong Password"
                      
                        SVProgressHUD.dismiss()
                        self.emailText.isEnabled = true
                        self.passwordText.isEnabled = true
                    default:
                        print("Create User Error: \(String(describing: error))")
                        self.emailText.isEnabled = true
                        self.passwordText.isEnabled = true
                        SVProgressHUD.dismiss()
                    }
                }
                
                } else {
                    SVProgressHUD.dismiss()
                    self.emailText.isEnabled = true
                    self.passwordText.isEnabled = true
                    print("Sucessful Log In")
                    self.view.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                  let presentingViewController = self.presentingViewController
                
                self.dismiss(animated: true) {
                    presentingViewController?.viewWillAppear(true)
                }
             }
           }
         }
       }
     }
    
   
    @IBAction func dismissButton(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.performSegue(withIdentifier: "goToSignUp", sender: self)
        }
    }
    @IBAction func resetPressed(_ sender: Any) {
        if emailText.text?.count != 0 {
            SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.show(withStatus: "Loading")
            view.endEditing(true)
            Auth.auth().sendPasswordReset(withEmail: emailText.text!) { (error) in
                
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .invalidEmail:
                            self.errorLog.text = "Invalid Email"
                            SVProgressHUD.dismiss()
                        case .networkError:
                            self.errorLog.text = "No Network Connection"
                            SVProgressHUD.dismiss()
                        default:
                            self.errorLog.text = "An error has occured, contact administrator"
                            SVProgressHUD.dismiss()
                            print(error!)
                        }
                    }
                } else {
                    SVProgressHUD.dismiss()
                    let snackBar = TTGSnackbar(message: "We send you an email in regard of your password.", duration: .middle)
                    snackBar.animationType = .slideFromBottomBackToBottom
                    snackBar.shouldDismissOnSwipe = true
                    snackBar.show()
                }
            }
        } else {
            self.errorLog.text = "Fill The Email Field"
        }
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!)
        } else {
            SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.show(withStatus: "Signing")
            guard let idToken = user.authentication.idToken else {return}
            guard let accessToken = user.authentication.accessToken else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                if error != nil {
                    print("error while signing to google \(String(describing: error))")
                    SVProgressHUD.dismiss()
                } else {
                    print("signed in with google on firebase")
                    let userUID = user?.user.uid
                    let ref = Database.database().reference().child("users")
             
                    ref.child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() == true {
                            print("child exist")
                            SVProgressHUD.dismiss()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            print("doesnt exist")
                            SVProgressHUD.dismiss()
                            self.performSegue(withIdentifier: "goToSignUp", sender: self)
                            
                        }
                    })
                }
            }
        }
    }
}
