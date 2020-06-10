//
//  HomeViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 21/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import Alamofire
import CoreData
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON
import SDWebImage
import NVActivityIndicatorView
import UIColor_Hex_Swift
import UIKit
import TTGSnackbar
import TMPasscodeLock

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, NVActivityIndicatorViewable, TMPasscodeLockControllerDelegate{
    

    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var quotesPageControl: UIPageControl!
    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var quotesCollectionView: UICollectionView!
    @IBOutlet weak var greetingBackgroundImage: UIImageView!
    @IBOutlet weak var reminderCard: UIView!
    @IBOutlet weak var quotesActivity: NVActivityIndicatorView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var hospitalButton: UIButton!
    @IBOutlet weak var diaryButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameGreeting: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hospitalFinderView: UIView!
    @IBOutlet weak var diaryView: UIView!
    

  // MARK: -DEFINING LET AND VARIABLE
    //Core Data Objects
    fileprivate let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    fileprivate var reminderArray = [Reminder]()
    fileprivate var quotesDBArray = [Quotes]()
    
    //API KEY for quote and news
    fileprivate let quoteAPIURL = "https://favqs.com/api/qotd"
    fileprivate let newsAPIURL = "6a101f1ef174428da463c06bf669ea69"
    fileprivate let statusBarView = UIView()
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate let date = Date()
    fileprivate let calendar = Calendar.current
    fileprivate lazy var hour = calendar.component(.hour, from: date)
    fileprivate let defaults = UserDefaults.standard
    fileprivate let famousQuotePerson = "Helen Keller"
    fileprivate let famousQuote = "\"Optimism is the faith that leads to achievement.\""
    fileprivate var quotesCounter = 0
    fileprivate var x = 1
    fileprivate var timer = Timer()
    private var pinnedChat : String?
    
    //NVACTIVITY Indicator View
    private let size = CGSize(width: 60.0, height: 60.0)
    
    //SNACKBAR OBJECTS FOR SAVE, DELETE, AND INTERNET
    fileprivate let snackbar = TTGSnackbar(message: "No Internet Connection", duration: .long)
    fileprivate let snackbarSave = TTGSnackbar(message: "Pinned!", duration: .middle)
    fileprivate let snackbarDelete = TTGSnackbar(message: "Unpinned!", duration: .middle)
    fileprivate var navigation : UINavigationController?
    
    //ARRAY FOR NEWS FUNCTION
    private var NewsModel = [News]()
    fileprivate var pilihanArticle : String?
    fileprivate var newsIndexpath : Int?

    //VARIABLE for storing username and internetBool
    fileprivate var namaUser : String?
    fileprivate var internet = false
    fileprivate var noDB = false
    fileprivate var fetchType = false
    
    //ALAMOFIREMANAGER Object setup
    fileprivate lazy var alamoFireManager: SessionManager? = {
       let configuration = URLSessionConfiguration.default
       configuration.timeoutIntervalForRequest = 5
       configuration.timeoutIntervalForResource = 5
       let alamoFireManager = Alamofire.SessionManager(configuration: configuration)
       return alamoFireManager
    }()
    
    // Status bar Color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onStartObserver()
        pilihanArticle = defaults.string(forKey: "articleSelection") ?? "Motivational"
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func changedTabBarArticle(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }

    fileprivate func onStartObserver() {
       if Reachability.isConnectedToNetwork() == true {
            if Auth.auth().currentUser != nil {
            print("online with user")
             let userUID = Auth.auth().currentUser?.uid
                let ref     = Database.database().reference()
                let userReference = ref.child("users")
                _ = userReference.child(userUID!).observe(DataEventType.value) { (snapshot) in
                if let snapshotValue = snapshot.value as? [String : String] {
                    let username = snapshotValue["username"] ?? ""
                    self.namaUser = username
                    self.setupTime(time: self.hour)
                    self.loadItems()
                    if self.pinnedChat == nil {
                        self.reminderLabel.text = "-"
                    }else {
                        self.reminderLabel.text = self.pinnedChat
                        }
                   }
               }
            }else {
                print("kebuka online tanpa user")
                self.loadItems()
                if self.pinnedChat == nil {
                   self.reminderLabel.text = "-"
                }else {
                   self.reminderLabel.text = self.pinnedChat
                }
                self.setupTime(time: hour)
            }
        }else {
            print("offline")
            self.loadItems()
            if self.pinnedChat == nil {
                self.reminderLabel.text = "-"
            }else {
                self.reminderLabel.text = self.pinnedChat
            }
            self.setupTime(time: hour)
            namaUser = defaults.object(forKey: "userName") as? String
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForPreviewing(with: self, sourceView: newsCollectionView)
        
        // Dummy data for news
        isiNews()
        
        // Creating Status bar view and background
        viewForStatusBar()
        statusBarView.alpha        = 0
        
        //Quotes CollectionView opacity
        quotesCollectionView.alpha = 0
                
        // Datasource and delegate for CollectionView
        quotesCollectionView.delegate     = self
        quotesCollectionView.dataSource   = self
        newsCollectionView.delegate       = self
        newsCollectionView.dataSource     = self
        scrollView.delegate              = self
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped(Gesture:)))
        quotesCollectionView.addGestureRecognizer(tapped)
        
        // Refresh Control
        refreshControl.addTarget(self, action: #selector(pullToFetch(refreshControl:)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        scrollView.addSubview(refreshControl)
        refreshControl.alpha = 0.6
        
        // Query Quotes and Fetch Data
        loadQuotes()
        initialSetup()
        checkArray()
        setupTime(time: hour)
        
        //Observer for setupTime, greeting label, reminder database, quote database, etc when the user changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.isUserChangedFunction), name: NSNotification.Name(rawValue: "userChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.isUserChangedWithout), name: NSNotification.Name(rawValue: "userChangedWithout"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchTimer), name: NSNotification.Name(rawValue: "fetchTime"), object: nil)
     }
    
    @objc func collectionViewTapped(Gesture: UITapGestureRecognizer) {
       timer.invalidate()
       x = 1
       print("maana")
       DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
           self.setTimer()

       }
    }
    

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == quotesCollectionView {
            timer.invalidate()
            x = 1
            print("maana")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                self.setTimer()

            }
        }
    }

    @objc func fetchTimer() {
        onStartObserver()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tabBarController?.tabBar.isHidden = false
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        // internet state observer remover
         let database = Database.database().reference(withPath: ".info/connected")
         database.removeAllObservers()
        
         // Dismiss Snackbar before changing UIViewController
         snackbarDelete.dismiss()
         snackbarSave.dismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "userChanged"), object: self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "userChangedWithout"), object: self)
    }


    //MARK: Initializing MENU
    private func initialSetup() {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        setupTime(time: hour)
        
        // Setting up background view for Reminders and character spacing
        reminderCard.setLayerReminder()
        
        hospitalFinderView.setTreatmentLayer()
        
        diaryView.setTreatmentLayer()
       
        notificationView.layer.cornerRadius  = 10
        notificationView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        notificationView.layer.shadowOpacity = 0.5
        notificationView.layer.shadowRadius  = 10
        notificationView.layer.shadowOffset  = CGSize(width: 1, height: 1)
        notificationView.layer.shadowColor   = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMM YYYY"
        let dateString = dateFormatter.string(from: Date())
        dateLabel.text = "\(dateString)"
       
        // User defaults for article selection
        pilihanArticle = defaults.string(forKey: "articleSelection") ?? "Motivational"
    }
    
    // Function for setting up status bar
    fileprivate func viewForStatusBar() {
        self.view.insertSubview(statusBarView, at: 4)
        statusBarView.backgroundColor = UIColor("#FF9300")
        var statusBarHeight: CGFloat = 0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136:
                    print("iPhone 5 or 5S or 5C")
                    statusBarHeight = 40
                case 1334:
                    print("iPhone 6/6S/7/8")
                    statusBarHeight = 40
                case 1920, 2208:
                    print("iPhone 6+/6S+/7+/8+")
                    statusBarHeight = 40
                case 2436:
                    print("iPhone X/XS/11 Pro")
                    statusBarHeight = 66
                case 2688:
                    print("iPhone XS Max/11 Pro Max")
                    statusBarHeight = 66
                case 1792:
                    print("iPhone XR/ 11 ")
                    statusBarHeight = 66
                default:
                    statusBarHeight = 40
                }
            }
        statusBarView.frame = CGRect(x: 0, y: -20, width: UIScreen.main.bounds.size.width, height: statusBarHeight)
    }
    
    fileprivate func setupTime (time: Int) {
       // Username user
       let modifiedName = namaUser ?? ""
       // Text that needs to be modified (systemWeight, and systemColor)
        if Auth.auth().currentUser != nil {
            switch time {
               case 5...11:
                let coloredString = "Good Morning"
                let fullString = "Good Morning, \(modifiedName)"
                timeImageSetup(condition: 0, fullstring: fullString, coloredString: coloredString)
               case 12...17:
                let coloredString = "Good Afternoon"
                let fullString = "Good Afternoon, \(modifiedName)"
                timeImageSetup(condition: 1, fullstring: fullString, coloredString: coloredString)
               case 18...22:
                let coloredString = "Good Evening"
                let fullString = "Good Evening, \(modifiedName)"
                timeImageSetup(condition: 2, fullstring: fullString, coloredString: coloredString)
               default:
                let coloredString = "Good Night"
                let fullString = "Good Night, \(modifiedName)"
                timeImageSetup(condition: 5, fullstring: fullString, coloredString: coloredString)
            }
        }else {
            let coloredString = "Guest!"
            switch time {
               case 5...11:
                 let fullString = "Good Morning, Guest!"
                 timeImageSetup(condition: 0, fullstring: fullString, coloredString: coloredString)
               case 12...17:
                 let fullString = "Good Afternoon, Guest!"
                 timeImageSetup(condition: 1, fullstring: fullString, coloredString: coloredString)
               case 18...22:
                 let fullString = "Good Evening, Guest!"
                 timeImageSetup(condition: 2, fullstring: fullString, coloredString: coloredString)
               default:
                 let fullString = "Good Night, Guest!"
                 timeImageSetup(condition: 5, fullstring: fullString, coloredString: coloredString)
            }
        }
    }
    
    fileprivate func timeImageSetup(condition : Int, fullstring : String, coloredString: String) {
      switch condition {
        case 0:
            let attributedString = NSMutableAttributedString(string: fullstring)
            let rangeOfColoredString = (attributedString.string as NSString).range(of: coloredString)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor("#FFE282"), NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)],range: rangeOfColoredString)
            
            DispatchQueue.main.async {
                self.nameGreeting.attributedText = attributedString
                self.greetingBackgroundImage.image = UIImage(named: "flyingBirthMorning")!
                self.greetingBackgroundImage.contentMode = .right
                self.greetingBackgroundImage.setNeedsDisplay()
                self.view.setNeedsDisplay()
            }
            
        case 1:
            let rangeOfColoredString = (fullstring as NSString).range(of: coloredString)
            let attributedString = NSMutableAttributedString(string:fullstring)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor("#FFB400"), NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)],
                                   range: rangeOfColoredString)
            DispatchQueue.main.async {
                self.greetingBackgroundImage.image = UIImage(named: "afternoonBaru")!
                self.greetingBackgroundImage.contentMode = .scaleToFill
                self.refreshControl.tintColor = .darkGray
                self.nameGreeting.attributedText = attributedString
                self.greetingBackgroundImage.setNeedsDisplay()
                self.view.setNeedsDisplay()
            }
         
        case 2:
            let rangeOfColoredString = (fullstring as NSString).range(of: coloredString)
            let attributedString = NSMutableAttributedString(string:fullstring)
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor("#FFC400"), NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)], range: rangeOfColoredString)
            DispatchQueue.main.async {
                self.nameGreeting.attributedText = attributedString
                self.greetingBackgroundImage.image = UIImage(named: "nightTest")!
                self.greetingBackgroundImage.contentMode = .scaleAspectFill
                self.greetingBackgroundImage.setNeedsDisplay()
            }
           
        default:
           let rangeOfColoredString = (fullstring as NSString).range(of: coloredString)
           let attributedString = NSMutableAttributedString(string:fullstring)
           attributedString.setAttributes([NSAttributedString.Key.foregroundColor: UIColor("#FFC400"), NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16.0)], range: rangeOfColoredString)
           DispatchQueue.main.async {
               self.nameGreeting.attributedText = attributedString
               self.greetingBackgroundImage.image = UIImage(named: "nightTest")!
               self.greetingBackgroundImage.contentMode = .scaleAspectFill
               self.greetingBackgroundImage.setNeedsDisplay()
           }
        }
    }
    
    //MARK: - Collection View Delegate and Datasource Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.quotesCollectionView {
            quotesPageControl.numberOfPages = quotesDBArray.count
            quotesPageControl.isHidden = !(quotesDBArray.count > 1)
                return quotesDBArray.count
        } else {
            return NewsModel.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.quotesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection", for: indexPath) as! quoteCollectionViewCell
            
                let quote = quotesDBArray[indexPath.item]
            
                //quotesFunc Protocol Delegate for pinning quotes
                cell.delegate = self
            
                //Configuring Quotes Cell, setting label, text, image etc
                cell.configureQuotesCell(quotes: quote)
            
            return cell
            
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCollection", for: indexPath) as! NewsCollectionViewCell
            let indexpath = indexPath.item
                //Configuring News Cell, setting label, text, image etc
            cell.setupNewsCell(articleSelection: pilihanArticle ?? "Motivational", isiNews : NewsModel[indexpath].newsContents)
            cell.photoTokoh.sd_setImage(with:URL(string: self.NewsModel[indexpath].urlPhoto))
//                cell.photoTokoh.sd_setImage(with: <#T##URL?#>) { (image, error, imageCache, URL) in
//                if error != nil {
//                    cell.photoTokoh.image = UIImage(named: <#T##String#>)
//                   }
//                }
                    
            //NewsTapped protocol for Segueing to the NewsViewController
            cell.delegate  = self
            cell.isHidden  = false
            cell.indexpath = indexpath
            
            cell.tokohLabel.text = NewsModel[indexpath].newsContents
            cell.dateLabel.text  = NewsModel[indexpath].time
            return cell
          }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == quotesCollectionView {
                return  CGSize(width: 344, height: 97)
        } else if collectionView == newsCollectionView {
            if indexPath.row % 2 == 0 {
                return CGSize(width: 175, height: 225)
            } else {
                return CGSize(width: 175, height: 250)
            }
        }else {
            return CGSize(width: 330, height: 158)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == quotesCollectionView {
            let visibleRect = CGRect(origin: self.quotesCollectionView.contentOffset, size: self.quotesCollectionView.bounds.size)
             let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
             if let visibleIndexPath = self.quotesCollectionView.indexPathForItem(at: visiblePoint) {
                 self.quotesPageControl.currentPage = visibleIndexPath.row
             }
        }else if scrollView == self.scrollView {
            let scrollOffset = scrollView.contentOffset.y
            if scrollOffset <= 10 {
                UIView.animate(withDuration: 0.2) {
                    self.statusBarView.alpha = 0
                }
            }else {
                UIView.animate(withDuration: 0.3) {
                    self.statusBarView.alpha = 1
                }
            }
        }
    }
      
    //MARK: - Mentrely's IBAction function
    @IBAction func writeAction(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            if TMPasscodeLock.isPasscodeSet {
                let passcodeLockViewController = TMPasscodeLockController(style: .basic, state: .enter)
                    passcodeLockViewController.delegate = self
                    passcodeLockViewController.presentIn(viewController: self, animated: true)
            } else {
                self.performSegue(withIdentifier: "goToDiary", sender: self)
            }
        } else {
            self.performSegue(withIdentifier: "goToLogin", sender: self)
        }
    }
    
    //Cross check before fetching Quotes for quotesCollectionView
    fileprivate func checkArray() {
        if quotesDBArray.count <= 5 {
            if fetchType == false {
                quotesActivity.type = .ballRotateChase
                quotesActivity.startAnimating()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                self.quotesActivity.stopAnimating()
                UIView.animate(withDuration: 0.3) {
                    self.quotesCollectionView.alpha = 1
                    }
                }
            }else {
                startAnimating(size, message: "Loading",type: .ballRotateChase, color: UIColor.white, textColor: UIColor.white)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Hang in there")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        self.stopAnimating(nil)
                        }
                    }
                }
              getQuotes()
              getQuotes()
              getQuotes()
              getQuotes()
              getQuotes()
              getQuotes()
              fetchNews()
          } else {
              startAnimating(size, message: "Loading",type: .ballRotateChase, color: UIColor.white, textColor: UIColor.white)
              DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                NVActivityIndicatorPresenter.sharedInstance.setMessage("Hang in there")
                  DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                      self.stopAnimating(nil)
                  }
              }
              fetchNews()
          }
        
      }
    //Check for Internet connectivity and automatically fetch data
       private func internetObserver() {
           let connectedRef = Database.database().reference(withPath: ".info/connected")
                connectedRef.observe(.value, with: { snapshot in
                if let connected = snapshot.value as? Bool, connected {
                   print("internetobserver nyala")
                   self.snackbar.dismiss()
                   self.snackbarSave.dismiss()
                   self.snackbarDelete.dismiss()
                   self.internet = false
                   self.fetchType = true
                   if self.NewsModel[0].newsContents == "" {
                        self.checkArray()
                   }
                } else {
                   print("internetobserver mati")
                    if self.NewsModel[0].newsContents == "" {
                        self.snackbar.animationType    = .slideFromTopBackToTop
                        self.snackbar.backgroundColor  = UIColor.black
                        self.snackbar.messageTextColor = UIColor.white
                        self.snackbar.show()
                        self.snackbar.alpha = 0.8
                    }
                }
           })
       }
        
    //MARK: - Fetch quote
    private func getQuotes () {
        alamoFireManager!.request(quoteAPIURL, method: .get ).responseJSON { (response) in
            if response.result.isSuccess {
                let quoteJSON : JSON = JSON(response.result.value!)
                self.updateQuotesCollection(quote: quoteJSON)
            } else {
                self.quotesActivity.stopAnimating()
                 UIView.animate(withDuration: 0.3) {
                    self.quotesCollectionView.alpha = 1
                }
                print(response.result.error?.localizedDescription ?? "")
                if self.internet ==  false  {
                    print("FAILED GETTING THE DATA")
                    self.internet = true
                    self.internetObserver()
                }
            }
        }
    }
    
    fileprivate func updateQuotesCollection (quote: JSON) {
         var isiQuote  = quote["quote"]["body"].stringValue
         let namaTokoh = quote["quote"]["author"].stringValue
         let quoteID   = quote["quote"]["id"].int16Value
         isiQuote.insert("\"", at: isiQuote.startIndex)
         isiQuote.append("\"")
        
         if isiQuote.count > 0 && isiQuote.count < 50{
            let quotes = Quotes(context: self.context)
            quotes.username = self.namaUser ?? "Guest"
            quotes.isQuote = false
            quotes.quotes = isiQuote
            quotes.quotesTokoh = namaTokoh
            quotes.quoteID = quoteID
            quotesDBArray.append(quotes)
        }
            quotesCounter += 1
        
        if noDB == true {
            quotesDBArray.shuffle()
        }
        
        if quotesCounter == 6 && fetchType == false {
            quotesActivity.stopAnimating()
            UIView.animate(withDuration: 0.3) {
                self.quotesCollectionView.alpha = 1
                self.setTimer()
            }
            let range = Range(uncheckedBounds: (0, quotesCollectionView.numberOfSections))
            let indexSet = IndexSet(integersIn: range)
            quotesCollectionView.reloadSections(indexSet)
            quotesCounter = 0
        }else if quotesCounter == 6 && fetchType == true {
            let range = Range(uncheckedBounds: (0, quotesCollectionView.numberOfSections))
            let indexSet = IndexSet(integersIn: range)
            quotesCollectionView.reloadSections(indexSet)
            quotesCounter = 0
        }
     }
    
    fileprivate func isiNews() {
        for _ in stride(from: 0, to: 4, by: 1) {
            NewsModel.append(News(newsContent: "", urlPhoto: "", newsDesc: "", urlWeb: "", sourceName: "", hourPublished: "", timePublished: "", author: ""))
        }
        self.newsCollectionView.reloadData()
    }

    //MARK: FETCH NEWS
    fileprivate func fetchNews () {
        let newsURL = "https://newsapi.org/v2/everything?q="+(pilihanArticle ?? "mentalhealth")+"&language=en&sortBy=relevancy&apiKey=\(newsAPIURL)"
        alamoFireManager!.request(newsURL, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let newsJson : JSON = JSON(response.result.value!)
                self.updateArrayNews(news: newsJson)
                print("data is fetched")
            } else {
                if response.result.error?.localizedDescription == "The Internet connection appears to be offline." {
                    self.snackbar.animationType = .slideFromTopBackToTop
                    self.snackbar.backgroundColor = UIColor.black
                    self.snackbar.messageTextColor = UIColor.white
                    self.snackbar.leftMargin = 25
                    self.snackbar.rightMargin = 25
                    self.snackbar.show()
                    self.snackbar.alpha = 0.8
                }
                self.stopAnimating(nil)
            }
        }
    }
    
    //MARK: - Function for PARSING NEWS JSON DATA
    private func updateArrayNews(news: JSON) {
        var indexNews = 0
        let batasBawah = Int.random(in: 0...4)
        for index in stride(from: batasBawah, to: batasBawah+4, by: 1){
            let title = news["articles"].arrayValue[index]["title"].stringValue
            let profileImage = news["articles"].arrayValue[index]["urlToImage"].stringValue
            let Author = news["articles"].arrayValue[index]["author"].stringValue
            let date = news["articles"].arrayValue[index]["publishedAt"].stringValue
            let description = news["articles"].arrayValue[index]["content"].stringValue
            let FullURL = news["articles"].arrayValue[index]["url"].stringValue
            let source = news["articles"].arrayValue[index]["source"]["name"].stringValue
            
            var formattedDate = date
            formattedDate = String(formattedDate.prefix(10))
            let suffixIndex = date.index(date.endIndex, offsetBy: -8)
            let suffix = String(date[suffixIndex...])
            var formattedHour =  suffix
            formattedHour = String(formattedHour.prefix(4))

            NewsModel[indexNews].author = Author
            NewsModel[indexNews].time = formattedDate
            NewsModel[indexNews].hour = formattedHour
            NewsModel[indexNews].newsContents = title
            NewsModel[indexNews].description = description
            NewsModel[indexNews].url = FullURL
            NewsModel[indexNews].urlPhoto = profileImage
            NewsModel[indexNews].source = source
            indexNews += 1

        }
        
        if self.internet == true {
            let internetObserver = Database.database().reference(withPath: ".info/connected")
            internetObserver.removeAllObservers()
        }
       
        let range = Range(uncheckedBounds: (0,newsCollectionView.numberOfSections))
        let indexSet = IndexSet(integersIn: range)
        newsCollectionView.reloadSections(indexSet)
        print(NewsModel.count)
        stopAnimating(nil)
    }
    
    //MARK: -ScrollView Pull to Fetch Control Function
    @objc func pullToFetch(refreshControl: UIRefreshControl) {
        for index in stride(from: 0, to: 4, by: 1) {
            NewsModel[index].author = ""
            NewsModel[index].time = ""
            NewsModel[index].hour = ""
            NewsModel[index].newsContents = ""
            NewsModel[index].description = ""
            NewsModel[index].url = ""
            NewsModel[index].urlPhoto = ""
            NewsModel[index].source = ""
        }
        newsCollectionView.reloadData()
        fetchType = true
        snackbar.dismiss()
        checkArray()
        refreshControl.endRefreshing()
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc func autoScroll() {
         if self.x < self.quotesDBArray.count {
           let indexPath = IndexPath(item: x, section: 0)
             self.quotesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
           self.x = self.x + 1
         }else {
             self.x = 1
             self.quotesCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
         }
     }

    fileprivate func loadQuotes() {
        let request: NSFetchRequest<Quotes> = Quotes.fetchRequest()
            let predicate : NSPredicate?
        
            //Query Quotes on the Internet and User conditions
             if Auth.auth().currentUser != nil {
               if Reachability.isConnectedToNetwork() == true {
                   predicate = NSPredicate(format: "username CONTAINS[CD] %@", Auth.auth().currentUser!.uid)
               }else {
                   let UID = defaults.value(forKey: "userUID") as? String
                   predicate = NSPredicate(format: "username CONTAINS[CD] %@", UID ?? "")
               }
             }else {
               predicate = NSPredicate(format: "username CONTAINS[CD] %@", "/sadGuest1231")
            }
        
            request.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "username", ascending: false)
            request.sortDescriptors = [sortDescriptor]
           do {
                quotesDBArray = try context.fetch(request)
                if quotesDBArray.count == 0 {
                    noDB = true
                    addDummyQuote()
                }
           }catch {
                print("error fetching data \(error.localizedDescription)")
           }
         let range = Range(uncheckedBounds: (0, quotesCollectionView.numberOfSections))
         let indexSet = IndexSet(integersIn: range)
         quotesCollectionView.reloadSections(indexSet)
    }
    
    //Function For Loading Coredata into reminderArray
    fileprivate func loadItems() {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        let predicate : NSPredicate?
        // Query Reminder based on the Internet and User conditions
         if Auth.auth().currentUser != nil {
             if Reachability.isConnectedToNetwork() == true {
                predicate = NSPredicate(format: "username CONTAINS[CD] %@ AND isPinned == %@", Auth.auth().currentUser!.uid, NSNumber(booleanLiteral: true))
             }else {
                let UID = defaults.value(forKey: "userUID") as? String
                predicate = NSPredicate(format: "username CONTAINS[CD] %@  AND isPinned == %@", UID ?? "",  NSNumber(booleanLiteral: true))
             }
         }else {
            predicate = NSPredicate(format: "username CONTAINS[CD] %@  AND isPinned == %@", "Guest", NSNumber(booleanLiteral: true))
         }
        request.predicate = predicate
        let sortDescriptor : NSSortDescriptor?
        sortDescriptor = NSSortDescriptor(key: "username", ascending: false)
        request.sortDescriptors = [(sortDescriptor ?? NSSortDescriptor(key: "dateCreated", ascending: true))]
        do {
            pinnedChat = nil
            reminderArray = try context.fetch(request)
            if reminderArray.count != 0 {
                pinnedChat =  reminderArray[0].daily
            }
        } catch {
            print("error fetching data \(error)")
        }
    }
    
    private func addDummyQuote() {
        let quotes = Quotes(context: self.context)
        quotes.isQuote = false
        quotes.quotesTokoh = famousQuotePerson
        quotes.quotes = famousQuote
        quotes.username = self.namaUser ?? ""
        quotes.quoteID = 0
        quotesDBArray.insert(quotes, at: 0)
    }
    
    private func saveItems() {
         do {
            try context.save()
                snackbarSave.animationType = .slideFromTopBackToTop
                snackbarSave.leftMargin = 25
                snackbarSave.rightMargin = 25
                snackbarSave.shouldDismissOnSwipe = true
                snackbarSave.show()
             } catch {
                fatalError("error saving context \(error.localizedDescription)")
            }
         let range = Range(uncheckedBounds: (0, self.quotesCollectionView.numberOfSections))
         let indexSet = IndexSet(integersIn: range)
         self.quotesCollectionView.reloadSections(indexSet)
    }
    
    //MARK: -Prepare DataSet before segueing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "goToNews" {
             if let nextViewController = segue.destination as? NewsViewController {
                nextViewController.author           = NewsModel[self.newsIndexpath ?? 0].author
                nextViewController.time            = NewsModel[self.newsIndexpath ?? 0].time
                nextViewController.titleNews       = NewsModel[self.newsIndexpath ?? 0].newsContents
                nextViewController.newsProfileURL   = NewsModel[self.newsIndexpath ?? 0].urlPhoto
                nextViewController.descriptionNews  = NewsModel[self.newsIndexpath ?? 0].description
                nextViewController.newsURL         = NewsModel[self.newsIndexpath ?? 0].url
                nextViewController.website         = NewsModel[self.newsIndexpath ?? 0].source
                nextViewController.hour            = NewsModel[self.newsIndexpath ?? 0].hour
            }
         }else if segue.identifier == "goToLogin" {
            if let nextViewController = segue.destination as? LoginViewController {
                nextViewController.condition = 0
            }
        }
    }
  
    //MARK: -Notification Observer Function
    @objc func isUserChangedFunction() {
        if self.internet == true {
            let internetObserver = Database.database().reference(withPath: ".info/connected")
            internetObserver.removeAllObservers()
        }
        reminderArray.removeAll()
        quotesDBArray.removeAll()
        onStartObserver()
        loadQuotes()
        checkArray()
        performSegue(withIdentifier: "goToDiary", sender: self)
    }
    
    @objc func isUserChangedWithout() {
        if self.internet == true {
            let internetObserver = Database.database().reference(withPath: ".info/connected")
            internetObserver.removeAllObservers()
        }
        reminderArray.removeAll()
        quotesDBArray.removeAll()
        onStartObserver()
        loadQuotes()
        checkArray()
    }
    
    //Delete Quotes/Unpinned Quote based on their ID
    fileprivate func deleteQuote(int : Int16) {
       let fetchRequest: NSFetchRequest<Quotes> = Quotes.fetchRequest()
       fetchRequest.predicate = NSPredicate.init(format: "quoteID==\(int)")
       let objects = try! context.fetch(fetchRequest)
       for obj in objects {
           context.delete(obj)
       }
       do {
        try context.save()
          snackbarDelete.animationType = .slideFromTopBackToTop
          snackbarDelete.leftMargin = 25
          snackbarDelete.rightMargin = 25
          snackbarDelete.shouldDismissOnSwipe = true
          snackbarDelete.show()
       } catch {
            fatalError("Can't Delete Quote \(error.localizedDescription)")
       }
   }
}

