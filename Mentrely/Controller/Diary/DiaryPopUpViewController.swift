//
//  DiaryPopUpViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/01/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import UIKit

class DiaryPopUpViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var dateDiary: UILabel!
    @IBOutlet weak var diaryTitle: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var diaryCard: UIView!
    @IBOutlet weak var dateModifiedLabel: UILabel!
    @IBOutlet weak var diaryPhoto: UIImageView!
    
    fileprivate let interactor = Interactor()
    var judulDiary : String?
    var tanggalDiary : Date?
    var lastModified : Date?
    var diaryPhotoData : Data?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.isBeingPresented)
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM YYYY"
        let dateString = dateFormatter.string(from: tanggalDiary ?? Date())
        let modifiedDateFormatter = DateFormatter()
        modifiedDateFormatter.dateFormat = "HH:mm, dd MMM YYYY"
        let modifiedDate = modifiedDateFormatter.string(from: lastModified ?? Date())
        
        if diaryPhotoData != Data() {
            diaryPhoto.image = UIImage(data: diaryPhotoData!)
            diaryPhoto.roundedCorner()
            diaryPhoto.layer.borderColor = UIColor("#F3F3F3").cgColor
            diaryPhoto.layer.borderWidth = 3
            diaryPhoto.backgroundColor   = UIColor.black
            diaryPhoto.isUserInteractionEnabled = true
            let tapped = UITapGestureRecognizer(target: self, action: #selector(photoTapped(gesture:)))
            diaryPhoto.addGestureRecognizer(tapped)
        }
        
        diaryCard.layer.masksToBounds = true
        diaryCard.corner10()
        
        diaryTitle.text = judulDiary ?? ""
        
        dateDiary.text = "Created On: \(dateString)"
        
        dateModifiedLabel.text = "Last Modified On: \(modifiedDate)"
    
        let tapped = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        tapped.delegate = self
        view.addGestureRecognizer(tapped)
    }
    
    @objc func photoTapped(gesture: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "goToFullScreen", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullScreen" {
            if let nextViewController = segue.destination as? FullscreenViewController {
                nextViewController.isNews = true
                nextViewController.newsName = diaryTitle.text
                nextViewController.websitePhoto = imageData as NSData?
                nextViewController.interactor = interactor
                nextViewController.transitioningDelegate = self
                nextViewController.condition = 1
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
           if touch.view != self.view
           {
               return false
           }
           return true
       }

  
    @objc func handleTapped(gesture: UITapGestureRecognizer) {
//       if let navController = presentingViewController as? UINavigationController {
//         let presenter = navController.topViewController as! noteViewController
//            print("diary pop")

//         
//      }
        imageData = (self.diaryPhotoData as Data?)!
        self.dismiss(animated: true, completion: nil)
    }
}

extension DiaryPopUpViewController :  UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
          return DismissAnimator()
    }
      
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
          return interactor.hasStarted ? interactor : nil
    }
}



