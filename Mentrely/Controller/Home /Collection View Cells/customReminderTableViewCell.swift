//
//  customReminderTableViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 29/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class customReminderTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundCard.layer.cornerRadius = 5
        backgroundCard.layer.shadowRadius = 6
        backgroundCard.layer.shadowOpacity = 0.4
        backgroundCard.layer.shadowOffset = CGSize(width: 2.5, height: 2.5)
    }
    @IBOutlet weak var backgroundCard: UIView!
    

    @IBOutlet weak var namaReminder: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
