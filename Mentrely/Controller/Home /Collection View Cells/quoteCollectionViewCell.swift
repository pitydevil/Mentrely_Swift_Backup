//
//  CollectionViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 22/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

protocol quotesFunc: AnyObject {
    func quotesIndex(cell : quoteCollectionViewCell)
}

class quoteCollectionViewCell: UICollectionViewCell {
    
  
    @IBOutlet weak var carouselQuotes: UITextView!
    @IBOutlet weak var carouselLabel: UILabel!
    @IBOutlet weak var collectionCard: UIView!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var quotesImage: UIImageView!
    
    let italicFont = UIFont.italicSystemFont(ofSize: 11)
    var delegate: quotesFunc?
    private let imageArray : [UIImage] = [UIImage(named: "Profile 1")!, UIImage(named: "Profile 2")!, UIImage(named: "Profile 3")!
        , UIImage(named: "Profile 4")!, UIImage(named: "Profile 5")!, UIImage(named: "Profile 6")!]
    override func awakeFromNib() {
      
        carouselLabel.lineBreakMode = .byWordWrapping
        carouselLabel.numberOfLines = 1
        carouselLabel.font = italicFont
  
        let tapped = UITapGestureRecognizer(target: self, action: #selector(infoTapped))
        infoImage.isUserInteractionEnabled = true
        infoImage.addGestureRecognizer(tapped)
    }
    
    
    
    @objc func infoTapped() {
        delegate?.quotesIndex(cell: self)
    }
    
    func configureQuotesCell(quotes: Quotes)  {
        let randomIndex = Int.random(in: 0...5)
        self.carouselLabel.text  = quotes.quotesTokoh
        self.carouselQuotes.text = quotes.quotes
        self.quotesImage.image = imageArray[randomIndex]
        if quotes.isQuote == true {
          self.infoImage.image = UIImage(named:"pin")
          self.infoImage.alpha = 0.8
        }else {
          self.infoImage.image = UIImage(named:"pin")
          self.infoImage.alpha = 0.4
        }
    }
}