extension HomeViewController: UIViewControllerPreviewingDelegate  {
     func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
           
        if self.NewsModel[0].newsContents != "" {
            // Obtain the index path and the cell that was pressed.
             guard let indexPath = newsCollectionView.indexPathForItem(at: location),
             let cell = newsCollectionView.cellForItem(at: indexPath) else { return nil }

             // Create a destination view controller and set its properties.
             guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "DestinationViewController") as? NewsViewController else { return nil }
             nextViewController.author          = NewsModel[indexPath.row].author
             nextViewController.time            = NewsModel[indexPath.row].time
             nextViewController.titleNews       = NewsModel[indexPath.row].newsContents
             nextViewController.newsProfileURL =   NewsModel[indexPath.row].urlPhoto
             nextViewController.descriptionNews  = NewsModel[indexPath.row].description
             nextViewController.newsURL         = NewsModel[indexPath.row].url
             nextViewController.website         = NewsModel[indexPath.row].source
             nextViewController.hour            = NewsModel[indexPath.row].hour
             newsIndexpath = indexPath.row
             nextViewController.preferredContentSize = CGSize(width: 0.0, height: nextViewController.view.frame.height/2)
             previewingContext.sourceRect = cell.frame
             /*
                 Set the height of the preview by setting the preferred content size of the destination view controller. Height: 0.0 to get default height
             */
           navigation = UINavigationController(rootViewController: nextViewController)
           if #available(iOS 13.0, *) {
               if let navigation = navigation {
                   let navBarAppearance = UINavigationBarAppearance()
                      navBarAppearance.configureWithOpaqueBackground()
                      navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                      navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                      navBarAppearance.backgroundColor = UIColor("#FF9300")
                      navBarAppearance.shadowColor = .clear
                      navigation.navigationBar.shadowImage = UIImage()
                      navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
                      navigation.navigationBar.standardAppearance = navBarAppearance
                      navigation.navigationBar.scrollEdgeAppearance = navBarAppearance
                  }
               }
             return navigation
           }else {
               return nil
           }
       }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if self.navigation != self.navigationController {
            self.navigation?.popToRootViewController(animated: true)
        }
        self.performSegue(withIdentifier: "goToNews", sender: self)
    }
}

