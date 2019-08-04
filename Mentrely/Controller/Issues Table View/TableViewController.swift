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

    var doctor = ["Dr. Nella", "Dr Sigmund Freud", "Dr terrano", "asd", "adsa", "asda", "asdad"]

    var photoList : [UIImage] = [UIImage(named: "Autism")!, UIImage(named: "Depression")!, UIImage(named: "Schizophrenia")!, UIImage(named: "ADHD")!, UIImage(named: "Bipolar")!, UIImage(named: "OCD")!, UIImage(named: "PTSD")!]



    override func viewDidLoad() {
        super.viewDidLoad()



  


 
    }

    override func viewDidAppear(_ animated: Bool) {

        
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return issuesArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "issuesCell", for: indexPath) as! TableViewCell

        cell.namaPenyakit.text = issuesArray[indexPath.row]
        cell.namadokter.text = doctor[indexPath.row]
        cell.imagePenyakit.layer.borderWidth = 1.0
        cell.imagePenyakit.layer.borderColor = UIColor.gray.cgColor
        cell.imagePenyakit.layer.cornerRadius = 20


        let layer = CAGradientLayer()
        layer.frame = cell.backgroundCard.bounds
        layer.colors = [UIColor.brown.cgColor, UIColor.orange.cgColor]
        layer.startPoint = CGPoint(x: 0.2,y: 0.2)
        layer.endPoint = CGPoint (x: 1,y: 1)
       cell.backgroundCard.layer.insertSublayer(layer, at: 0)

            cell.layer.shadowOpacity = 1
            cell.layer.shadowRadius = 1
            cell.layer.shadowOffset = CGSize(width: 2, height: 2)
            cell.imagePenyakit.image = photoList[indexPath.row]
            cell.imagePenyakit.backgroundColor = UIColor.white


        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        performSegue(withIdentifier: segueIdentifier[indexPath.row], sender: self)

        tableView.deselectRow(at: indexPath, animated: true)
    }



}
