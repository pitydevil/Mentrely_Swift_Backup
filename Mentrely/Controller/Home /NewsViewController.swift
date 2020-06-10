//
//  NewsViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 22/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import SDWebImage
import FirebaseAuth
import MessageUI

class NewsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var zoomButton: UIButton!
    
    //MARK: -DEFINING VARIABLE
    fileprivate let interactor = Interactor()
    var titleNews: String?
    var descriptionNews: String?
    var time: String?
    var author: String?
    var newsProfileURL: String?
    var newsURL: String?
    var website: String?
    var hour: String?
    var imageData: NSData?
    
  
    //Status Bar appearance
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Setting up navigation bar title
        title = "Articles"
    
        //Setting up Title Label
        titleLabel.text = titleNews
        
        //Setting up description Label
        descriptionTextView.text = descriptionNews
        
        //Setting up timeLabel
        timeLabel.text = "Published on: \(hour ?? ""), \(time ?? "")"
        
        //Setting up newsImageView
        newsImageView.sd_setImage(with:URL(string: newsProfileURL ?? ""), placeholderImage:UIImage(named: "loadingImage"))
        newsImageView.clipsToBounds = true
        newsImageView.backgroundColor = UIColor.black
        
        if let newsImage = newsImageView.image?.pngData() as NSData?  {
            imageData = newsImage
        }
        //How to changeWeight, and color to a particular string
        let fullString = "\(website ?? "") | \(author ?? "")"
        let coloredString = "\(website ?? "")"
        let rangeOfColoredString = (fullString as NSString).range(of: coloredString)
        let attributedString = NSMutableAttributedString(string:fullString)
        attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 13)],
                               range: rangeOfColoredString)
        authorLabel.attributedText = attributedString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomButton.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        zoomButton.layer.cornerRadius = 3.5
    }

    @IBAction func zoomPressed(_ sender: Any) {
         self.performSegue(withIdentifier: "goToFullScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWeb" {
            if let nextViewController = segue.destination as? BrowserViewController {
                nextViewController.fullURL = newsURL ?? ""
                nextViewController.titleNews = titleNews ?? ""
            }
        } else if segue.identifier == "goToFullScreen" {
            if let nextViewController = segue.destination as? FullscreenViewController {
                nextViewController.isNews = true
                nextViewController.websitePhoto = imageData
                nextViewController.newsName = titleNews ?? ""
                nextViewController.interactor = interactor
                nextViewController.transitioningDelegate = self
            }
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        let alert =  UIAlertController(title: "Share this news to", message: nil, preferredStyle: .actionSheet)
              let action = UIAlertAction(title: "More", style: .default) { (UIAlertAction) in
                let activityController =  UIActivityViewController(activityItems: [self.newsURL ?? ""], applicationActivities: nil)
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
        alert.addAction(message)
        alert.addAction(action)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func seguePressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToWeb", sender: self)
    }
}

extension NewsViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
      
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
