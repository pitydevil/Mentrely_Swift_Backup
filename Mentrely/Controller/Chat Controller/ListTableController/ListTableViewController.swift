//
//  ListTableViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
      
class ListTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    var viewController : UIViewController?
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

         // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
             // Create a destination view controller and set its properties.
        guard let nextViewController = storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return nil }

        nextViewController.database = childDatabase[indexPath.row]
        nextViewController.segueIndex = indexPath.row
        nextViewController.navigationTitle = "\(navbarName[indexPath.row])"
        indexpathBesar = indexPath.row
             /*
                 Set the height of the preview by setting the preferred content size of the destination view controller. Height: 0.0 to get default height
             */
         nextViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)

         previewingContext.sourceRect = cell.frame
        
        if Auth.auth().currentUser != nil {
            switch indexPath.row {
              case 0:
                  if self.depression != "0"  {
                    return nextViewController
                  }
              case 1:
                  if self.hyper != "0" {
                     return nextViewController
                  }
              case 2:
                  if self.bipolar != "0" {
                     return nextViewController
                  }
              case 3:
                  if self.anxiety != "0" {
                     return nextViewController
                 }
              case 4:
                  if self.OCD != "0" {
                      return nextViewController
                 }
              case 5:
                  if self.PTSD != "0" {
                     return nextViewController
                }
               default:
                 return nil
           }
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        performSegue(withIdentifier: "depressionSegue", sender: self)
    }
    
    
    private let defaults = UserDefaults.standard
    private let date = Date()
    private let calendar = Calendar.current
    private let namaPenyakit = ["Depression", "Hyperactivity Disorder", "Bipolar Disorder", "Anxiety Disorder", "OCD Disorder", "Post Traumatic Stress" ]
    private let namaDoktor = ["Dr. Andy", "Dr. Bianca", "Dr.Hermawan", "Dr. Agatha", "Dr. Aurel", "Dr. Stefan", "Dr. Puan"]
    private let photoDockter : [UIImage] = [UIImage(named: "Depression.png")!, UIImage(named: "ADHD.png")!,UIImage(named: "Bipolar.png")!,UIImage(named: "Scizophrenia.png")!,UIImage(named: "OCD.png")!,UIImage(named: "PTSD.png")!, UIImage(named: "Bipolar.png")!]
    private let childDatabase = ["Messages", "messages2", "messages3", "Messages4", "Messages5", "Messages6"]
    private let navbarName = ["Depression Group", "Hyperactivity Group", "Bipolar Group", "Anxiety Group", "OCD Group", "PTSD Group"]
    
    private let depressionSegue = "depressionSegue"
    private var depression = ""
    private var hyper      = ""
    private var bipolar    = ""
    private var anxiety    = ""
    private var OCD        = ""
    private var PTSD       = ""
    private var mental     = ""
    private var ref : DatabaseReference!
    private var indexpathBesar = 0
    private var messageArray   = [messageChat]()
    private var timerFetch     = 0
    var setting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForPreviewing(with: self, sourceView: tableView)
        tableView.separatorStyle = .none
        definesPresentationContext = true
        navigationItem.largeTitleDisplayMode = .always
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginChangedFunction), name: NSNotification.Name(rawValue: "loginChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.firstTime), name: NSNotification.Name(rawValue: "firstTime"), object: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)
    }
  
    @objc func firstTime() {
        setting = true
    }
    @objc func loginChangedFunction() {
        lastMessageObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            lastMessageObserver()
        }else {
            messageArray.removeAll()
            tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
         let ref = Database.database().reference()
        ref.removeAllObservers()
    }
    
    public func lastMessageObserver() {
        let userUID   = Auth.auth().currentUser?.uid
          let ref = Database.database().reference().child("users").child(userUID!)
          ref.observe(DataEventType.value) { (snapshot) in
              if let snapshotValue = snapshot.value as? [String:String] {
                  let selectedMental = snapshotValue["mental"]
                  self.mental        = selectedMental!
                  let selectedHyper  = snapshotValue["HyperRoom"]
                  self.hyper         = selectedHyper!
                  let bipolarRoom    = snapshotValue["BipolarRoom"]
                  self.bipolar       = bipolarRoom!
                  let anxietyRoom    = snapshotValue["AnxietyRoom"]
                  self.anxiety       = anxietyRoom!
                  let ocdRoom = snapshotValue["OCDRoom"]
                  self.OCD           = ocdRoom!
                  let ptsdRoom = snapshotValue["PTSDRoom"]
                  self.PTSD          = ptsdRoom!
                  let depressionRoom = snapshotValue["DepressionRoom"]
                  self.depression    = depressionRoom!
                  self.tableView.reloadData()
              }
          }
        for index in stride(from: 0, to: 6, by: 1){
            let messages = messageChat()
                     messages.text = ""
                     messages.time = ""
                     messages.day  = 0
                     messages.month = 0
                  //  print("child kosong \(index)")
                    self.messageArray.insert(messages, at: index)
                let ref = Database.database().reference()
                ref.child(childDatabase[index]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
                         let value = snap.value as? [String: Any] ?? [:]
                         if let message = value["text"] as? String {
                            let messages = messageChat()
                            messages.text = message
                            let time = value["time"]
                            messages.time = time as? String
                            let day = value["day"]
                            messages.day  = day  as? Int
                            let month = value["month"]
                            messages.month = month as? Int
                            self.messageArray.insert(messages, at: index)
                          //    print("child \(index)")
                    }
                }
            })
         }
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namaPenyakit.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListTableViewCell
        
        cell.namaPenyakit.text = namaPenyakit[indexPath.row]
        cell.namaDoktor.text = namaDoktor[indexPath.row]
        cell.imageDoctornya.image = photoDockter[indexPath.row]
        cell.chatCounter.isHidden = true
        if Auth.auth().currentUser != nil {
            cell.lastChatLabel.isHidden = false
            cell.previewChatLabel.isHidden = false
            _ = Auth.auth().currentUser?.uid
            ref = Database.database().reference()
            let messageUsersCount = ref.child("users").child("registeredUsers").child(childDatabase[indexPath.row])
            messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                      cell.memberLabel.text = "(\(snapshots.count))"
                }
            })

                cell.previewChatLabel.text = self.messageArray[indexPath.row].text
                cell.lastChatLabel.textColor = UIColor.white
                let day = self.calendar.component(.day, from: self.date)
                    if self.messageArray[indexPath.row].day == day{
                        cell.lastChatLabel.text = self.messageArray[indexPath.row].time
                    } else if self.messageArray[indexPath.row].day == 0 {
                        cell.lastChatLabel.isHidden = true
                    }  else if (self.messageArray[indexPath.row].day!) == day-1 {
                        cell.lastChatLabel.text = "Yesterday"
                    } else {
                        cell.lastChatLabel.text = "\(String(describing: self.messageArray[indexPath.row].day!))/\(String(describing: self.messageArray[indexPath.row].month!))"
                    }

        }else {
            cell.lastChatLabel.isHidden = true
            cell.previewChatLabel.isHidden = true
            cell.memberLabel.isHidden = true
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == depressionSegue {
        if let nextViewController = segue.destination as? ChatViewController {
            nextViewController.database = childDatabase[indexpathBesar]
            nextViewController.segueIndex = indexpathBesar
            nextViewController.navigationTitle = "\(navbarName[indexpathBesar])"
            if self.setting == true {
                nextViewController.snackbar.animationType = .slideFromTopBackToTop
                nextViewController.popUp = true
                nextViewController.snackbar.animationDuration    = 1.5
                nextViewController.snackbar.topMargin            = 50
                nextViewController.snackbar.shouldDismissOnSwipe = true
                nextViewController.snackbar.cornerRadius         = 5
                nextViewController.snackbar.show()
                print("called")
            }
            self.setting = false
        }
     } else if segue.identifier == "goToPopDepression" {
        if let nextViewController =  segue.destination as? ChatPopUpViewController {
            nextViewController.indexpath = indexpathBesar
            print("index = \(indexpathBesar)")
            }
        }else if segue.identifier == "goToLogin" {
            if let nextViewController =  segue.destination as? LoginViewController {
                nextViewController.condition = 2
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "goToLogin", sender: self)
        } else {
            let indexpath = indexPath.row
                switch indexpath {
                case 0:
                    indexpathBesar = indexpath
                    if self.depression == "0"  {
                     
                        self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                    }else {
                        
                        self.performSegue(withIdentifier: depressionSegue, sender: self)
                    }
                case 1:
                    indexpathBesar = indexpath
                    if self.hyper == "0" {
                          self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                     } else {
                          
                          self.performSegue(withIdentifier: depressionSegue, sender: self)
                    }
                case 2:
                    indexpathBesar = indexpath
                    if self.bipolar == "0" {
                        self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                    } else {
                        self.performSegue(withIdentifier: depressionSegue, sender: self)
                    }
                case 3:
                    indexpathBesar = indexpath
                    if self.anxiety == "0" {
                        self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                   } else {
                    
                      self.performSegue(withIdentifier: depressionSegue, sender: self)
                   }
                case 4:
                    indexpathBesar = indexpath
                    if self.OCD == "0" {
                         self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                   } else {
                      
                        self.performSegue(withIdentifier: depressionSegue, sender: self)
                   }
                case 5:
                    indexpathBesar = indexpath
                    if self.PTSD == "0" {
                        self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                  } else {
        
                     self.performSegue(withIdentifier: depressionSegue, sender: self)
                  }
                default:
                    return
                }
            }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
          let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
              let alert = UIAlertController(title: "", message: "Are you sure want to delete this Chat?", preferredStyle: .alert
              )
              let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
              let Delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
                   self.remove(child: self.childDatabase[indexPath.row])
                   tableView.reloadData()
              }
              alert.addAction(cancel)
              alert.addAction(Delete)
              self.present(alert, animated: true, completion: nil)
          }
          delete.backgroundColor = UIColor.red
          return [delete]
    }
        
    private func remove(child: String) {
        let ref = self.ref.child(child)
        ref.removeValue { error, _ in
            print("error removing chat \(String(describing: error))")
        }
    }
}
