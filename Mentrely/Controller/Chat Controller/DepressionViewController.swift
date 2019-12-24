//
//  DepressionViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 20/10/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import UIColor_Hex_Swift
import TTGSnackbar
import SDWebImage
import CoreData

class DepressionViewController: UICollectionViewController, UITextFieldDelegate,UICollectionViewDelegateFlowLayout, profileButton{
    
    var profileIndexpath = 0
    var segueIndex = 0
    var database = ""
    var navigationTitle = ""
    let snackbar = TTGSnackbar(message:"Welcome to Depression Support Group.", duration: .middle)
    private let cellID = "cellID"
    private var namaUser = ""
    private var state = false
    private var messageArray = [Chat]()
    private var containerViewBottom : NSLayoutConstraint?
    private let segueIdentifier = ["goToPopDepression", "goToPopHyper","goToPopBipolar", "goToPopAnxiety", "goToPopOCD", "goToPopPTSD"]
    private let date = Date()
    private let calendar = Calendar.current
    private var lastContentOffset : CGFloat = 0
    private var floatingButton: UIButton?
    private let floatingButtonImageName = "arrow2"
    private static let buttonHeight: CGFloat = 25
    private static let buttonWidth: CGFloat = 25
    private let trailingValue: CGFloat = 15.0
    private let leadingValue: CGFloat = 15.0
    private let shadowRadius: CGFloat = 0.5
    private let shadowOpacity: Float = 0.5
    private let shadowOffset = CGSize(width: 1.0, height: 1.0)
    private let scaleKeyPath = "scale"
    private let animationKeyPath = "transform.scale"
    private let animationDuration: CFTimeInterval = 0.4
    private let animateFromValue: CGFloat = 1.00
    private let animateToValue: CGFloat = 1.05
    private let roundValue = DepressionViewController.buttonHeight/2
    private let newNotificationButton = UIButton()
    private var profileURL = ""
    private var keyboardDuration = 0.0
    private var keyboardHeight : CGFloat?
    @IBOutlet weak var navigationButton: UIButton!
    private var defaults = UserDefaults.standard
    private let snackbarInternet = UIView()
    private let internetTextView = UITextView()
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
      
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var managedObjectContext: NSManagedObjectContext? {
          return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      }
    
