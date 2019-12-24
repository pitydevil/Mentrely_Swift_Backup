//
//  TableViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 25/07/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
    }

  
    @IBOutlet weak var imagePenyakit: UIImageView!
    @IBOutlet weak var namaPenyakit: UILabel!
    @IBOutlet weak var namadokter: UILabel!
    @IBOutlet weak var backgroundCard: UIView!
    

    
}
