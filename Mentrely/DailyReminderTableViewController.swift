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

class DailyReminderTableViewController: UITableViewController,SwipeTableViewCellDelegate {

var reminderRealm : Results<reminder>?
let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

            loadItems()
            tableView.rowHeight = 60

    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reminderRealm?.count ?? 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell

        cell.delegate = self

        cell.textLabel?.text = reminderRealm?[indexPath.row].daily ?? "Add a daily Reminder"



        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }

    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
        // handle action by updating model with deletion

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
    func updateModel(at indexpath: IndexPath) {

             if let categoryForDeletion = self.reminderRealm?[indexpath.row] {
        do {
            try self.realm.write {
                self.realm.delete(categoryForDeletion)
                }
                    } catch {

        print("error \(error)")

            }
        }
    }


    @IBAction func addButton(_ sender: UIBarButtonItem) {


        // textfield dibawah digunakan agar bisa mensave apa yang ditulis user

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

                print("success")

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


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