    lazy var inputTextField : UITextField = {
        let TextField = UITextField()
        TextField.placeholder = "Enter Message"
        TextField.translatesAutoresizingMaskIntoConstraints = false
        TextField.delegate = self
        return TextField
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.floatingButton?.isHidden = true
        self.newNotificationButton.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationButton.contentHorizontalAlignment = .left
        navigationButton.setTitle(navigationTitle, for: .normal)
        
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        self.activityIndicator.color = UIColor.white
        
        self.observeMessages()
        setupKeyboardObservers()
        if Reachability.isConnectedToNetwork() == true {
      
            self.activityIndicator.startAnimating()
            let userUID   = Auth.auth().currentUser?.uid
                  _ = Database.database().reference().child("users").child(userUID!).observe(DataEventType.value) { (snapshot) in
                      if let postDict = snapshot.value as? [String:Any] {
                          let username = postDict["username"] as! String
                       self.namaUser = username
                    }
                }
                self.newNotificationButton.isHidden = true
                snackbarInternet.isHidden = true
                internetTextView.isHidden = true
                createFloatingButton()
        } else {
            inputTextField.isEnabled = false
            snackbarInternet.isHidden = false
            internetTextView.isHidden = false
            inputTextField.backgroundColor = UIColor.lightGray
            inputTextField.placeholder = "Not Available"
        }
        setupUI()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleKeyboard))
        collectionView?.addGestureRecognizer(gestureRecognizer)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.newNotificationButton.backgroundColor = UIColor.black
    }
    
    override func viewDidDisappear(_ animated: Bool) {
            guard floatingButton?.superview != nil else {  return }
            DispatchQueue.main.async {
                self.floatingButton?.removeFromSuperview()
                self.floatingButton = nil
                self.inputTextField.resignFirstResponder()
                self.containerViewBottom?.constant = 0
                self.snackbar.dismiss()
                if Reachability.isConnectedToNetwork() == false {
                    self.snackbarInternet.isHidden = true
                    self.internetTextView.isHidden = true
                    self.snackbar.isHidden = true
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
           if state == false{
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.00001) {
                    self.scrollToBottom(animated: false)
                }
               state = true
           }else {
               return
           }
       }
       
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    deinit {
         //stop events
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboard(_ gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: self.keyboardDuration) {
                self.inputTextField.resignFirstResponder()
                self.containerViewBottom?.constant = 0

                self.collectionView.frame.origin.y = -28
                self.view.layoutIfNeeded() }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return }
        
        let keyboardHeight = keyboardFrame.height
        
        guard let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return }
    
            if notification.name == UIResponder.keyboardWillShowNotification {
                if self.collectionView.contentSize.height < self.collectionView.frame.height {
                  self.keyboardDuration = keyboardDuration
                  self.keyboardHeight = keyboardHeight
                  containerViewBottom?.constant = -keyboardHeight
                  collectionView?.frame.origin.y = -keyboardHeight/2
                  UIView.animate(withDuration: keyboardDuration) {
                  self.view.layoutIfNeeded() }
                  print("keyboard atas + kebuka")
                } else  if collectionView.contentSize.height/2 > collectionView.frame.height/2 {
                    self.keyboardDuration = keyboardDuration
                    self.keyboardHeight = keyboardHeight
                    containerViewBottom?.constant = -keyboardHeight
                    collectionView?.frame.origin.y = -keyboardHeight-30
                    UIView.animate(withDuration: keyboardDuration) {
                    self.view.layoutIfNeeded() }
                    print("keyboard tengah")
                } else {
                     UIView.animate(withDuration: keyboardDuration) {
                        self.collectionView?.frame.origin.y = 0
                        self.keyboardDuration = keyboardDuration
                        self.containerViewBottom?.constant = -keyboardHeight
                        self.view.layoutIfNeeded() }
                        print("keyboard bawah")
                }
            }
        }
    
    //MARK: - COLLECTION VIEW FUNCTION
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath ) as! ChatMessageCell
            let message = messageArray[indexPath.row]
        
            if indexPath.row == messageArray.count - 1  {
                floatingButton?.isHidden = true
                self.newNotificationButton.isHidden = true
            }else {
                floatingButton?.isHidden = false
            }
            
            cell.delegate = self
            cell.indexpath = indexPath.row
   
            if Reachability.isConnectedToNetwork() == false {
               let messageNama = defaults.object(forKey: "userName") as! String
                if message.sender == messageNama  && message.uid == Auth.auth().currentUser!.uid{
                    cell.bubble.backgroundColor = UIColor("#D56A92")
                    cell.textView.textColor = UIColor.white
                    cell.bubbleViewRightAnchor?.isActive = true
                    cell.bubbleViewLeftAnchor?.isActive = false
                    cell.imageView.isHidden = true
                    cell.textViewNama.isHidden = true
                    cell.timeTableRightAnchor?.isActive = true
                    cell.timeTableLeftAnchor?.isActive = false
                    cell.profileButton.isHidden = true
                    
                } else {
                    cell.bubble.backgroundColor = UIColor("#E8EBE4")
                    cell.textView.textColor = UIColor.black
                    cell.bubbleViewRightAnchor?.isActive = false
                    cell.bubbleViewLeftAnchor?.isActive = true
                    cell.imageView.isHidden = false
                    cell.textViewNama.isHidden = false
                    cell.timeTableRightAnchor?.isActive = false
                    cell.timeTableLeftAnchor?.isActive = true
                    cell.profileButton.isHidden = false
                }
            } else {
                if message.sender == self.namaUser && message.uid == Auth.auth().currentUser!.uid{
                          cell.bubble.backgroundColor = UIColor("#D56A92")
                          cell.textView.textColor = UIColor.white
                          cell.bubbleViewRightAnchor?.isActive = true
                          cell.bubbleViewLeftAnchor?.isActive = false
                          cell.imageView.isHidden = true
                          cell.textViewNama.isHidden = true
                          cell.timeTableRightAnchor?.isActive = true
                          cell.timeTableLeftAnchor?.isActive = false
                          cell.profileButton.isHidden = true
                          
                      } else {
                          cell.bubble.backgroundColor = UIColor("#E8EBE4")
                          cell.textView.textColor = UIColor.black
                          cell.bubbleViewRightAnchor?.isActive = false
                          cell.bubbleViewLeftAnchor?.isActive = true
                          cell.imageView.isHidden = false
                          cell.textViewNama.isHidden = false
                          cell.timeTableRightAnchor?.isActive = false
                          cell.timeTableLeftAnchor?.isActive = true
                          cell.profileButton.isHidden = false
                      }
                }
        _ = Database.database().reference().child("users").child(message.uid!).observe(DataEventType.value) { (snapshot) in
                  if let postDict = snapshot.value as? [String:Any] {
                      let profileImage = postDict["profileImage"] as! String
                   self.profileURL = profileImage
                    cell.imageView.sd_setImage(with:URL(string: profileImage),placeholderImage:UIImage(named: "finalProfile"))
                }
            }
            
            cell.textView.text = message.text
            cell.bubbleWidth?.constant = self.estimateFrame(text: message.text!).width + 20
            cell.textViewNama.text = message.sender
            cell.timeLabel.text = message.time
            cell.timeLabel.font = UIFont.systemFont(ofSize: 9)
            cell.timeLabel.textColor =  UIColor.gray
            cell.contentView.isUserInteractionEnabled = false
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:  IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        if let text = messageArray[indexPath.row].text {
            height = estimateFrame(text: text).height + 20
        }
        return CGSize(width: view.frame.width, height:height)
   }
    
    private func estimateFrame(text: String)-> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    //MARK: - SEND BUTTON
    @objc func sendButtonPressed() {

        if inputTextField.text?.count != 0 {
            inputTextField.isEnabled = false

            let hour   = self.calendar.component(.hour,from: self.date)
            let minute = self.calendar.component(.minute, from: self.date)
            let day    = self.calendar.component(.day, from: self.date)
            let month  = self.calendar.component(.month, from: self.date)
              var time   = ""
              if hour < 10 && minute >= 10 {
                  time = "0\(hour).\(minute)"
              }
              if hour >= 10 && minute < 10 {
                  time = "\(hour).0\(minute)"
              }
              if hour >= 10 && minute >= 10 {
                  time = "\(hour).\(minute)"
              }
              if hour <= 10 && minute <= 10 {
                  time = "0\(hour).0\(minute)"
              }
            let userUID = Auth.auth().currentUser?.uid
            let ref = Database.database().reference().child(database)
            let childRef = ref.childByAutoId()
            let namaChildRef = childRef.key!
            let messageDirectory  = ["text": self.inputTextField.text!, "sender": namaUser , "time": time, "uid":userUID!, "day": day, "month": month, "childRef": namaChildRef] as [String : Any]
            childRef.updateChildValues(messageDirectory)
            
            inputTextField.text = ""
            inputTextField.isEnabled = true
            inputTextField.becomeFirstResponder()
          
        } else {
            return
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            sendButtonPressed()
        return true
    }
    

    func observeMessages() {
        let ref = Database.database().reference().child(database)
        ref.observe(.childAdded) { (snapshot) in
        let snapshotValue = snapshot.value as! Dictionary <String,Any>
        let childRef = snapshotValue["childRef"] ?? ""
            if self.someEntityExists(childQuery: childRef as! String) == false{
            let text = snapshotValue["text"] ?? ""
            let sender = snapshotValue["sender"] ?? ""
            let time = snapshotValue["time"] ?? ""
            let userUID = snapshotValue["uid"] ?? ""
            let month   = snapshotValue["month"] ?? 0
            let day     = snapshotValue["day"] ?? 0
           
            let messages = Chat(context: self.context )
                messages.text = text as? String
                messages.sender = sender as? String
                messages.time = time as? String
                messages.uid = userUID as? String
                messages.day = day as! Int16
                messages.month = month as! Int16
                messages.childRef = childRef as? String
            
            self.messageArray.append(messages)
            self.saveItems()
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
                
                DispatchQueue.main.async {
                    if self.namaUser != sender as! String {
                        if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
                            self.newNotificationButton.isHidden = true
                            self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                            self.floatingButton?.isHidden = true
                            self.scrollToBottom(animated: true)
                            print("dibawah")
                           // self.activityIndicator.stopAnimating()
                        } else if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height-40)) {
                            self.newNotificationButton.isHidden = true
                            self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                            self.floatingButton?.isHidden = true
                            self.scrollToBottom(animated: true)
                            print("keyboard kebuka")
                         //    self.activityIndicator.stopAnimating()
                        }else {
                            self.newNotificationButton.isHidden = false
                            self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                            self.floatingButton?.isHidden = true
                            print("di atas")
                         //    self.activityIndicator.stopAnimating()
                        }
                    } else {
                            print("keyboard beda orang, bawah")
                            self.newNotificationButton.isHidden = true
                            self.floatingButton?.isHidden = true
                            self.scrollToBottom(animated: false)
                          
                    }
                }
            } else {
                self.loadItems()
            }
        }
    }
    
    private func scrollToBottom(animated: Bool) {
        let section = (collectionView?.numberOfSections)! - 1
        let lastItemIndex = IndexPath(item: self.messageArray.count - 1, section: section)
        self.collectionView?.scrollToItem(at: lastItemIndex, at: .bottom, animated: animated)
   
    }

    @IBAction func navigationButton(_ sender: UIButton) {
        switch segueIndex {
        case 0:
            if collectionView?.frame.origin.y == -(keyboardHeight ?? 0)-40 {
                return
            } else {
                 self.performSegue(withIdentifier: segueIdentifier[segueIndex], sender: self)
            }
           
        case 1:
            self.performSegue(withIdentifier: segueIdentifier[segueIndex], sender: self)
        case 2:
            self.performSegue(withIdentifier: segueIdentifier[segueIndex], sender: self)
        case 3:
            self.performSegue(withIdentifier: segueIdentifier[segueIndex], sender: self)
        case 4:
            self.performSegue(withIdentifier: segueIdentifier[segueIndex], sender: self)
        case 5:
            self.performSegue(withIdentifier: segueIdentifier[segueIndex], sender: self)
        default:
            return
        }
    }
    
    
    // MARK: - INITIAL SETUP
    
    private func createFloatingButton() {
         floatingButton = UIButton(type: .custom)
         floatingButton?.translatesAutoresizingMaskIntoConstraints = false
         floatingButton?.backgroundColor = .white
         floatingButton?.setImage(UIImage(named: floatingButtonImageName), for: .normal)
         floatingButton?.addTarget(self, action: #selector(doThisWhenButtonIsTapped(_:)), for: .touchUpInside)
         constrainFloatingButtonToWindow()
         makeFloatingButtonRound()
         addShadowToFloatingButton()
         addScaleAnimationToFloatingButton()
         floatingButton?.alpha = 0.6
     }
    
    
      @IBAction private func doThisWhenButtonIsTapped(_ sender: Any) {
        scrollToBottom(animated: true)
      }

      private func constrainFloatingButtonToWindow() {
          DispatchQueue.main.async {
              guard let keyWindow = UIApplication.shared.keyWindow,
                  let floatingButton = self.floatingButton else { return }
              keyWindow.addSubview(floatingButton)
              keyWindow.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor,
                                                  constant: self.trailingValue-10).isActive = true
              keyWindow.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor,
                                                constant: self.leadingValue+60).isActive = true
              floatingButton.widthAnchor.constraint(equalToConstant:
                  DepressionViewController.buttonWidth).isActive = true
              floatingButton.heightAnchor.constraint(equalToConstant:
                  DepressionViewController.buttonHeight).isActive = true
          }
      }

      private func makeFloatingButtonRound() {
          floatingButton?.layer.cornerRadius = roundValue
      }

      private func addShadowToFloatingButton() {
          floatingButton?.layer.shadowColor = UIColor.black.cgColor
          floatingButton?.layer.shadowOffset = shadowOffset
          floatingButton?.layer.masksToBounds = false
          floatingButton?.layer.shadowRadius = shadowRadius
          floatingButton?.layer.shadowOpacity = shadowOpacity
      }
    
      private func addScaleAnimationToFloatingButton() {
          // Add a pulsing animation to draw attention to button:
          DispatchQueue.main.async {
              let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: self.animationKeyPath)
              scaleAnimation.duration = self.animationDuration
              scaleAnimation.repeatCount = .greatestFiniteMagnitude
              scaleAnimation.autoreverses = true
              scaleAnimation.fromValue = self.animateFromValue
              scaleAnimation.toValue = self.animateToValue
              self.floatingButton?.layer.add(scaleAnimation, forKey: self.scaleKeyPath)
          }
      }

        private func setupUI() {
          
            collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
            collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 40, right: 0)
            collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 40, right: 0)
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            // anchor constraint
            containerViewBottom = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            containerViewBottom?.isActive = true
            
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 65).isActive = true
            containerView.backgroundColor =  UIColor("#D52192")
            
            //Send Button
           
            let sendButton = UIButton()
            sendButton.setTitle("Send", for: .normal)
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            sendButton.addTarget(self, action: #selector(sendButtonPressed), for: .touchUpInside)
            sendButton.setTitleColor(UIColor.white, for: .normal)
            containerView.addSubview(sendButton)

            // sendButton Position
         
            sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            sendButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -6).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
            sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
         
            containerView.addSubview(inputTextField)
            inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12).isActive = true
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
            inputTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
            inputTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
            inputTextField.layer.cornerRadius = inputTextField.frame.height/2
            inputTextField.layer.cornerRadius = 8
            inputTextField.backgroundColor = UIColor.white
            inputTextField.autocorrectionType = .yes
            
            inputTextField.txtPaddingVw(txt: inputTextField)
       
            // separator line
            let separatorLine = UIView()
            separatorLine.backgroundColor = UIColor("#D52192")
            separatorLine.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(separatorLine)
            
            separatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            separatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            separatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            // notification Button
            newNotificationButton.translatesAutoresizingMaskIntoConstraints = false
            newNotificationButton.addTarget(self, action: #selector(newNotificationPressed), for: .touchUpInside)
            newNotificationButton.setTitleColor(UIColor.white, for: .normal)
            newNotificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            
            view.addSubview(newNotificationButton)
            
            newNotificationButton.alpha = 0.6
            newNotificationButton.contentHorizontalAlignment = .left
            newNotificationButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            newNotificationButton.isHidden = true
            
            newNotificationButton.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            newNotificationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            newNotificationButton.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            newNotificationButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            newNotificationButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            //Internet Snackbar
      
            snackbarInternet.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(snackbarInternet)
            
            // anchor constraint
            if #available(iOS 11.0, *)  {
                snackbarInternet.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                snackbarInternet.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            }
            snackbarInternet.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            snackbarInternet.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            snackbarInternet.heightAnchor.constraint(equalToConstant: 40).isActive = true
            snackbarInternet.backgroundColor =  UIColor.black
            snackbarInternet.alpha = 0.6
           
            internetTextView.translatesAutoresizingMaskIntoConstraints = false
            snackbarInternet.addSubview(internetTextView)
            internetTextView.textAlignment = .center
            internetTextView.leftAnchor.constraint(equalTo:snackbarInternet.leftAnchor).isActive = true
            internetTextView.heightAnchor.constraint(equalTo: snackbarInternet.heightAnchor).isActive = true
            internetTextView.widthAnchor.constraint(equalTo: snackbarInternet.widthAnchor).isActive = true
            internetTextView.topAnchor.constraint(equalTo: snackbarInternet.topAnchor).isActive = true
            internetTextView.textColor = UIColor.white
            internetTextView.backgroundColor = UIColor.clear
            internetTextView.font = .systemFont(ofSize: 14)
            internetTextView.text = "No Internet Connection"
            internetTextView.alpha = 0.9
        }
    
    @objc func newNotificationPressed() {
        newNotificationButton.isHidden = true
        scrollToBottom(animated: true)
    }
    
    // MARK: -PROTOCOL FUNCTION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "goToProfileImage" {
              if let nextViewController = segue.destination as? ProfileViewController {
                nextViewController.userUID = messageArray[profileIndexpath].uid!
                }
            }
        }
    func indexpath(indexpath: Int) {
        self.floatingButton?.isHidden = true
        profileIndexpath = indexpath
        self.performSegue(withIdentifier: "goToProfileImage", sender: self)
    }
    
