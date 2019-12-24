//
//  CustomDiaryViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 29/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import RealmSwift

class CustomDiaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remindersCOUNT: UILabel!
    @IBOutlet weak var undoneLabel: UILabel!
    @IBOutlet weak var todayCard: UIView!
    @IBOutlet weak var thisWeekCard: UIView!
    @IBOutlet weak var nextWeekCard: UIView!
    @IBOutlet weak var doneCard: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var doneCardCounter: UILabel!
    @IBOutlet weak var myReminderLabel: UIView!
 
    
    let realm = try! Realm()
    let defaults = UserDefaults.standard
    let date = Date()
    let calendar = Calendar.current
    var reminderRealm : Results<reminder>?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate   = self
        tableView.delegate   = self
        tableView.dataSource = self
        myReminderLabel.layer.borderWidth = 1.5
        myReminderLabel.layer.borderColor = UIColor.purple.cgColor
  
        if #available(iOS 13, *) {
            searchBar.searchTextField.backgroundColor = UIColor.white
        }else {
            searchBar.backgroundColor = UIColor.white
        }
  
        // Today Card
        todayCard.reminderLayer()
        
        // This Week Card
        thisWeekCard.reminderLayer()
        
        // Next Week Card
        nextWeekCard.reminderLayer()
        
        // Done Card
        doneCard.reminderLayer()
        
        loadItems()
        textInitializer()
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        tapped.cancelsTouchesInView = false
        view.addGestureRecognizer(tapped)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }
       
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        textInitializer()
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.reloadData()
    }

    private func textInitializer() {
        
        let jumlahDone = defaults.integer(forKey: "dataDone")
        doneCardCounter.text = "\(jumlahDone)"
        let jumlahUndone = reminderRealm!.count - jumlahDone
        undoneLabel.text = "\(jumlahUndone)"
        
        let day  =  calendar.component(.day,from: date)
        let month = calendar.component(.month, from: date)
        let year  = calendar.component(.year, from: date)
        todayDate.text = "\(day) - \(month) - \(year)"
        remindersCOUNT.text = "\(reminderRealm!.count)"
    }
    
    
    @objc func handleTapped(gesture: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = reminderRealm?[sourceIndexPath.row]

        let data = reminder()
        data.daily = item!.daily
        data.date  = Date()
        self.saveItems(reminder: data)
        self.viewWillAppear(true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderRealm?.count ?? 1
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! customReminderTableViewCell
        
        cell.tintColor = UIColor.green
        cell.namaReminder.text = reminderRealm?[indexPath.row].daily
       
        if reminderRealm?[indexPath.row].done == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var defaults2 = defaults.integer(forKey: "dataDone")
        
        do {
            try realm.write {
              if reminderRealm?[indexPath.row].done == true {
                reminderRealm?[indexPath.row].done = false
                defaults2 = defaults2 - 1
                defaults.set(defaults2, forKey: "dataDone")
                viewWillAppear(true)
                    } else {
                reminderRealm?[indexPath.row].done = true
                defaults2 = defaults2 + 1
                defaults.set(defaults2, forKey: "dataDone")
                viewWillAppear(true)
                    }
                 }
             }catch{
                print("error saving checkmark \(error)")
             }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        }
        tableView.reloadData()
       
    }
    
   
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action =  UIContextualAction(style: .normal, title: "Delete", handler: { (action,view,completionHandler ) in
            if self.reminderRealm?[indexPath.row].done == true {
                let alert = UIAlertController(title: "Delete Item?", message: "", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes", style: .default, handler: { (uialertaction) in
                    self.deleteItems(indexPath: indexPath)
                       tableView.deleteRows(at: [indexPath], with: .automatic)
                       var defaults2 = self.defaults.integer(forKey: "dataDone")
                       defaults2 = defaults2 - 1
                       self.defaults.set(defaults2, forKey: "dataDone")
                       self.viewWillAppear(true)
                       completionHandler(true)
                })
                let no = UIAlertAction(title: "No", style: .destructive) { (uialertaction) in
                    tableView.reloadData()
                    return
                }
             //   let no = UIAlertAction(title: "No", style: .destructive, handler: nil)
                alert.addAction(yes)
                alert.addAction(no)
                
                self.present(alert, animated: true, completion: nil)
   
            } else {
                
                let alert = UIAlertController(title: "Delete Item?", message: "", preferredStyle: .alert)
                let yes = UIAlertAction(title: "Yes", style: .default) { (uialertaction) in
                        self.deleteItems(indexPath: indexPath)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.viewWillAppear(true)
                        completionHandler(true)
                }
                
                let no = UIAlertAction(title: "No", style: .destructive) { (uialertaction) in
                               tableView.reloadData()
                    return
                }
                
                alert.addAction(yes)
                alert.addAction(no)
                
                self.present(alert, animated: true, completion: nil)
            }
       
        })
        action.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        var textField = UITextField()
        
        let alert2 = UIAlertController(title: "Add New Reminder", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Reminder", style: .default, handler:{
            
            (UIAlertAction) in
            _ = UITextField()
            if textField.text!.count != 0 {
                let data = reminder()
                data.daily = textField.text!
                data.date  = Date()
                self.saveItems(reminder: data)
                self.viewWillAppear(true)
           
            } else {
                let alert = UIAlertController(title: "Reminder Field is Empty", message: "", preferredStyle: .alert)
                let cancel = UIKit.UIAlertAction(title: "Dismiss", style: .destructive) { (UIAlertAction) in
                     self.present(alert2, animated: true, completion: nil)
                }
             
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        })
        //   UItextfield di uialert
        alert2.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Reminder"
            alertTextField.keyboardType = .alphabet
            alertTextField.returnKeyType = .done
            alertTextField.autocorrectionType = .yes
            textField = alertTextField
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (UIAlertAction) in
            return
        }
        
        alert2.addAction(cancel)
        alert2.addAction(action)
        
        self.present(alert2, animated: true, completion: nil)
        }
    
    func deleteItems(indexPath: IndexPath) {
        
        if let itemDeletion = self.reminderRealm?[indexPath.row] {
        do {
            try self.realm.write {
                realm.delete(itemDeletion)
            }
        }
        catch {
            print("Error deleting Data \(error)")
        }
      }
    }
    
    func saveItems(reminder: reminder) {
        do  {
            try realm.write {
                realm.add(reminder)
               }
             }
      catch {
             print("Error Saving Data \(error)")
            }
        }
    
    func loadItems() {
        reminderRealm = realm.objects(reminder.self)
        tableView.reloadData()
    }
}

extension CustomDiaryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        reminderRealm = reminderRealm?.filter("daily CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "daily", ascending: true)
        searchBar.sizeToFit()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
