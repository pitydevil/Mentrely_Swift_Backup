//
//  AboutTableViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 27/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class AboutTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var TellLabel: UILabel!
    @IBOutlet weak var imageVIEW: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
