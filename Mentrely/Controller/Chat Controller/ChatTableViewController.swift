//
//  ChatTableViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 08/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    var messageArray = [String]()
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! ChatTableViewCell
        cell.messageBody.text = "sadasda"
        return cell
    }

   
}

