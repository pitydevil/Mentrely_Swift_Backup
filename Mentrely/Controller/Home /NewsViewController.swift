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

class NewsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
    var titleNews = ""
    var descriptionNews = ""
    var time = ""
    var author = ""
    var newsProfileURL = ""
    var newsURL  = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setNeedsStatusBarAppearanceUpdate()
        
//      timeLabel.text = time
//      authorLabel.text = author
        
        title = "Article"
        titleLabel.text = titleNews
        
        newsImageView.sd_setImage(with:URL(string: newsProfileURL))
        newsImageView.clipsToBounds = true
        newsImageView.backgroundColor = UIColor.black
        descriptionTextView.text = descriptionNews
        
        timeLabel.isHidden = true
        authorLabel.isHidden = true
     
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWeb" {
            if let nextViewController = segue.destination as? BrowserViewController {
                nextViewController.fullURL = newsURL
            }
        }
    }
    
    @IBAction func seguePressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToWeb", sender: self)
    }
}
