//
//  DiaryMainViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 01/01/20.
//  Copyright © 2020 Mikhael Adiputra. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAuth
import FirebaseDatabase
import UIColor_Hex_Swift

class DiaryMainViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var diaryLabel: UILabel!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    fileprivate let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    fileprivate var notes = [Note]()
    fileprivate var notesPinned = [Note]()
    fileprivate let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.retrieveNotes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate   = self
     
        // searchbar delegate
        searchbar.delegate = self
        searchbar.backgroundImage = UIImage()
        
        // searchbar backgroundColor
        if #available(iOS 13, *) {
             searchbar.searchTextField.backgroundColor = UIColor.white
         }else {
             searchbar.backgroundColor = UIColor.white
         }
        
       tableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: Double.leastNormalMagnitude))
    
        // UITapGestureRecognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapped))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
        
        // Styles for tableView
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func countChecker() {
        if notes.count == 0 && notesPinned.count == 0{
            diaryLabel.isHidden = false
        } else {
            diaryLabel.isHidden = true
        }
    }
    
    @objc func handleTapped(gesture: UITapGestureRecognizer){
          searchbar.resignFirstResponder()
      }
        
    // MARK: - Table view data source and delegate Function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header : String?
        switch section {
            case 0:
               header = "Pinned"
            case 1:
                if (notesPinned.count == 0 && notes.count != 0) || (notesPinned.count != 0 && notes.count == 0) || (notesPinned.count == 0 && notes.count == 0){
                    header = nil
                }else {
                    header = "Others"
                }
            default:
                fatalError("Header doesnt exist")
        }
        return header
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return notesPinned.count
        }else {
            return notes.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            if notesPinned.count == 0 {
                return 0
            }else {
                return UITableView.automaticDimension
            }
        }else if section == 1{
            if notesPinned.count == 0{
                return 0.0
            }else {
                return UITableView.automaticDimension
            }
        }else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteTableViewCell", for: indexPath) as! noteTableViewCell

            if indexPath.section == 0{
                cell.configureCell(note: self.notesPinned[indexPath.row])
            }else {
                cell.configureCell(note: self.notes[indexPath.row])
            }
            cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        }
        tableView.reloadData()
    }
        
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var pinned : UITableViewRowAction?
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Are you sure want to delete this diary?", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let Delete = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
                if indexPath.section == 0 {
                    let note = self.notesPinned[indexPath.row]
                    self.context.delete(note)
                    self.saveItems()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.notesPinned.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.countChecker()
                        tableView.reloadData()
                    }
                }else if indexPath.section == 1{
                      let note = self.notes[indexPath.row]
                      self.context.delete(note)
                      self.saveItems()
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.notes.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.countChecker()
                        tableView.reloadData()
                    }
                }
            }
            alert.addAction(cancel)
            alert.addAction(Delete)
            self.present(alert, animated: true, completion: nil)
            }

        if indexPath.section  == 0 {

            if notesPinned[indexPath.row].isPinned == true {
                pinned = UITableViewRowAction(style: .default, title: "Unpin") { (action, indexpath) in
                  self.notesPinned[indexPath.row].isPinned = false
                  self.saveItems()
                  self.retrieveNotes()
                  }
              }
        }else if indexPath.section == 1{
            if notes[indexPath.row].isPinned == false  {
                 pinned = UITableViewRowAction(style: .default, title: "Pin") { (action, indexpath) in
                 self.notes[indexPath.row].isPinned = true
                 self.saveItems()
                 self.retrieveNotes()
                }
            }
        }
        
        pinned!.backgroundColor = UIColor.systemOrange
        delete.backgroundColor = UIColor.red
        return [delete, pinned!]
    }
        
    // MARK: NSCoding
    fileprivate func retrieveNotes() {
        self.fetchNotesFromCoreData { (notes, notesPinned) in
            if let notesBerisi = notes      {
                self.notes = notesBerisi
            }
            if let notePinned = notesPinned {
                self.notesPinned = notePinned
                self.tableView.reloadData()
                self.countChecker()
            }
        }
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            fatalError("Error saving data from context to CoreData \(error.localizedDescription)")
        }
        tableView.reloadData()
    }

    private func fetchNotesFromCoreData( completion: @escaping ([Note]?, [Note]?)->Void){

            var notes = [Note]()
            var notesPinned = [Note]()
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            let predicate : NSPredicate?
            let requestPinned: NSFetchRequest<Note> = Note.fetchRequest()
            let predicatepinned : NSPredicate?

            if Reachability.isConnectedToNetwork() == true {
                   predicate = NSPredicate(format: "username CONTAINS[CD] %@  && date <= %@ && isPinned == %@", Auth.auth().currentUser!.uid, Date() as NSDate, NSNumber(booleanLiteral: false))
            }else {
                let uid = self.defaults.value(forKey: "userUID") as? String
                 predicate = NSPredicate(format: "username CONTAINS[CD] %@  && date <= %@ && isPinned == %@", uid!, Date() as NSDate, NSNumber(booleanLiteral: false))
            }
            
           request.predicate = predicate
           let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
           request.sortDescriptors = [sortDescriptor]
            
            do {
                notes = try self.context.fetch(request)
            }catch {
                print("Could not fetch notes from CoreData: \(error.localizedDescription)")
            }
            
          
           if Reachability.isConnectedToNetwork() == true {
                 predicatepinned = NSPredicate(format: "username CONTAINS[CD] %@  && date <= %@ && isPinned == %@", Auth.auth().currentUser!.uid, Date() as NSDate, NSNumber(booleanLiteral: true))
           }else {
               let uid = self.defaults.value(forKey: "userUID") as? String
                 predicatepinned = NSPredicate(format: "username CONTAINS[CD] %@  && date <= %@ && isPinned == %@",uid!, Date() as NSDate, NSNumber(booleanLiteral: true))
           }
         
          requestPinned.predicate = predicatepinned
          let sortDescriptorPinned = NSSortDescriptor(key: "date", ascending: false)
          requestPinned.sortDescriptors = [sortDescriptorPinned]
        
           do {
               notesPinned = try self.context.fetch(requestPinned)
               completion(notes, notesPinned)
           }catch {
               print("Could not fetch notes from CoreData: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Sending Data to noteViewController(for user edit diary)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedNote : Note?
                if let nextDetailViewController = segue.destination as? noteViewController {
                    if indexPath.section == 0{
                        selectedNote = notesPinned[indexPath.row]
                        nextDetailViewController.isExsisting = false
                        nextDetailViewController.note = selectedNote
                    }else {
                        selectedNote = notes[indexPath.row]
                        nextDetailViewController.isExsisting = false
                        nextDetailViewController.note = selectedNote
                    }
                }
            }
        }
    }
  
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       let request : NSFetchRequest<Note> = Note.fetchRequest()
       let requestPinned :  NSFetchRequest<Note> = Note.fetchRequest()
       let predicate : NSPredicate?
       let predicatePinned : NSPredicate?

         if Reachability.isConnectedToNetwork() == true {
             predicatePinned = NSPredicate(format: "(username CONTAINS[CD] %@) AND (noteName CONTAINS[CD] %@) AND (isPinned == %@)", Auth.auth().currentUser!.uid , searchBar.text!, NSNumber(booleanLiteral: true))
         }else {
             let uid = defaults.value(forKey: "userUID") as? String
               predicatePinned = NSPredicate(format: "(username CONTAINS[CD] %@) AND (noteName CONTAINS[CD] %@) AND (isPinned == %@)", uid! , searchBar.text!, NSNumber(booleanLiteral: true))
         }
        
        requestPinned.predicate = predicatePinned
        let sortDescriptorPinned = NSSortDescriptor(key: "username", ascending: true)
        requestPinned.sortDescriptors = [sortDescriptorPinned]
             
        do {
            notesPinned = try context.fetch(requestPinned)
        }catch {
            print("Data Not found")
        }


        if Reachability.isConnectedToNetwork() == true {
            predicate = NSPredicate(format: "(username CONTAINS[CD] %@) AND (noteName CONTAINS[CD] %@) AND (isPinned == %@)", Auth.auth().currentUser!.uid , searchBar.text!, NSNumber(booleanLiteral: false))
        }else {
            let uid = defaults.value(forKey: "userUID") as? String
             predicate = NSPredicate(format: "(username CONTAINS[CD] %@) AND (noteName CONTAINS[CD] %@) AND (isPinned == %@)", uid! , searchBar.text!, NSNumber(booleanLiteral: false))
        }
 
       request.predicate = predicate
       let sortDescriptor = NSSortDescriptor(key: "username", ascending: true)
       request.sortDescriptors = [sortDescriptor]
        
       do {
          notes = try context.fetch(request)
       } catch {
           print("error")
       }
       searchBar.sizeToFit()
       tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       if searchBar.text?.count == 0 {
            retrieveNotes()
       }
   }
}
