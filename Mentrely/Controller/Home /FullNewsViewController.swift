//
//  FullNewsViewController.swift
//  Mentrely
//
//  Created by Mikhael Adiputra on 27/05/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import SwiftyJSON
import TTGSnackbar
import Alamofire
import UIColor_Hex_Swift

class FullNewsViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, newsTapped,UICollectionViewDelegateFlowLayout, UIViewControllerPreviewingDelegate  {
    
   @IBOutlet weak var scrollView: UIScrollView!
   @IBOutlet weak var NewsCollectionView: UICollectionView!
    
   private var NewsModel = [News]()
   private let refreshControl = UIRefreshControl()
   private var newsIndexpath : Int?
   private var pilihanArticle : String?
   private let defaults = UserDefaults.standard
   private var navigation : UINavigationController?
   private let snackbar = TTGSnackbar(message: "No Internet Connection", duration: .long)
   private let newsAPIURL = "6a101f1ef174428da463c06bf669ea69"
   //ALAMOFIREMANAGER Object setup
   private lazy var alamoFireManager: SessionManager? = {
   let configuration = URLSessionConfiguration.default
   configuration.timeoutIntervalForRequest = 5
   configuration.timeoutIntervalForResource = 5
   let alamoFireManager = Alamofire.SessionManager(configuration:  configuration)
   return alamoFireManager
   }()
   
   override func viewWillAppear(_ animated: Bool) {
        pilihanArticle = defaults.string(forKey: "articleSelection") ?? "Motivational"
   }
     
    override func viewDidLoad() {
        super.viewDidLoad()
          isiNews()
          fetchNews()
          registerForPreviewing(with: self, sourceView: NewsCollectionView)
          NewsCollectionView.delegate = self
          NewsCollectionView.dataSource = self
          refreshControl.addTarget(self, action: #selector(pullToFetch(refreshControl:)), for: .valueChanged)
          refreshControl.tintColor = UIColor.black
          scrollView.addSubview(refreshControl)
          refreshControl.alpha = 0.6
    }
    
    fileprivate func isiNews() {
        for _ in stride(from: 0, to: 8, by: 1) {
            NewsModel.append(News(newsContent: "", urlPhoto: "", newsDesc: "", urlWeb: "", sourceName: "", hourPublished: "", timePublished: "", author: ""))
        }
        self.NewsCollectionView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNewsDetail" {
            if let nextViewController = segue.destination as? NewsViewController {
                nextViewController.author          = NewsModel[self.newsIndexpath ?? 0].author
                nextViewController.time            = NewsModel[self.newsIndexpath ?? 0].time
                nextViewController.titleNews       = NewsModel[self.newsIndexpath ?? 0].newsContents
                nextViewController.newsProfileURL   = NewsModel[self.newsIndexpath ?? 0].urlPhoto
                nextViewController.descriptionNews  = NewsModel[self.newsIndexpath ?? 0].description
                nextViewController.newsURL         = NewsModel[self.newsIndexpath ?? 0].url
                nextViewController.website         = NewsModel[self.newsIndexpath ?? 0].source
                nextViewController.hour            = NewsModel[self.newsIndexpath ?? 0].hour
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NewsModel.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         if collectionView == NewsCollectionView {
            if indexPath.row % 2 == 0 {
                return CGSize(width: 175, height: 200)

            }else {
                return CGSize(width: 175, height: 225)
            }
         }else {
            return CGSize(width: 175, height: 225)
        }
    }
      
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            cell.delegate = self
            cell.isHidden = false
            cell.indexpath = indexpath
            
            cell.tokohLabel.text = NewsModel[indexpath].newsContents
            cell.dateLabel.text  = NewsModel[indexpath].time
        
        return cell
    }
    
    
    //MARK: FETCH NEWS
    fileprivate func fetchNews () {
            let newsURL = "https://newsapi.org/v2/everything?q="+(pilihanArticle ?? "mentalhealth")+"&language=en&sortBy=relevancy&apiKey=\(newsAPIURL)"
            alamoFireManager!.request(newsURL, method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let newsJson : JSON = JSON(response.result.value!)
                self.updateArrayNews(news: newsJson)
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
            }
        }
    }
    
    //MARK: - Function for PARSING NEWS JSON DATA
       private func updateArrayNews(news: JSON) {
           var indexNews = 0
           let batasBawah = Int.random(in: 0...8)
           for index in stride(from: batasBawah, to: batasBawah+8, by: 1){
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
       let range = Range(uncheckedBounds: (0,NewsCollectionView.numberOfSections))
       let indexSet = IndexSet(integersIn: range)
       NewsCollectionView.reloadSections(indexSet)
    }
    
  
    //MARK: -ScrollView Pull to Fetch Control Function
    @objc func pullToFetch(refreshControl: UIRefreshControl) {
        for index in stride(from: 0, to: 8, by: 1) {
           NewsModel[index].author = ""
           NewsModel[index].time = ""
           NewsModel[index].hour = ""
           NewsModel[index].newsContents = ""
           NewsModel[index].description = ""
           NewsModel[index].url = ""
           NewsModel[index].urlPhoto = ""
           NewsModel[index].source = ""
        }
        NewsCollectionView.reloadData()
        fetchNews()
        refreshControl.endRefreshing()
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    if self.NewsModel[0].newsContents != "" {

    // Obtain the index path and the cell that was pressed.
        guard let indexPath = NewsCollectionView.indexPathForItem(at: location),
        let cell = NewsCollectionView.cellForItem(at: indexPath) else { return nil }

            // Create a destination view controller and set its properties.
            guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "DestinationViewController") as? NewsViewController else { return nil }
            nextViewController.author          = NewsModel[indexPath.row].author
            nextViewController.time            = NewsModel[indexPath.row].time
            nextViewController.titleNews       = NewsModel[indexPath.row].newsContents
            nextViewController.newsProfileURL   = NewsModel[indexPath.row].urlPhoto
            nextViewController.descriptionNews  = NewsModel[indexPath.row].description
            nextViewController.newsURL         = NewsModel[indexPath.row].url
            nextViewController.website         = NewsModel[indexPath.row].source
            nextViewController.hour           = NewsModel[indexPath.row].hour
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
        self.performSegue(withIdentifier: "goToNewsDetail", sender: self)
    }
    
    func indexReceiver(index: Int) {
         newsIndexpath = index
         performSegue(withIdentifier: "goToNewsDetail", sender: self)
    }

}
