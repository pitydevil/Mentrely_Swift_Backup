//
//  TableViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 23/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var issuesArray = ["Autism", "Depression", "Scizophrenia", "Hyperactivity Disorder", "Bipolar Disorder", "Obsessive Compulsive Disorder", "Post Traumatic Stress"]

    var segueIdentifier = ["goToAutism", "goToDepression", "goToScizophrenia", "goToHyper", "goToBipolar", "goToOCD", "goToPost"]

    override func viewDidLoad() {
        super.viewDidLoad()

      tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "labelMental")
      tableView.rowHeight = 50
      tableView.separatorStyle = .none

 
    }

    override func viewDidAppear(_ animated: Bool) {

        let layer = CAGradientLayer()
        layer.frame = tableView.bounds
        layer.colors = [UIColor.purple.cgColor, UIColor.orange.cgColor]
        layer.startPoint = CGPoint(x: 0.8,y: 0)
        layer.endPoint = CGPoint (x: 1,y: 1)
        tableView.layer.insertSublayer(layer, at: 0)
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return issuesArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelMental", for: indexPath) as! TableViewCell

        cell.labelMental.text = issuesArray[indexPath.row]





        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: segueIdentifier[indexPath.row], sender: self)

        tableView.deselectRow(at: indexPath, animated: true)
    }





}
