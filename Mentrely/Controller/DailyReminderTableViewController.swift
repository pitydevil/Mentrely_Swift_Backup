//
//  DailyReminderTableViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 28/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class DailyReminderTableViewController: UITableViewController, SwipeTableViewCellDelegate {

var reminderRealm : Results<reminder>?
let realm = try! Realm()

    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

            loadItems()
            tableView.rowHeight = 60
            searchBar.barTintColor = UIColor.purple
           
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reminderRealm?.count ?? 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell

        cell.delegate = self
        cell.textLabel?.text = reminderRealm?[indexPath.row].daily ?? "Add a daily Reminder"

        if reminderRealm?[indexPath.item].done == true {

            cell.accessoryType = .checkmark

        } else {

            cell.accessoryType = .none
        }

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            do {
                 try realm.write {

                if reminderRealm?[indexPath.item].done == false {

                    reminderRealm?[indexPath.item].done = true

                    print("trued")

                    } else {

               reminderRealm?[indexPath.item].done = false

                    print("falsed")
                            }
                        }
                    } catch {
                print("error \(error)")

                }

                tableView.reloadData()
                tableView.deselectRow(at: indexPath, animated: true)
            }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in

        self.updateModel(at: indexPath)

    }

    // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {

        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options

    }

    // MARK: -- UPDATE MODEL FOR DELETING

    func updateModel(at indexpath: IndexPath) {

             if let reminderForDeletion = self.reminderRealm?[indexpath.row] {
        do {
            try self.realm.write {
                self.realm.delete(reminderForDeletion)
                }
                    } catch {
                    print("error \(error)")
                    }
                }
            }


    @IBAction func addButton(_ sender: UIBarButtonItem) {

        // apa yang akan terjadi saat user menclick add button

        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Reminder", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Reminder", style: .default, handler:{

         (UIAlertAction) in

        // What will happen if user clicks on our UI alert

        let textfield = UITextField()

            let data = reminder()
            data.daily = textField.text!
            self.saveItems(reminder: data)
            self.tableView.reloadData()

                print("success adding data")
            })

        //   UItextfield di uialert

            alert.addTextField { (alertTextField) in

            alertTextField.placeholder = "Create New Reminder"
            textField = alertTextField

        }

        let cancel = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in

                print("Canceled")
            }

        alert.addAction(cancel)
        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

    // MARK: --UNTUK MENSAVE DAN MELOAD DATA

    func saveItems(reminder: reminder ) {

        do {
            try realm.write {
            realm.add(reminder)
                }
            }

        catch {

            print("error saving context \(error)")

            }
        }

    func loadItems() {

        reminderRealm = realm.objects(reminder.self)
        tableView.reloadData()

        }
}
    // MARK: -- EXTENSION UNTUK SEARCHBAR DELEGATE

extension DailyReminderTableViewController : UISearchBarDelegate{


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        reminderRealm = reminderRealm?.filter("daily CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "daily", ascending: true)

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