extension HomeViewController : quotesFunc, newsTapped {
        //MARK: - Quotes Protocol
        func quotesIndex(cell: quoteCollectionViewCell) {
            var alert : UIAlertController?
            let indexPath = self.quotesCollectionView.indexPath(for: cell)
            let quotes = self.quotesDBArray[indexPath!.item]
    
            if quotes.isQuote == true {
                alert = UIAlertController(title: "", message: "Are you sure want to delete this quote?", preferredStyle: .alert)
                snackbarDelete.dismiss()
                snackbarSave.dismiss()
                let action = UIAlertAction(title: "   Unpin Quote   ", style: .destructive) { (uialertaction) in
                   let ID = quotes.quoteID
                   self.deleteQuote(int: ID)
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.003) {
                        self.quotesDBArray.remove(at:indexPath!.item)
                        if self.quotesDBArray.count == 0 {
                            self.addDummyQuote()
                        }
                        self.quotesCollectionView.deleteItems(at: [indexPath!])
                        self.quotesCollectionView.reloadData()
                   }
               }
                alert!.addAction(action)
           }else {
                
                alert = UIAlertController(title: "", message: "Do you want to pin this quote?", preferredStyle: .alert)
               self.snackbarSave.dismiss()
               self.snackbarDelete.dismiss()
                
               let action = UIAlertAction(title: "Pin Quote", style: .default) { (uialertaction) in
                
                quotes.isQuote      = true
                let newItem         = Quotes(context: self.context)
                newItem.quotes      = quotes.quotes
                newItem.isQuote     = true
                newItem.quotesTokoh = quotes.quotesTokoh
                newItem.quoteID    = quotes.quoteID
              
                 if Auth.auth().currentUser != nil {
                    newItem.username = Auth.auth().currentUser!.uid
                 } else {
                   newItem.username = "/sadGuest1231"
                 }
                self.saveItems()
               }
               alert!.addAction(action)
           }
            
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert!.addAction(cancel)
        self.present(alert!, animated: true, completion: nil)
    }
    
    //MARK: -Protocol News Function
    func indexReceiver(index: Int) {
         newsIndexpath = index
         performSegue(withIdentifier: "goToNews", sender: self)
     }
    //MARK: -Passcode Delegate
    func passcodeLockController(passcodeLockController: TMPasscodeLockController, didFinishFor state: TMPasscodeLockState) {
        self.performSegue(withIdentifier: "goToDiary", sender: self)
    }
        
    func passcodeLockControllerDidCancel(passcodeLockController: TMPasscodeLockController) {
        return
    }
}
