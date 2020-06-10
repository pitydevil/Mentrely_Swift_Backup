//
//  CustomDiaryViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 29/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import TTGSnackbar

class CustomDiaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, reminderTapped, reminderTulisan {
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var undoneLabel: UILabel!
    @IBOutlet weak var doneCardCounter: UILabel!
    @IBOutlet weak var nextWeekCard: UIView!
    @IBOutlet weak var doneCard: UIView!
    
//MARK: -DEFINING LET AND VARIABLE
    //Core Data Array and Context
    fileprivate var reminderArray = [Reminder]()
    private var pinnedChat : String?
    fileprivate let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    fileprivate var pinIndex : Int?
    //Defining Objects from native module
    fileprivate let defaults = UserDefaults.standard
    fileprivate let date = Date()
    fileprivate let calendar = Calendar.current
    fileprivate var textField = UITextField()
    fileprivate var condition : Int?
    lazy var conditionInt = defaults.integer(forKey: "intCondition")
  
    //Status Bar appearance
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textInitializer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates and Datasources
        textField.delegate   = self
        searchBar.delegate   = self
        tableView.delegate   = self
        tableView.dataSource = self
                
        // Setting up SearchBar backgroundImage and backgroundColor
        searchBar.backgroundImage = UIImage()
        if #available(iOS 13, *) {
            searchBar.searchTextField.backgroundColor = UIColor.white
        }else {
            searchBar.backgroundColor = UIColor.white
        }
        
        if conditionInt == 1 {
            doneCard.backgroundColor     = UIColor("#FF6E00")
        }else if conditionInt == 2 {
            nextWeekCard.backgroundColor = UIColor("#FF6E00")
        }
        // Setting up This Next Week Card reminder Layer
        nextWeekCard.reminderLayer()
        
        // Setting up Done Card reminder Later
        doneCard.reminderLayer()
        
        // Load ReminderArray based on condition from CoreData
        loadItems(condition: conditionInt)
        
        // Calculate and setting up doneCounter,undoneCounter, and today's date
        textInitializer()
        
        // UITapGestureRecognizer for resigning searchbar etc
        let tapped = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        tapped.cancelsTouchesInView = false
        view.addGestureRecognizer(tapped)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for data in reminderArray {
            if data.isPinned == true {
                pinnedChat = data.daily
                break
            }
        }
    }
    
    //Calculate and setting up doneCounter,undoneCounter, and today's date
    fileprivate func textInitializer() {
        let jumlahDone = defaults.integer(forKey: "dataDone")
        doneCardCounter.text = "\(jumlahDone)"
        
        let jumlahUndone = reminderArray.count - jumlahDone
        undoneLabel.text = "\(jumlahUndone)"
    
        tableView.reloadData()
    }
    
    //UITapGestureRecognizer function for dismissing keyboard
    @objc func handleTapped(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: - Table View Datasource and Delegate Function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderArray.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomReminderCell", for: indexPath) as! CustomReminderTableViewCell
            let reminder = reminderArray[indexPath.row]
        cell.tulisanDelegate = self
        cell.tappedDelegate = self
        cell.reminderTextfield.text = reminder.daily
        
        if reminder.isPinned == true {
            self.pinIndex = indexPath.row
            cell.pinnedImage.image = UIImage(named: "pin")!
        }else {
             cell.pinnedImage.image = nil
        }
        
        // Showing and hiding accessory type based on done property
        if reminder.done == true {
            cell.checkButton.setImage(UIImage(named: "Filled")!, for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(named: "Not Filled")!, for: .normal)
        }
        return cell
    }

    //MARK: -TABLEVIEW EDITING STYLE FUNCTION DELEGATE
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Reordering tableViewCell
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = reminderArray[sourceIndexPath.row]
        let newItem = Reminder(context:context)
        newItem.daily = item.daily!
        newItem.done = item.done
        context.delete(item)
        if Auth.auth().currentUser != nil {
              newItem.username = Auth.auth().currentUser!.uid
          } else {
              newItem.username = "Guest"
        }
        let date = Date()
        newItem.dateCreated = date
        reminderArray.remove(at: sourceIndexPath.row)
        reminderArray.insert(newItem, at: destinationIndexPath.row)
        self.saveItems()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
           var pin : UITableViewRowAction?
           let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            //Saving and Changing tableViewCell accessory type based on done property.
            if self.reminderArray[indexPath.row].done == true {
              
                 let alert = UIAlertController(title: "", message: "Are you sure want to delete this reminder?", preferredStyle: .alert)
                 let yes = UIAlertAction(title: "Delete", style: .destructive, handler: { (uialertaction) in
                     var jumlahDataDone = self.defaults.integer(forKey: "dataDone")
                     self.context.delete(self.reminderArray[indexPath.row])
                     self.saveItems()
                     self.reminderArray.remove(at: indexPath.row)
                     tableView.deleteRows(at: [indexPath], with: .left)
                     jumlahDataDone = jumlahDataDone - 1
                     self.defaults.set(jumlahDataDone, forKey: "dataDone")
                     //Function for hiding/showing editButton based on reminderArray count
                     self.textInitializer()
                 })
                 let no = UIAlertAction(title: "Cancel", style: .cancel) { (uialertaction) in
                     return
                 }
                 alert.addAction(yes)
                 alert.addAction(no)
                 self.present(alert, animated: true, completion: nil)
             } else {
                 //Alert for deleting Reminder
                 let alert = UIAlertController(title: "", message: "Are you sure want to delete this Reminder?", preferredStyle: .alert)
                 let Yes = UIAlertAction(title: "Delete", style: .destructive) { (uialertaction) in
                     self.context.delete(self.reminderArray[indexPath.row])
                     self.reminderArray.remove(at: indexPath.row)
                     tableView.deleteRows(at: [indexPath], with: .left)
                     self.saveItems()
                     //Function for hiding/showing editButton based on reminderArray count
                     self.viewWillAppear(true)
                 }
                 let No = UIAlertAction(title: "Cancel", style: .cancel) { (uialertaction) in
                     return
                 }
                 alert.addAction(Yes)
                 alert.addAction(No)
                 
                 self.present(alert, animated: true, completion: nil)
                }
            }
        if pinnedChat == self.reminderArray[indexPath.row].daily && pinIndex == indexPath.row && pinnedChat != nil {
             pin = UITableViewRowAction(style: .default, title: "Unpin", handler: { (action, indexpath) in
                self.pinnedChat = nil
                self.reminderArray[indexPath.row].isPinned = false
                self.pinIndex = nil
                self.saveItems()
                self.tableView.reloadData()
   
            })
        }else if pinnedChat == nil {
            pin = UITableViewRowAction(style: .default, title: "Pin", handler: { (action, indexpath) in
                self.pinnedChat = self.reminderArray[indexPath.row].daily
                self.reminderArray[indexPath.row].isPinned = true
                self.pinIndex = indexPath.row
                self.tableView.reloadData()
                self.saveItems()
            })

        }else if pinnedChat != nil && pinnedChat != self.reminderArray[indexPath.row].daily && pinIndex != indexPath.row{
            pin = UITableViewRowAction(style: .default, title: "Pin", handler: { (action, indexpath) in
                let alert = UIAlertController(title: "", message: "Are you sure want to change the pinned item?", preferredStyle: .alert)
                let Okay = UIAlertAction(title: "Confirm", style: .cancel) { (UIAlertAction) in
                    self.pinnedChat = self.reminderArray[indexPath.row].daily
                    self.reminderArray[self.pinIndex!].isPinned = false
                    self.reminderArray[indexPath.row].isPinned = true
                    self.pinIndex = indexPath.row
                    self.tableView.reloadData()
                    self.saveItems()
                }
                let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (UIAlertAction) in
                    return
                }
                alert.addAction(Okay)
                alert.addAction(cancel)
                
                self.present(alert, animated: true, completion: nil)
            })
        }else if pinnedChat != nil && pinnedChat == self.reminderArray[indexPath.row].daily && pinIndex != indexPath.row{
            pin = UITableViewRowAction(style: .default, title: "Pin", handler: { (action, indexpath) in
               let alert = UIAlertController(title: "", message: "Are you sure want to change the pinned item?", preferredStyle: .alert)
               let Okay = UIAlertAction(title: "Confirm", style: .cancel) { (UIAlertAction) in
                   self.pinnedChat = self.reminderArray[indexPath.row].daily
                   self.reminderArray[self.pinIndex!].isPinned = false
                   self.reminderArray[indexPath.row].isPinned = true
                   self.pinIndex = indexPath.row
                   self.tableView.reloadData()
                   self.saveItems()
               }
               let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (UIAlertAction) in
                   return
               }
               alert.addAction(Okay)
               alert.addAction(cancel)
               
               self.present(alert, animated: true, completion: nil)
           })
        }
        
        delete.backgroundColor = UIColor.red
        pin?.backgroundColor = UIColor("#FF9300")
           return [delete, pin!]
       }
    
    //Changing tableView isEditing State
    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
    //Button for adding reminder
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        let reminder = UIAlertController(title: "Add New Reminder", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: " Add Reminder ", style: .default, handler: { (UIAlertAction) in _ = UITextField()
            //Adding reminder to the textfield
            if self.textField.text!.count != 0 {
                //Building new Reminder Object for reminder, and saving it to the coredata
                let newItem = Reminder(context: self.context )
                newItem.daily = self.textField.text!
                newItem.done = false
                newItem.isPinned = false
                if Auth.auth().currentUser != nil {
                    newItem.username = Auth.auth().currentUser!.uid
                } else {
                    newItem.username = "Guest"
                }
                let date = Date()
                newItem.dateCreated = date
                self.reminderArray.append(newItem)
                self.saveItems()
                let conditionInteger = self.defaults.integer(forKey: "intCondition")
                self.loadItems(condition: conditionInteger)
                self.textInitializer()
            } else {
                //Alert if UITextField in UIAlertAction is empty.
                let alert  = UIAlertController(title: "Reminder Field is Empty", message: nil, preferredStyle: .alert)
                let cancel = UIKit.UIAlertAction(title: "Dismiss", style: .destructive) { (UIAlertAction) in
                     self.present(reminder, animated: true, completion: nil)
                }
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                }
            })
            //UITextField di UIAlert
                reminder.addTextField { (alertTextField) in
                alertTextField.delegate      = self
                alertTextField.placeholder   = "Reminder"
                alertTextField.keyboardType  = .alphabet
                alertTextField.returnKeyType = .done
                alertTextField.autocorrectionType = .yes
                alertTextField.autocapitalizationType = .sentences
                self.textField = alertTextField
            }

            let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (UIAlertAction) in
                return
            }
            reminder.addAction(action)
            reminder.addAction(cancel)
     
        self.present(reminder, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.textField {
            guard let textFieldText = textField.text,
               let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                   return false
           }
           let substringToReplace = textFieldText[rangeOfTextToReplace]
           let count = textFieldText.count - substringToReplace.count + string.count
            
           return count <= 35
        }else {
            return true
        }
    }
    
    //MARK: -Function for saving/loading CoreData
    fileprivate func saveItems() {
        do {
            try context.save()
        } catch {
            fatalError("Error saving data from context to CoreData \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
    
    //Function For Loading Coredata into reminderArray
    fileprivate func loadItems(condition : Int) {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        let predicate : NSPredicate?
        // Query Reminder based on the Internet and User conditions
         if Auth.auth().currentUser != nil {
             if Reachability.isConnectedToNetwork() == true {
                predicate = NSPredicate(format: "username CONTAINS[CD] %@", Auth.auth().currentUser!.uid)
             }else {
                let UID = defaults.value(forKey: "userUID") as? String
                predicate = NSPredicate(format: "username CONTAINS[CD] %@", UID ?? "")
             }
         }else {
            predicate = NSPredicate(format: "username CONTAINS[CD] %@", "Guest")
         }
            request.predicate = predicate
        
            let sortDescriptor : NSSortDescriptor?
            if condition == 1 {
                sortDescriptor = NSSortDescriptor(key: "done", ascending: false)
            }else {
                sortDescriptor = NSSortDescriptor(key: "done", ascending: true)
            }
            request.sortDescriptors = [(sortDescriptor ?? NSSortDescriptor(key: "dateCreated", ascending: true))]
            do {
                reminderArray = try context.fetch(request)
            } catch {
                print("error fetching data \(error)")
            }
         tableView.reloadData()
    }
  
    @IBAction func doneReminderPressed(_ sender: Any) {
        loadItems(condition: 1)
        defaults.set(1, forKey: "intCondition")
        UIView.animate(withDuration: 0.175) {
            self.nextWeekCard.backgroundColor = UIColor("#FF9300")
        
            self.doneCard.backgroundColor = UIColor("#FF6E00")
        }
    }
    
    @IBAction func notDoneReminderPressed(_ sender: Any) {
        loadItems(condition: 2)
        defaults.set(2, forKey: "intCondition")
        UIView.animate(withDuration: 0.175) {

            self.doneCard.backgroundColor = UIColor("#FF9300")
            self.nextWeekCard.backgroundColor = UIColor("#FF6E00")
        }
    }
    
     func indexpathShifter(Cell: CustomReminderTableViewCell) {
         let indexPath   = self.tableView.indexPath(for: Cell)
         let index       = indexPath?.row ?? 0
         var doneCounter = defaults.integer(forKey: "dataDone")
         let reminder    = reminderArray[index]
         if reminder.done == true {
             reminder.done = false
             doneCounter   = doneCounter - 1
             defaults.set(doneCounter, forKey: "dataDone")
             saveItems()
             textInitializer()
             loadItems(condition: conditionInt)
        } else {
              reminder.done = true
              doneCounter   = doneCounter + 1
              defaults.set(doneCounter, forKey: "dataDone")
              saveItems()
              textInitializer()
              loadItems(condition: conditionInt)
         }
     }
     
     func endText(Tulisan: String, Cell: CustomReminderTableViewCell) {
         let indexPath = self.tableView.indexPath(for: Cell)
         let index = indexPath?.row ?? 0
         if reminderArray[index].isPinned == true {
             defaults.set(Tulisan, forKey: "pinnedChat")
         }
         reminderArray[index].daily = Tulisan
         saveItems()
     }

}

extension CustomDiaryViewController: UISearchBarDelegate {
    //SearchBar Delegate Function
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Reminder> = Reminder.fetchRequest()
        var predicate : NSPredicate?

            if Auth.auth().currentUser != nil {
                if Reachability.isConnectedToNetwork() == true {
                    predicate = NSPredicate(format: "daily CONTAINS[CD] %@ && username CONTAINS[CD] %@", searchBar.text!, Auth.auth().currentUser!.uid)
                }else {
                    let UID = defaults.value(forKey: "userUID") as? String
                    predicate = NSPredicate(format: "daily CONTAINS[CD] %@ && username CONTAINS[CD] %@", searchBar.text!, UID ?? "")
                }
            } else {
                predicate = NSPredicate(format: "daily CONTAINS[CD] %@ && username CONTAINS[CD] %@",  searchBar.text!, "Guest")
            }
            request.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "daily", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            do {
                self.reminderArray = try context.fetch(request)
            } catch {
                print("Error Finding the data \(error.localizedDescription)")
            }
        searchBar.sizeToFit()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            let conditionInt = defaults.integer(forKey: "intCondition")
            loadItems(condition: conditionInt)
        }
    }
}
