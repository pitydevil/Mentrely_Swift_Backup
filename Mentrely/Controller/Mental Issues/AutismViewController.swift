//
//  AutismViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 30/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class AutismViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {


    @IBOutlet weak var autismCollectionView: UICollectionView!
    @IBOutlet weak var autismCardView: UIView!
    @IBOutlet weak var consult: UIButton!
    private var imageArray : [UIImage] = [UIImage(named: "chat.png")!, UIImage(named: "delete.png")!]

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var penjelasanText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

      autismCollectionView.dataSource = self
      autismCollectionView.delegate   = self

      consult.layer.cornerRadius = 5
      consult.layer.borderWidth  = 1.0
      consult.layer.borderColor  = UIColor.purple.cgColor
      self.consult.layer.shadowOpacity = 0.8
      self.consult.layer.shadowRadius = 0.2
      self.consult.layer.shadowOffset = CGSize(width: 2, height: 2)
    penjelasanText.layer.cornerRadius = 10
    penjelasanText.layer.borderWidth = 0.8
    penjelasanText.layer.borderColor = UIColor.brown.cgColor
    titleView.layer.cornerRadius = 10
    titleView.layer.borderWidth  = 1.0
    titleView.backgroundColor = UIColor.orange



    }

       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return imageArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AutismCell", for: indexPath) as! AutismCollectionViewCell

        cell.layer.borderWidth = 1.0
        cell.layer.cornerRadius = 10
        cell.famousImage.image = imageArray[indexPath.item]
        cell.labelTokoh.text   = "nama Tokoh"
        

        return cell

    }

    @IBAction func consultButton(_ sender: UIButton) {

        performSegue(withIdentifier: "goToHospital", sender: self)

    }

}
