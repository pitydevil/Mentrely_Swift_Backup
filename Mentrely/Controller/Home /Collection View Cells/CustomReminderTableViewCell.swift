//
//  customReminderTableViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 29/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

protocol reminderTulisan {
    func endText(Tulisan: String, Cell : CustomReminderTableViewCell)
}

protocol reminderTapped {
    func indexpathShifter(Cell : CustomReminderTableViewCell)
}


class CustomReminderTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var namaReminder: UILabel!
    @IBOutlet weak var reminderTextfield: UITextField!
    @IBOutlet weak var pinnedImage: UIImageView!
    
    var tulisanDelegate : reminderTulisan?
    var tappedDelegate : reminderTapped?
    
    @IBAction func reminderTapped(_ sender: Any) {
        tappedDelegate?.indexpathShifter(Cell: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        tulisanDelegate?.endText(Tulisan: textField.text!, Cell: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reminderTextfield.delegate = self
        selectionStyle = .none
    }

}
