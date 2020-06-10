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

class ChatViewController: UICollectionViewController, UITextFieldDelegate,UICollectionViewDelegateFlowLayout, profileButton{

    var profileIndexpath : Int?
    var segueIndex : Int?
    var database : String?
    var navigationTitle : String?
    let snackbar = TTGSnackbar(message:"Welcome to Depression Support Group.", duration: .middle)
    var popUp : Bool?
    private let cellID = "cellID"
    private var namaUser : String?
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
    private let roundValue = ChatViewController.buttonHeight/2
    private let newNotificationButton = UIButton()
    private let snackbarInternet = UIView()
    private let internetTextView = UITextView()
    private var profileURL : String?
    private var keyboardDuration = 0.0
    private var keyboardHeight : CGFloat?
    private var defaults = UserDefaults.standard
    private var internetBool = false
    private let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    private lazy var messageNama = defaults.object(forKey: "userName") as! String
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var navigationButton: UIButton!
    
    lazy var inputTextField : UITextField = {
        let TextField = UITextField()
        TextField.placeholder = "Chat as \(self.namaUser ?? "Human")"
        TextField.translatesAutoresizingMaskIntoConstraints = false
        TextField.delegate = self
        return TextField
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        floatingButton?.isHidden = true
        newNotificationButton.isHidden = true
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        print("kepanggil vdl")
        setupUI()
        observeMessages()
        setupKeyboardObservers()
        createFloatingButton()
        floatingButton?.isHidden = true
        navigationButton.contentHorizontalAlignment = .left
        let ref = Database.database().reference()
        let messageUsersCount = ref.child("users").child("registeredUsers").child(database ?? "")
            messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                if self.popUp != true {
                self.navigationButton.setTitle((self.navigationTitle ?? "")+" (\(snapshots.count))", for: .normal)
                 self.view.setNeedsDisplay()
               }else {
                  self.navigationButton.setTitle((self.navigationTitle ?? "")+" (\(snapshots.count+1))", for: .normal)
                  self.view.setNeedsDisplay()
               }
            }
        })
        
        snackbarInternet.alpha = 0
        internetTextView.alpha = 0

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleKeyboard))
        collectionView?.addGestureRecognizer(gestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(self.messageObserver), name: NSNotification.Name(rawValue: "message"), object: nil)
    }
    
    @objc func messageObserver() {
        observeMessages()
        connectedObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        connectedObserver()
    }
    
    fileprivate func connectedObserver() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
             connectedRef.observe(.value, with: { snapshot in
             if let connected = snapshot.value as? Bool, connected {
                   self.internetBool = true
                   let userUID   = Auth.auth().currentUser?.uid
                     _ = Database.database().reference().child("users").child(userUID ?? "").observe(DataEventType.value) { (snapshot) in
                         if let postDict = snapshot.value as? [String:Any] {
                             let username = postDict["username"] as! String
                             self.namaUser = username
                             self.inputTextField.isEnabled = true
                             self.inputTextField.placeholder = "Chat as \(self.namaUser ?? "Human")"
                       }
                   }
                   self.newNotificationButton.isHidden = true
                     UIView.animate(withDuration: 0.3) {
                         self.snackbarInternet.alpha = 0
                         self.internetTextView.alpha = 0
                   }
                   print("Connected")
             } else {
                 UIView.animate(withDuration: 0.3) {
                     self.snackbarInternet.alpha = 0.6
                     self.internetTextView.alpha = 0.9
                 }
                 self.inputTextField.isEnabled = false
                 self.internetBool = false
                 print("Not connected")
             }
         })
       self.newNotificationButton.backgroundColor = UIColor.black
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let ref = Database.database().reference().child(database ?? "")
        ref.removeAllObservers()
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.removeAllObservers()
        self.snackbar.dismiss()
            guard floatingButton?.superview != nil else {  return }
            DispatchQueue.main.async {
                self.floatingButton?.removeFromSuperview()
                self.floatingButton = nil
                self.inputTextField.resignFirstResponder()
                self.containerViewBottom?.constant = 0
                if self.internetBool == false {
                    self.snackbarInternet.isHidden = true
                    self.internetTextView.isHidden = true
            }
        }
    }
    //    let barButton = UIBarButtonItem(customView: activityIndicator)
    //    navigationItem.setRightBarButton(barButton, animated: true)
    //    activityIndicator.color = UIColor.white
    //    activityIndicator.startAnimating()
    override func viewWillDisappear(_ animated: Bool) {
        self.snackbar.dismiss()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
           if state == false{
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.065) {
                self.scrollToBottomAnimated(animated: false)
                self.state = true
                }
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
        navigationButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: self.keyboardDuration) {
            self.containerViewBottom?.constant = 0
            self.collectionView.frame.origin.y = 0
            self.inputTextField.resignFirstResponder()
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
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
                navigationButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded() }
            } else if collectionView.contentSize.height/2 > collectionView.frame.height/2 {
                self.keyboardDuration = keyboardDuration
                self.keyboardHeight   = keyboardHeight
                containerViewBottom?.constant  = -keyboardHeight
                collectionView?.frame.origin.y = -keyboardHeight-30
                UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded() }
            } else {
                UIView.animate(withDuration: keyboardDuration) {
                self.collectionView?.frame.origin.y = 0
                self.keyboardDuration = keyboardDuration
                self.containerViewBottom?.constant = -keyboardHeight
                self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    //MARK: - COLLECTION VIEW FUNCTION DELEGATES and DATASOURCES
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
                newNotificationButton.isHidden = true
            }else {
                floatingButton?.isHidden = false
            }
            cell.delegate = self
            cell.indexpath = indexPath.row
            cell.textView.text = message.text
            cell.bubbleWidth?.constant = self.estimateFrame(text: message.text!).width + 20
            cell.textViewNama.text = message.sender
            cell.timeLabel.text = message.time
            cell.contentView.isUserInteractionEnabled = false
            cell.imageView.layer.borderWidth = 1.5
            cell.imageView.layer.borderColor = UIColor.lightGray.cgColor
        
            let uid = self.defaults.value(forKey: "userUID") as? String ?? ""
            if message.uid  == Auth.auth().currentUser?.uid ?? uid    {
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
            Database.database().reference().child("users").child(message.uid ?? "").observe(DataEventType.value) { (snapshot) in
              if let postDict = snapshot.value as? [String:Any] {
                    let profileImage = postDict["profileImage"] as? String
                    self.profileURL = profileImage
                    cell.imageView.sd_setImage(with:URL(string: profileImage ?? ""),placeholderImage:UIImage(named: "loadingImage"))
            }
        }
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
    
    //MARK: - SEND BUTTON Function
    @objc func sendButtonPressed() {
        if internetBool == true {
            if inputTextField.text?.count != 0 {
               inputTextField.becomeFirstResponder()
               inputTextField.isEnabled = false
               let hour   = self.calendar.component(.hour,from: self.date)
               let minute = self.calendar.component(.minute, from: self.date)
               let day    = self.calendar.component(.day, from: self.date)
               let month  = self.calendar.component(.month, from: self.date)
                var time: String?
                 if hour < 10 && minute >= 10 {
                     time = "0\(hour).\(minute)"
                 } else if hour >= 10 && minute < 10 {
                     time = "\(hour).0\(minute)"
                 } else if hour >= 10 && minute >= 10 {
                     time = "\(hour).\(minute)"
                 } else if hour <= 10 && minute <= 10 {
                     time = "0\(hour).0\(minute)"
                 }
               let userUID = Auth.auth().currentUser?.uid
               let ref = Database.database().reference().child(database ?? "")
               let childRef = ref.childByAutoId()
               let namaChildRef = childRef.key!
               let messageDirectory  = ["text": self.inputTextField.text!, "sender": namaUser ?? messageNama , "time": time!, "uid":userUID!, "day": day, "month": month, "childRef": namaChildRef] as [String : Any]
               childRef.updateChildValues(messageDirectory)
               inputTextField.text = ""
               inputTextField.isEnabled = true
               inputTextField.becomeFirstResponder()
           } else {
               return
           }
        } else {
            return
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendButtonPressed()
        return true
    }
    
    private func observeMessages() {
        let ref = Database.database().reference().child(database ?? "")
        ref.observe(.value) { (snapshot) in
            if snapshot.hasChild(self.database ?? "") {
                self.isiObserver()
            } else {
               // self.activityIndicator.stopAnimating()
                self.isiObserver()
            }
        }
    }
    
    private func isiObserver() {
        if internetBool == true {
            return
        }else {
            print("kepanggil isi observer 1")
            let ref = Database.database().reference().child(database ?? "")
            ref.observe(.childAdded) { (snapshot) in
             let snapshotValue = snapshot.value as! Dictionary <String,Any>
             let childRef = snapshotValue["childRef"] ?? ""
                if self.someEntityExists(childQuery: childRef as? String ?? "") == false{
                 let text = snapshotValue["text"] ?? ""
                 let sender = snapshotValue["sender"] ?? ""
                 let time = snapshotValue["time"] ?? ""
                 let userUID = snapshotValue["uid"] ?? ""
                 let month   = snapshotValue["month"] ?? 0
                 let day     = snapshotValue["day"] ?? 0
                
                 let messages = Chat(context: self.context)
                     messages.text = text as? String
                     messages.sender = sender as? String
                     messages.time = time as? String
                     messages.uid = userUID as? String
                     messages.day = day as! Int16
                     messages.month = month as! Int16
                     messages.childRef = childRef as? String
                 self.messageArray.append(messages)
                 self.saveItems()
                     DispatchQueue.main.async {
                         self.collectionView.reloadData()
                         if self.namaUser != sender as? String {
                             if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
                                 self.newNotificationButton.isHidden = true
                                 self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                                 self.floatingButton?.isHidden = true
                                 self.scrollToBottomAnimated(animated: true)
                             } else if(self.collectionView.contentOffset.y >= (self.collectionView.contentSize.height - self.collectionView.frame.size.height-40)) {
                                 self.newNotificationButton.isHidden = true
                                 self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                                 self.floatingButton?.isHidden = true
                                 self.scrollToBottomAnimated(animated: true)
                             }else if Reachability.isConnectedToNetwork() == false{
                                self.newNotificationButton.isHidden = false
                                self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                                self.floatingButton?.isHidden = true
                                self.scrollToBottomAnimated(animated: false)
                             }else {
                                 self.newNotificationButton.isHidden = false
                                 self.newNotificationButton.setTitle("\(sender) : \(text)" , for: .normal)
                                 self.floatingButton?.isHidden = true
                               //  self.scrollToBottomAnimated(animated: false)
                             }
                            } else {
                                 self.newNotificationButton.isHidden = true
                                 self.floatingButton?.isHidden = true
                                 self.scrollToBottomAnimated(animated:false)
                         }
                     }
                 } else {
                     print("data ada")
                 }
             }
        }
    }

    
    @IBAction func hamburgerButton(_ sender: Any) {
        performSegue(withIdentifier: "goToChatSetting", sender: self)
        guard floatingButton?.superview != nil else {  return }
           DispatchQueue.main.async {
               self.floatingButton?.removeFromSuperview()
               self.floatingButton = nil
            }
    }

    @IBAction func navigationButton(_ sender: UIButton) {
        if collectionView?.frame.origin.y == -(keyboardHeight ?? 0)-40 {
            return
        } else {
             self.performSegue(withIdentifier: "goToPopDepression", sender: self)
        }
    }

    // MARK: - Creating button and initial setup
    func createFloatingButton() {
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
        scrollToBottomAnimated(animated: true)
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
                  ChatViewController.buttonWidth).isActive = true
              floatingButton.heightAnchor.constraint(equalToConstant:
                  ChatViewController.buttonHeight).isActive = true
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
    
    @objc func newNotificationPressed() {
        newNotificationButton.isHidden = true
        scrollToBottomAnimated(animated: true)
    }
    private func setupUI() {
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 65, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 30, left: 0, bottom: 65, right: 0)

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        //Container Anchor constraint
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

        //SendButton Position
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

    // MARK: -PROTOCOL FUNCTION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "goToProfileImage" {
              if let nextViewController = segue.destination as? ProfileViewController {
                nextViewController.userUID = messageArray[profileIndexpath ?? 0].uid!
            }
          }else if segue.identifier == "goToPopDepression" {
            if let nextViewController = segue.destination as? ChatPopUpViewController {
                nextViewController.indexpath = segueIndex ?? 0
            }
          }else if segue.identifier == "goToChatSetting" {
            if let nextViewController = segue.destination as? ChatSettingClass {
                    nextViewController.indexpath = segueIndex ?? 0
                }
            }
        }
    
    func indexpath(indexpath: Int) {
        floatingButton?.isHidden = true
        profileIndexpath = indexpath
        performSegue(withIdentifier: "goToProfileImage", sender: self)
    }
 
    fileprivate func scrollToBottomAnimated(animated: Bool) {
        let objectNumCollectionViewCell : ChatMessageCell = ChatMessageCell()
        guard self.collectionView.numberOfSections > 0 else{
            return
        }
        let items = self.collectionView.numberOfItems(inSection: 0)
        if items == 0 { return }

        let collectionViewContentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        let isContentTooSmall: Bool = (collectionViewContentHeight < self.collectionView.bounds.size.height)

        if isContentTooSmall {
            
            self.collectionView.scrollRectToVisible(CGRect(x: 0, y: collectionViewContentHeight - 1, width: 1, height: 1), animated: animated)
            return
        }
        objectNumCollectionViewCell.isHidden = false
        self.view.setNeedsDisplay()
        self.collectionView.scrollToItem(at: NSIndexPath(item: items - 1, section: 0) as IndexPath, at: .bottom, animated: animated)
    }

    fileprivate func saveItems() {
        do {
        try context.save()
        } catch {
        print("error saving context \(error)")
        }
        self.collectionView.reloadData()
    }

    fileprivate func loadItems() {
        let request : NSFetchRequest<Chat> = Chat.fetchRequest()
        do {
            //activityIndicator.stopAnimating()
            messageArray = try context.fetch(request)
        } catch {
        print("error fetching data \(error)")
        }
        collectionView.reloadData()
    }
    
    fileprivate func someEntityExists(childQuery: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Chat")
        fetchRequest.predicate = NSPredicate(format: " childRef = %s",  childQuery)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
}
