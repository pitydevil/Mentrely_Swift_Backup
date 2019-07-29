//
//  ViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 21/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import RealmSwift




class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
@IBOutlet weak var scrollView: UINavigationItem!

 @IBOutlet weak var collectionView: UICollectionView!
 @IBOutlet weak var gradientView: UIView!
 @IBOutlet weak var cardView: UIView!
 @IBOutlet weak var diaryCard: UIView!
 @IBOutlet weak var newsletterCard: UIView!
 @IBOutlet weak var logCollectionView: UICollectionView!
 @IBOutlet weak var addButton: UIButton!
  


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource    = self
        collectionView.delegate      = self
        logCollectionView.dataSource = self
        logCollectionView.delegate   = self
        addButton.layer.cornerRadius = 10
        loadItems()
       




     }

    override func viewWillAppear(_ animated: Bool) {

        let layer = CAGradientLayer()
        layer.frame = gradientView.bounds
        layer.colors = [UIColor.purple.cgColor, UIColor.orange.cgColor]
        layer.startPoint = CGPoint(x: 0.8,y: 0)
        layer.endPoint = CGPoint (x: 1,y: 1)

        gradientView.layer.addSublayer(layer)
        cardView.layer.cornerRadius = 10
        cardView.layer.borderWidth = 1.0
        cardView.layer.borderColor = UIColor.orange.cgColor
        cardView.layer.backgroundColor = UIColor.orange.cgColor
        cardView.layer.shadowColor = UIColor.orange.cgColor
        cardView.layer.shadowOffset = CGSize(width: 10, height: 10.0)
        diaryCard.layer.cornerRadius = 10
        newsletterCard.layer.cornerRadius = 10
        self.addButton.layer.shadowOpacity = 1
        self.addButton.layer.shadowRadius = 0.5
        self.addButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        reUpdate()
        reUpdate()
        reUpdate()
        reUpdate()
        reUpdate()
        loadItems()
        fetchButton()



    }


    var tokohArray = ["Dr. Seuss"]
    var quotesArray = [" “Don't cry because it's over, smile because it happened.” "]
    var data = ["sadasd", "sadasd", "asdaa", "aasda"]
    let quoteURL = "https://favqs.com/api/qotd"

    var reminderRealm : Results<reminder>? 

    let realm = try! Realm()

   
    
    


    func reUpdate () {

    if quotesArray.count < 6 {

        for item in quotesArray {
            getQuotes()
        }

           } else {

            print("Penuh")
        }
    }

    func fetchButton() {

        if reminderRealm!.count == 0 {

            addButton.setTitle("Add", for: .normal)

        } else {

            addButton.setTitle("Edit", for: .normal)

        }

    }




//MARK: - GET QUOTE FUNC

    func getQuotes () {

        DispatchQueue.main.async {
            SVProgressHUD.show(withStatus: "Loading")
            }

        Alamofire.request(quoteURL, method: .get ).responseJSON { (response) in

            if response.result.isSuccess {

                SVProgressHUD.dismiss()

               print("success, got the data")

                let quoteJSON : JSON = JSON(response.result.value!)

                self.updateCollection(quote: quoteJSON)

                } else {

                SVProgressHUD.showError(withStatus: "No internet connection")
                
                print("FAILED GETTING THE DATA")

            }
        }
    }

    func updateCollection (quote: JSON) {

        let isiQuote  =  quote["quote"]["body"].stringValue
        quotesArray.append(isiQuote)

        let namaTokoh = quote["quote"]["author"].stringValue
        tokohArray.insert(namaTokoh, at: 0)
        collectionView.reloadData()

    }


//MARK: - FUNCTION FOR COLLECTION VIEW


   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == self.collectionView {

                return tokohArray.count

            } else {

            return reminderRealm?.count ?? 1
            }



    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    if collectionView == self.collectionView {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection", for: indexPath) as! CollectionViewCell

        cell.carouselLabel.lineBreakMode = .byWordWrapping
        cell.carouselLabel.numberOfLines = 1
        cell.carouselLabel.text  = tokohArray[indexPath.item]
        cell.carouselQuotes.text = quotesArray[indexPath.item]
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.shadowColor = UIColor.orange.cgColor
//        cell.layer.backgroundColor = UIColor.purple.cgColor
        cell.layer.cornerRadius = 10
     



        return cell

        } else {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "logCell", for: indexPath) as! LogCollectionViewCell

            if let item = reminderRealm?[indexPath.item] {

                cell.logName.text = item.daily
                cell.layer.cornerRadius = 10

                } else {

                cell.logName.text = "No Reminder is Added"
                cell.layer.cornerRadius = 10

                }




                return cell

                }

            }

        func loadItems() {

        print("loaded")
        reminderRealm = realm.objects(reminder.self)
        collectionView.reloadData()
        logCollectionView.reloadData()

        
        }


    }