//    func monthCalculator(month: Int) -> String {
//          var convertedMonth = ""
//
//          switch month {
//
//          case 1 :
//              convertedMonth = "Jan"
//          case 2 :
//              convertedMonth = "Feb"
//          case 3 :
//              convertedMonth = "Marc"
//          case 4 :
//              convertedMonth = "Apr"
//          case 5 :
//              convertedMonth = "May"
//          case 6 :
//              convertedMonth = "Jun"
//          case 7 :
//              convertedMonth = "Jul"
//          case 8 :
//              convertedMonth = "Aug"
//          case 9 :
//              convertedMonth = "Sept"
//          case 10 :
//              convertedMonth = "Oct"
//          case 11 :
//              convertedMonth = "Nov"
//          case 12 :
//              convertedMonth = "Des"
//
//          default:
//              convertedMonth = "\(month)"
//          }
//
//          return convertedMonth
//      }
    
//
    private func saveItems() {
        do {
        try context.save()
        } catch {
        print("error saving context \(error)")
        }
        self.collectionView.reloadData()
    }

    private func loadItems() {
        let request : NSFetchRequest<Chat> = Chat.fetchRequest()
        do {
            activityIndicator.stopAnimating()
            messageArray = try context.fetch(request)
        } catch {
        print("error fetching data \(error)")
        }
        collectionView.reloadData()
    }
    private func someEntityExists(childQuery: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Chat")
        fetchRequest.predicate = NSPredicate(format: " childRef = %s",  childQuery)
        var results: [NSManagedObject] = []
        do {
            results = try managedObjectContext!.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }

        return results.count > 0
    }
}



