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
import GoogleSignIn
import TTGSnackbar
import NVActivityIndicatorView

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInDelegate, NVActivityIndicatorViewable {
 
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
    
    fileprivate var activeTextField : UITextField?
    var condition : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordText.delegate = self
        emailText.delegate    = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        passwordText.tag = 1
        emailText.tag = 0
        
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
     
        // Tap Gesture
        let tapped = UITapGestureRecognizer(target: self, action: #selector(self.handleTapped))
        tapped.addTarget(self,action:#selector(self.handleTapped))
        view.addGestureRecognizer(tapped)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        errorLog.text = ""
        emailText.setSignUp()
        emailText.txtPaddingVw(txt: emailText)

        passwordText.txtPaddingVw(txt: passwordText)
        passwordText.setSignUp()

        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
    @objc func keyboardWillChange(_  notification: Notification ) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let keyboardHeight = keyboardRect.height/2
        
        if notification.name == UIResponder.keyboardWillShowNotification  {
            
            if #available(iOS 11.0, *) {
                if self.activeTextField != nil {
                    return
                } else {
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.view.frame.origin.y = -keyboardHeight + self.view.safeAreaInsets.bottom/2
                    })
                }
            } else {
                 if self.activeTextField != nil {
                      return
                  } else {
                      UIView.animate(withDuration: 0.5, animations: { () -> Void in
                          self.view.frame.origin.y = -keyboardHeight + self.view.safeAreaInsets.bottom/2
                    })
                }
            }
        }else if notification.name == UIResponder.keyboardWillHideNotification{
            if #available(iOS 11.0, *) {
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.frame.origin.y = 0
                })
            } else {
                  UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.view.frame.origin.y = 0
              })
            }
        }
    }
    
    @objc func handleTapped(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
        self.activeTextField = nil
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
           nextField.becomeFirstResponder()
        } else {
           loginPressed(self)
        }
        return false
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        showLoading(message: "Signing In", secondMessage: "Authenticating")
        if let email = emailText.text, let pass = passwordText.text {
            if email.count == 0  {
                errorLog.text = "Fill The Email Space"
                stopAnimating(nil)
            }else if pass.count == 0 {
                errorLog.text = "Fill The Password Space"
                stopAnimating(nil)
        }
    if email.count != 0 && pass.count != 0 {
        emailText.isEnabled = false
        passwordText.isEnabled = false
        errorLog.text = ""
        emailText.backgroundColor    = .white
        emailText.attributedPlaceholder = NSAttributedString(string: "Email",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        emailText.tintColor = .black
        emailText.textColor = .black
        passwordText.backgroundColor = .white
        passwordText.textColor = .black
        passwordText.tintColor = .black
        passwordText.attributedPlaceholder = NSAttributedString(string: "Password",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        Auth.auth().signIn(withEmail:email, password: pass) { (user, error) in
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                        case .invalidEmail:
                            print("invalid email")
                            self.errorLog.text = "Invalid Email"
                            self.emailText.isEnabled = true
                            self.passwordText.isEnabled = true
                            self.emailText.backgroundColor = UIColor("#FF6E00")
                            self.emailText.tintColor = .white
                            self.emailText.textColor = .white
                            self.emailText.attributedPlaceholder = NSAttributedString(string: "Email",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                            self.stopAnimating(nil)
                        case .networkError:
                            print("Network error")
                            self.errorLog.text = "No Internet Conection"
                            self.stopAnimating(nil)
                            self.emailText.isEnabled = true
                            self.passwordText.isEnabled = true
                        case .userNotFound:
                            print("no user")
                            self.stopAnimating(nil)
                            self.errorLog.text = "User Not found"
                            self.emailText.isEnabled = true
                            self.passwordText.isEnabled = true
                            self.passwordText.backgroundColor = UIColor("#FF6E00")
                            self.emailText.backgroundColor    = UIColor("#FF6E00")
                            self.passwordText.tintColor = .white
                            self.passwordText.textColor = .white
                            self.passwordText.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                            self.emailText.tintColor    = .white
                            self.emailText.textColor    = .white
                            self.emailText.attributedPlaceholder = NSAttributedString(string:   "Email",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                        case .wrongPassword:
                            print("error password")
                            self.errorLog.text = "Wrong Password"
                            self.stopAnimating(nil)
                            self.emailText.isEnabled = true
                            self.passwordText.backgroundColor = UIColor("#FF6E00")
                            self.passwordText.tintColor = .white
                            self.passwordText.isEnabled = true
                            self.passwordText.textColor = .white
                            self.passwordText.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                        default:
                            print("Create User Error: \(String(describing: error))")
                            self.emailText.isEnabled = true
                            self.passwordText.isEnabled = true
                            self.stopAnimating(nil)
                        }
                    }
                } else {
                    self.stopAnimating(nil)
                    self.emailText.isEnabled = true
                    self.passwordText.isEnabled = true
                    print("Sucessful Log In")
                    NotificationCenter.default.post(name: NSNotification.Name("signOut"), object: nil)
                    self.view.endEditing(true)
                     self.dismiss(animated: true) {
                    if self.condition! == 0 {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userChanged"), object: nil)
                    }else if self.condition == 1{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userChangedWithout"), object: nil)
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSignUp" {
            if let nextViewController = segue.destination as? SignupViewController {
                nextViewController.condition = self.condition!
            }
        }
    }
    
    @IBAction func dismissButton(_ sender: Any) {
      self.view.endEditing(true)
      self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
            self.performSegue(withIdentifier: "goToSignUp", sender: self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
         self.activeTextField = textField
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        if emailText.text?.count != 0 {
            emailText.backgroundColor    = .white
            emailText.attributedPlaceholder = NSAttributedString(string: "Email",attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            emailText.tintColor = .black
            emailText.textColor = .black
            showLoading(message: "Loading", secondMessage: "Hang In There")
            view.endEditing(true)
            Auth.auth().sendPasswordReset(withEmail: emailText.text!) { (error) in
                if error != nil {
                    if let errorCode = AuthErrorCode(rawValue: error!._code) {
                        switch errorCode {
                        case .invalidEmail:
                            self.errorLog.text = "Invalid Email"
                            self.emailText.isEnabled = true
                            self.passwordText.isEnabled = true
                            self.emailText.backgroundColor = UIColor("#FF6E00")
                            self.emailText.tintColor = .white
                            self.emailText.textColor = .white
                            self.emailText.attributedPlaceholder = NSAttributedString(string: "Email",attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                            self.stopAnimating(nil)
                        case .networkError:
                            self.errorLog.text = "No Network Connection"
                            self.stopAnimating(nil)
                        default:
                            self.errorLog.text = "An error has occured, contact administrator"
                            self.stopAnimating(nil)
                            print(error!)
                        }
                    }
                } else {
                    self.stopAnimating(nil)
                    let snackBar = TTGSnackbar(message: "We send you an email in regards of your password.", duration: .middle)
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
        if #available(iOS 13.0, *) {
            GIDSignIn.sharedInstance()?.presentingViewController.modalPresentationStyle = .fullScreen
            GIDSignIn.sharedInstance()?.presentingViewController.isModalInPresentation = true
            GIDSignIn.sharedInstance()?.presentingViewController.modalTransitionStyle = .crossDissolve
       }
        GIDSignIn.sharedInstance().signIn()
    }
    
    private func showLoading(message: String, secondMessage : String) {
        let size = CGSize(width: 60, height: 60)
        startAnimating(size, message: message, type: .ballRotateChase, color: UIColor.white, textColor: UIColor.white)
           DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
               NVActivityIndicatorPresenter.sharedInstance.setMessage(secondMessage)
           }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print(error!)
        } else {
            showLoading(message: "Signing In", secondMessage: "Authenticating")
            guard let idToken = user.authentication.idToken else {return}
            guard let accessToken = user.authentication.accessToken else {return}
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                if error != nil {
                    print("error while signing to google \(String(describing: error))")
                    self.stopAnimating(nil)
                } else {
                    
                    print("signed in with google on firebase")
                    let userUID = user?.user.uid
                    let ref = Database.database().reference().child("users")
                    ref.child(userUID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        if snapshot.exists() == true {
                            print("child exist")
                            self.stopAnimating(nil)
                            self.dismiss(animated: true, completion: nil)
                            NotificationCenter.default.post(name: NSNotification.Name("signOut"), object: nil)
                            if self.condition! == 0 {
                                   NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userChanged"), object: nil)
                             } else if self.condition == 1{
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userChangedWithout"), object: nil)
                             } else {
                                   NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
                            }
                        } else {
                            print("doesnt exist")
                            self.stopAnimating(nil)
                            self.performSegue(withIdentifier: "goToSignUp", sender: self)
                            
                        }
                    })
                }
            }
        }
    }
}
