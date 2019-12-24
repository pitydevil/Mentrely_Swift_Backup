//
//  CollectionViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 22/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class quoteCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var carouselQuotes: UITextView!
    @IBOutlet weak var carouselLabel: UILabel!
    @IBOutlet weak var collectionCard: UIView!
    
    override func awakeFromNib() {
        collectionCard.layer.cornerRadius = 10
        collectionCard.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        collectionCard.layer.shadowOpacity = 0.5
        collectionCard.layer.shadowRadius  = 2.5
        collectionCard.layer.borderColor = UIColor.white.cgColor
        collectionCard.layer.borderWidth = 0.5
    

    }

}
