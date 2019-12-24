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
      
class ListTableViewController: UITableViewController {
    
    
    var ref : DatabaseReference!
    var indexpathBesar = 0
    var messageArray = [messageChat]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
          definesPresentationContext = true
        }
    
    let namaPenyakit = ["Depression", "Hyperactivity Disorder", "Bipolar Disorder", "Anxiety Disorder", "OCD Disorder", "Post Traumatic Stress" ]
    let namaDoktor = ["Dr. Andy", "Dr. Bianca", "Dr.Hermawan", "Dr. Agatha", "Dr. Aurel", "Dr. Stefan", "Dr. Puan"]
    let photoDockter : [UIImage] = [UIImage(named: "Depression.png")!, UIImage(named: "ADHD.png")!,UIImage(named: "Bipolar.png")!,UIImage(named: "Scizophrenia.png")!,UIImage(named: "OCD.png")!,UIImage(named: "PTSD.png")!, UIImage(named: "Bipolar.png")!]
    let childDatabase = ["Messages", "messages2", "messages3", "Messages4", "Messages5", "Messages6"]
    let navbarName = ["Depression Group", "Hyperactivity Group", "Bipolar Group", "Anxiety Group", "OCD Group", "PTSD Group"]
    var depression = ""
    var hyper      = ""
    var bipolar    = ""
    var anxiety    = ""
    var OCD        = ""
    var PTSD       = ""
    var mental     = ""
    let depressionSegue = "depressionSegue"
    var jumlahMember = 0
    private let date = Date()
    private let calendar = Calendar.current

    override func viewWillDisappear(_ animated: Bool) {
        let databaseRef = Database.database().reference()
        databaseRef.removeAllObservers()
    }
    override func viewWillAppear(_ animated: Bool) {
      
        if Auth.auth().currentUser != nil {
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
            
            let databaseRef = Database.database().reference()
            databaseRef.child(childDatabase[0]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                let messages = messageChat()
                messages.text = ""
                messages.time = ""
                messages.day  = 0
                messages.month = 0
                self.messageArray.insert(messages, at: 0)
                print("chat0")
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
                            self.messageArray.insert(messages, at: 0)
                        }
                    }
                })
            
            databaseRef.child(childDatabase[1]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                        let messages = messageChat()
                        messages.text = ""
                        messages.time = ""
                        messages.day  = 0
                        messages.month = 0
                   self.messageArray.insert(messages, at: 1)
                     print("chat1")
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
                            self.messageArray.insert(messages, at: 1)
                    }
                }
            })
            
            databaseRef.child(childDatabase[2]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                        let messages = messageChat()
                        messages.text = ""
                        messages.time = ""
                        messages.day  = 0
                        messages.month = 0
                     print("chat2")
                        self.messageArray.insert(messages, at: 2)
                        for snap in snapshot.children.allObjects as! [DataSnapshot] {
                        let value = snap.value as! [String: Any]
                            let message = value["text"]
                            let messages = messageChat()
                            messages.text = message  as? String
                            let time = value["time"]
                            messages.time = time as? String
                            let day = value["day"]
                            messages.day  = day  as? Int
                            let month = value["month"]
                            messages.month = month as? Int
                            self.messageArray.insert(messages, at: 2)
               
                    }
                })

            databaseRef.child(childDatabase[3]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                    let messages = messageChat()
                    messages.text = ""
                    messages.time = ""
                    messages.day  = 0
                    messages.month = 0
                print("chat3")
                    self.messageArray.insert(messages, at: 3)
               
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
                            self.messageArray.insert(messages, at: 3)

                         }
                    }
                })
                
            databaseRef.child(childDatabase[4]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                    let messages = messageChat()
                    messages.text = ""
                    messages.time = ""
                    messages.day  = 0
                    messages.month = 0
                       print("chat4")
                    self.messageArray.insert(messages, at: 4)
                               
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
                                self.messageArray.insert(messages, at: 4)
                
                         }
                    }
                })
            
            databaseRef.child(childDatabase[5]).queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                    let messages = messageChat()
                    messages.text = ""
                    messages.time = ""
                    messages.day  = 0
                    messages.month = 0
                    print("chat5")
                    self.messageArray.insert(messages, at: 5)
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
                                self.messageArray.insert(messages, at: 5)
                         }
                      }
                   })
        } else {
            return
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
            _ = Auth.auth().currentUser?.uid
            ref = Database.database().reference()
            let messageUsersCount = ref.child("users").child("registeredUsers").child(childDatabase[indexPath.row])
            messageUsersCount.observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                      cell.memberLabel.text = "(\(snapshots.count))"
                      self.jumlahMember = snapshots.count
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5) {
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
           }
        } else {
            
            cell.memberLabel.text  = ""
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "depressionSegue" {
        if let nextViewController = segue.destination as? DepressionViewController {
            nextViewController.database = childDatabase[indexpathBesar]
            nextViewController.segueIndex = indexpathBesar
            nextViewController.navigationTitle = "\(navbarName[indexpathBesar]) (\(self.jumlahMember))"
           }
       }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "present", sender: self)
        } else {
            let indexpath = indexPath.row
                switch indexpath {
                case 0:
                    if self.depression == "0" {
                        self.performSegue(withIdentifier: "goToPopDepression", sender: self)
                    }else {
                        indexpathBesar = indexpath
                        self.performSegue(withIdentifier: depressionSegue, sender: self)
                    }
                case 1:
                    if self.hyper == "0" {
                         self.performSegue(withIdentifier: "goToPopHyper", sender: self)
                     } else {
                          indexpathBesar = indexpath
                          self.performSegue(withIdentifier: depressionSegue, sender: self)
                    }
                case 2:
                    if self.bipolar == "0" {
                        self.performSegue(withIdentifier: "goToPopBipolar", sender: self)
                    } else {
                       indexpathBesar = indexpath
                        self.performSegue(withIdentifier: depressionSegue, sender: self)
                  }
                case 3:
                    if self.anxiety == "0" {
                       self.performSegue(withIdentifier: "goToPopAnxiety", sender: self)
                   } else {
                      indexpathBesar = indexpath
                      self.performSegue(withIdentifier: depressionSegue, sender: self)
                   }
                case 4:
                    if self.OCD == "0" {
                        self.performSegue(withIdentifier: "goToPopOCD", sender: self)
                   } else {
                        indexpathBesar = indexpath
                        self.performSegue(withIdentifier: depressionSegue, sender: self)
                   }
                case 5:
                    if self.PTSD == "0" {
                      self.performSegue(withIdentifier: "goToPopPTSD", sender: self)
                  } else {
                     indexpathBesar = indexpath
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
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action =  UIContextualAction(style: .destructive, title: "Clear", handler: { (action,view,completionHandler ) in
            let alert = UIAlertController(title: "", message: "Are you sure want to clear this chat?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { (UIAlertAction) in
                self.remove(child: self.childDatabase[indexPath.row])
                tableView.reloadData()
            })
            let no = UIAlertAction(title: "No", style: .destructive, handler: { (UIAlertAction) in
                tableView.reloadData()
            })
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        })
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func remove(child: String) {
        let ref = self.ref.child(child)
        ref.removeValue { error, _ in
            print("error removing chat \(String(describing: error))")
        }
    }
}
