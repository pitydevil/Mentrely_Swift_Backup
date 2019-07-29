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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var labelMental: UILabel!
    @IBOutlet weak var imageMental: UIImageView!
    
}
