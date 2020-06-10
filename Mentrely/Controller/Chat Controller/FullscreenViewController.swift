//
//  FullscreenViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 20/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage


class FullscreenViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    
    var userUID : String?
    var isNews  = false
    var websitePhoto : NSData?
    var newsName   : String?
    var interactor : Interactor? = nil
    var condition  : Int?
    var status : Bool?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        if isNews == false {
            Database.database().reference().child("users").child(userUID ?? "").observe(DataEventType.value) { (snapshot) in
                   if let postDict = snapshot.value as? [String:Any] {
                    let profileImage = postDict["profileImage"] as! String
                    let username = postDict["username"] as! String
                    self.profileImage.sd_setImage(with:URL(string: profileImage ),placeholderImage:UIImage(named: "finalProfile"))
                    self.profileImage.backgroundColor = UIColor.black
                    self.usernameLabel.text = username
                 }
            }
        } else {
            self.usernameLabel.text = newsName ?? ""
            self.profileImage.image = UIImage(data: websitePhoto! as Data)
        }
    }
    
    override func viewDidLoad() {
         super.viewDidLoad()
         scrollview.minimumZoomScale = 1.0
         scrollview.maximumZoomScale = 4.0
     }
    
       @IBAction func handleGesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold : CGFloat = 0.1
        
          // convert y-position to downward pull progress (percentage)
          let translation = sender.translation(in: view)
          let verticalMovement = translation.y / view.bounds.height
          let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
          let downwardMovementPercent = fminf(downwardMovement, 1.0)
          let progress = CGFloat(downwardMovementPercent)
          
          guard let interactor = interactor else { return }
          
          switch sender.state {
          case .began:
              interactor.hasStarted = true
              if self.condition == 0 {
//                if let navController = presentingViewController as? UINavigationController {
//                   let presenter = navController.topViewController as! noteViewController
//
//                }
                 imageData = (self.websitePhoto as Data?)!
                    dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "profileAction"), object: nil)
                }
              }else {
                self.dismiss(animated: true, completion: nil)
            }
          case .changed:
              interactor.shouldFinish = progress > percentThreshold
//              if progress > percentThreshold {
//                self.status = true
//              }else {
//                self.status = false
//              }
              interactor.update(progress)
          case .cancelled:
            
              interactor.hasStarted = false
              interactor.cancel()
          case .ended:
           
              interactor.hasStarted = false
              interactor.shouldFinish
                  ? interactor.finish()
                  : interactor.cancel()
          default:
              break
          }
    }

    override func viewDidDisappear(_ animated: Bool) {
       self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func dismissButton(_ sender: Any) {
         if self.condition == 0 {
//                if let navController = presentingViewController as? UINavigationController {
//                   let presenter = navController.topViewController as! noteViewController
//                    presenter.imageData = (self.websitePhoto as Data?)!
//
//                }
                imageData = (self.websitePhoto as Data?)!
            dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "profileAction"), object: nil)
           }
         }else {
           self.dismiss(animated: true, completion: nil)
       }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.profileImage
    }

}
