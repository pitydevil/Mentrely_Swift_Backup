//
//  ListTableViewCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 09/08/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet weak var imageDoctornya: UIImageView!
    @IBOutlet weak var namaPenyakit: UILabel!
    @IBOutlet weak var namaDoktor: UILabel!
    @IBOutlet weak var backgroundCard: UIView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var previewChatLabel: UILabel!
    @IBOutlet weak var chatCounter: UILabel!
    @IBOutlet weak var lastChatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageDoctornya.layer.cornerRadius = 5
        imageDoctornya.layer.borderWidth = 0.5
        imageDoctornya.layer.borderColor = UIColor.gray.cgColor
        imageDoctornya.backgroundColor = UIColor.white
        backgroundCard.layer.cornerRadius = 5
        backgroundCard.layer.shadowOpacity = 0.5
        backgroundCard.layer.shadowOffset = CGSize(width: 1, height: 1)
        backgroundCard.layer.shadowRadius = 3
        chatCounter.layer.cornerRadius = chatCounter.frame.height/2
        chatCounter.clipsToBounds = true
    
    }
}
