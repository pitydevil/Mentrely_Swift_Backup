//
//  TokohCollectionViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 25/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

protocol newsTapped {
    func indexReceiver(index: Int)
}

class NewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var newsTypeLabel  : UILabel!
    @IBOutlet weak var dateLabel      : UILabel!
    @IBOutlet weak var tokohLabel     : UITextView!
    @IBOutlet weak var photoTokoh     : UIImageView!
    @IBOutlet weak var collectionCard : UIView!
    
    var indexpath : Int?
    var delegate  : newsTapped?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.shadowRadius = 3
        self.layer.cornerRadius = 5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor   = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        self.collectionCard.layer.cornerRadius = 10
                
        photoTokoh.layer.cornerRadius  = 5
        photoTokoh.layer.masksToBounds = true
        photoTokoh.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        photoTokoh.backgroundColor = UIColor.black
        
        newsTypeLabel.layer.cornerRadius = 2
        newsTypeLabel.layer.masksToBounds = true
    }
    
    @IBAction func newsTapped(_ sender: Any) {
        delegate?.indexReceiver(index: indexpath ?? 0)
        print("kepencet newsnya")
    }
    
    override func prepareForReuse() {
         super.prepareForReuse()
         self.photoTokoh.image = nil
         self.newsTypeLabel.text = nil
         self.tokohLabel.text = nil
         self.dateLabel.text = nil
    }
    
    func setupNewsCell(articleSelection : String, isiNews: String) {
        switch articleSelection {
            case "Motivational":
                self.newsTypeLabel.backgroundColor = UIColor("#FF7130")
                self.newsTypeLabel.text = "Motivational  "
            case "mentalhealth":
                self.newsTypeLabel.backgroundColor = UIColor("#941751")
                self.newsTypeLabel.text = "Mental Health  "
            case "Love":
                self.newsTypeLabel.backgroundColor = UIColor("#FF2600")
                self.newsTypeLabel.text = "Love  "
            case "Psychology":
                self.newsTypeLabel.backgroundColor = UIColor("#C22600")
                self.newsTypeLabel.text = "Psychology  "
            default:
                self.newsTypeLabel.backgroundColor = UIColor("#FF7130")
                self.newsTypeLabel.text = articleSelection
        }
        if Reachability.isConnectedToNetwork() == true && isiNews != "" {
           self.isUserInteractionEnabled = true
           self.newsTypeLabel.isHidden = false
       } else if Reachability.isConnectedToNetwork() == false || isiNews == "" {
           self.isUserInteractionEnabled = false
           self.newsTypeLabel.isHidden = true
       }
    }
}
