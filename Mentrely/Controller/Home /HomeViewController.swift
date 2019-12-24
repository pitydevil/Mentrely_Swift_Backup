//
//  HomeViewController.swift
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
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import UIColor_Hex_Swift
import TTGSnackbar

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, newsTapped {

 @IBOutlet weak var tokohCollectionView: UICollectionView!
 @IBOutlet weak var quotesCollectionView: UICollectionView!
 @IBOutlet weak var diaryCard: UIView!
 @IBOutlet weak var hospitalCard: UIView!
 @IBOutlet weak var reminderCard: UIView!
 @IBOutlet weak var reminderCollectionView: UICollectionView!
 @IBOutlet weak var addButton: UIButton!
 @IBOutlet weak var hospitalButton: UIButton!
 @IBOutlet weak var writeButton: UIButton!
 @IBOutlet weak var greetingLabel: UILabel!
 @IBOutlet weak var userLabel: UILabel!
 @IBOutlet weak var mentalLabel: UILabel!
 @IBOutlet weak var profileImage: UIImageView!
 @IBOutlet weak var pageControl: UIPageControl!
 @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK : DEFINING LET AND VARIABLE
    let quoteAPIURL = "https://favqs.com/api/qotd"
    let newsURL = "https://newsapi.org/v2/everything?q=motivational&apiKey=6a101f1ef174428da463c06bf669ea69"
    let realm = try! Realm()
    let date = Date()
    let calendar = Calendar.current
    let defaults = UserDefaults.standard
    var tokohArray = ["Dr. Seuss"]
    var quotesArray = [" Don't cry because it's over, smile because it happened. "]
    var tokohTerkenalArray = [String]()
    var urlPhotos = [String]()
    var descriptionArray = [String]()
    var timeArray = [String]()
    var authorArray = [String]()
    var urlArray = [String]()
    var reminderRealm : Results<reminder>?
    var failed = false
    var newsIndexpath = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hour  =  calendar.component(.hour, from: date)
            setupTime(time: hour)
      
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            reminderCollectionView.delegate = self
            reminderCollectionView.dataSource = self
            quotesCollectionView.delegate    = self
            quotesCollectionView.dataSource  = self
            tokohCollectionView.delegate  = self
            tokohCollectionView.dataSource = self
            initialSetup()
            checkArray()
     }

    override func viewWillAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            initialSetup()
            if Auth.auth().currentUser != nil {
                let userUID = Auth.auth().currentUser?.uid
                      let ref     = Database.database().reference()
                      let userReference = ref.child("users")
                    _ = userReference.child(userUID!).observe(DataEventType.value) { (snapshot) in
                          if let snapshotValue = snapshot.value as? [String:String] {
                            let profileImage = snapshotValue["profileImage"]
                            self.profileImage.sd_setImage(with:URL(string: profileImage ?? ""), placeholderImage:UIImage(named: "finalProfile"))
                            self.profileImage.backgroundColor = UIColor.black
                            self.profileImage.contentMode = .scaleToFill
                            self.profileImage.layer.borderColor = UIColor.lightGray.cgColor
                            self.profileImage.layer.borderWidth = 0.4
                    }
                }
            }
        } else {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
 
    //MARK: Initializing MENU
    private func initialSetup() {
       
        // gradient layer
        let layer = CAGradientLayer()
        layer.frame = view.bounds
        layer.colors = [ UIColor("#B02193").cgColor,UIColor("#FF7E79").cgColor]
        layer.startPoint = CGPoint(x: 0.0,y: 0)
        layer.endPoint = CGPoint (x: 0.8,y: 1)
        view.layer.insertSublayer(layer, at: 0)

        // set user email etc
        if let email = Auth.auth().currentUser?.email {
            userLabel.text = email
        } else {
            userLabel.text = "Login"
        }
        
        if Auth.auth().currentUser != nil {
         
            let userUID = Auth.auth().currentUser?.uid
            let ref     = Database.database().reference()
            let userReference = ref.child("users")
                _ = userReference.child(userUID!).observe(DataEventType.value) { (snapshot) in
                if  let postDict = snapshot.value as? [String:String] {
                    
                    if let mentalIssues = postDict["mental"], postDict.count != 0 {
                        self.mentalLabel.text = mentalIssues
                    } else {
                        self.mentalLabel.text = ""
                    }
                    
                    if let username  = postDict["username"], username.count != 0 {
                         self.userLabel.text = username
                    } else {
                        self.userLabel.text = Auth.auth().currentUser?.email ?? "Guest User"
                        }
                      } else {
                        self.userLabel.text = Auth.auth().currentUser?.email
                  }
               }
            } else {
                userLabel.text = "Login"
                mentalLabel.text = ""
            }
         
            // button-button
            writeButton.setShadowDiary()
            
            //Hospital Button
            hospitalButton.setShadow()
            
            //add Button for daily reminder
            addButton.setShadow()
            addButton.layer.shadowOffset = CGSize(width: 1, height: 1)
            addButton.titleLabel?.textAlignment = .center
            addButton.titleLabel?.numberOfLines = 0
        
            //diaryCard
            diaryCard.setLayer()
            
            //hospitalCard
            hospitalCard.setLayer()
            
            //reminderCard
            reminderCard.setLayer()
        
            //profile image
            profileImage.roundedCorner()
            
            loadItems()
            fetchButton()
           
    }
    
    private func checkArray() {
        
        if quotesArray.count <= 3, failed == false {
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.setDefaultAnimationType(.native)
            SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
            SVProgressHUD.show(withStatus: "Loading")
            getQuotes()
            getQuotes()
            getQuotes()
            getQuotes()
            fetchNews()
            
            } else {
              return
        }
    }
    
    private func setupTime (time: Int) {
        switch time {
        case 5...12:
            greetingLabel.text = "Good Morning,"
        case 12...18:
            greetingLabel.text = "Good Afternoon,"
        case 18...24:
            greetingLabel.text = "Good Evening,"
        default:
            greetingLabel.text = "Good Evening,"
        }
    }
    
    private func fetchButton() {
        if reminderRealm!.count == 0 {
            addButton.setTitle("Add", for: .normal)
        } else {
            addButton.setTitle("Edit", for: .normal)
        }
    }

    
//MARK: - FUNCTION FOR COLLECTION VIEW

   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == self.quotesCollectionView {
            
                return tokohArray.count
            } else if collectionView == reminderCollectionView {
            if reminderRealm!.count < 3 {
                    return reminderRealm?.count ?? 1
                } else  {
                return 3
            }
        } else {
            if tokohTerkenalArray.count >= 4 {
                return 6
                } else {
                    return tokohTerkenalArray.count
            }
        }
    }
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == self.quotesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection", for: indexPath) as! quoteCollectionViewCell
                cell.carouselLabel.text  = tokohArray[indexPath.item]
                cell.carouselQuotes.text = quotesArray[indexPath.item]
                cell.carouselLabel.lineBreakMode = .byWordWrapping
                cell.carouselLabel.numberOfLines = 1
                cell.layer.cornerRadius = 10
            return cell
            
        }  else if collectionView == reminderCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "logCell", for: indexPath) as! LogCollectionViewCell
                    if let reminder = reminderRealm?[indexPath.item] {
                        cell.logName.text = reminder.daily
                        cell.layer.cornerRadius = 10
                        cell.logName.layer.masksToBounds = true
                        cell.logName.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                        cell.logName.layer.cornerRadius  = 10
                    } else {
                        cell.logName.text = "No Reminder is Added"
                        cell.layer.cornerRadius = 10
                    }
                    return cell
                } else {
                       
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tokohCollection", for: indexPath) as! TokohCollectionViewCell
            
                        cell.photoTokoh.layer.cornerRadius  = 5
                        cell.photoTokoh.layer.masksToBounds = true
                        cell.photoTokoh.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                        if indexPath.row == 5 {
                            cell.isHidden = true
                        } else if indexPath.row ==  6{
                            cell.isHidden = true
                        } else {
                            cell.delegate = self
                            cell.isHidden = false
                            cell.indexpath = indexPath.row
                            cell.tokohLabel.text = tokohTerkenalArray[indexPath.item]
                            cell.photoTokoh.sd_setImage(with:URL(string: self.urlPhotos[indexPath.item]))
                            cell.photoTokoh.backgroundColor = UIColor.black
                            cell.dateLabel.text = timeArray[indexPath.item]
                        }
                    return cell
              }
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          if collectionView == tokohCollectionView {
                if indexPath.row % 2 == 0 {
                     return CGSize(width: 175, height: 225)
                } else {
                    return CGSize(width: 175, height: 250)
                }
            } else if collectionView == quotesCollectionView {
                return  CGSize(width: 263, height: 160)
            } else {
            return CGSize(width: 359, height: 78)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        var indexes = self.quotesCollectionView.indexPathsForVisibleItems
        indexes.sort()
        var index = indexes.first!
        let cell = self.quotesCollectionView.cellForItem(at: index)!
        let position = self.quotesCollectionView.contentOffset.x + 30 - cell.frame.origin.x
        if position > cell.frame.size.width/2{
            index.row = index.row+1
        }
        self.self.quotesCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
    }
    
    
    //MARK: - GET QUOTE FUNCTION
    private func getQuotes () {
    
        Alamofire.request(quoteAPIURL, method: .get ).responseJSON { (response) in
            if response.result.isSuccess {
            
                let quoteJSON : JSON = JSON(response.result.value!)
                self.updateCollection(quote: quoteJSON)
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                if self.tokohArray.count >= 1 {
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
                } else {
                    return
                }
                
            } else {
                let snackbar = TTGSnackbar(message: "No Internet Connection", duration: .middle)
                snackbar.animationType = .slideFromTopBackToTop
                snackbar.show()
                
                print("FAILED GETTING THE DATA")
                
                self.failed = true
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            }
        }
    }
    
    //MARK: FETCHING INSPIRATIONAL PEOPLE
    private func fetchNews () {
        Alamofire.request(newsURL, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let newsJson : JSON = JSON(response.result.value!)
                self.updateNews(news: newsJson)
                SVProgressHUD.dismiss()
                print("data is fetched")
            } else {
                SVProgressHUD.dismiss()
                print("print ga dapet data news")
            }
        }
    }
    
    //MARK: - PARSING JSON DATA
    
    private func updateNews(news: JSON) {
        let batasBawah = Int.random(in: 0..<6)
        let batasAtas = Int.random(in: batasBawah+6..<batasBawah+12)
          
        for index in stride(from: batasBawah, to: batasAtas, by: 1){
            let title = news["articles"].arrayValue[index]["title"].stringValue
            let profileImage = news["articles"].arrayValue[index]["urlToImage"].stringValue
            let Author = news["articles"].arrayValue[index]["author"].stringValue
            let date = news["articles"].arrayValue[index]["publishedAt"].stringValue
            let description = news["articles"].arrayValue[index]["content"].stringValue
            let FullURL = news["articles"].arrayValue[index]["url"].stringValue

            var formattedDate = date
            formattedDate = String(formattedDate.prefix(10))
           
            self.urlArray.append(FullURL)
            self.tokohTerkenalArray.append(title)
            self.urlPhotos.append(profileImage)
            self.timeArray.append(formattedDate)
            self.authorArray.append(Author)
            self.descriptionArray.append(description)
        }
        
        DispatchQueue.main.async {
            self.tokohCollectionView.reloadData()
        }
    }
    
    private func updateCollection (quote: JSON) {
        
        let isiQuote  =  quote["quote"]["body"].stringValue
        let namaTokoh = quote["quote"]["author"].stringValue
              
        if  isiQuote.count < 100, namaTokoh.count < 25, isiQuote.count != 0, namaTokoh.count != 0 {
                self.quotesArray.insert(isiQuote, at: 0)
                self.tokohArray.insert(namaTokoh, at: 0)
        } else {
            return
        }
        DispatchQueue.main.async {
            self.quotesCollectionView.reloadData()
        }
        
    }

    //MARK : IBACTION FOR REFRESH, AND DIARY BUTTON
    
    @IBAction func refreshAction(_ sender: Any) {
        failed = false
        checkArray()
    }
    
    @IBAction func writeAction(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goToDiary", sender: self)
        } else {
            self.performSegue(withIdentifier: "goToLogin2", sender: self)
        }
    }
    
    //MARK : LOAD ITEMS FOR DAILY REMINDER
    private func loadItems() {
        reminderRealm = realm.objects(reminder.self)
        quotesCollectionView.reloadData()
        reminderCollectionView.reloadData()
    }
    func indexReceiver(index: Int) {
        newsIndexpath = index
        self.performSegue(withIdentifier: "goToNews", sender: self)
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "goToNews" {
                 if let nextViewController = segue.destination as? NewsViewController {
                    nextViewController.author = authorArray[newsIndexpath]
                    nextViewController.time = timeArray[newsIndexpath]
                    nextViewController.titleNews = tokohTerkenalArray[newsIndexpath]
                    nextViewController.newsProfileURL = urlPhotos[newsIndexpath]
                    nextViewController.descriptionNews = descriptionArray[newsIndexpath]
                    nextViewController.newsURL = urlArray[newsIndexpath]
                   }
               }
           }
        }
