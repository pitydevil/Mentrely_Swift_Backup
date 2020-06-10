//
//  noteTableViewCell.swift
//  Notes
//
//  Created by Irina on 8/2/17.
//  Copyright © 2017 Apple Developer. All rights reserved.
//

import UIKit

class noteTableViewCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var noteNameLabel: UILabel!
    @IBOutlet weak var noteDescriptionLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Styles
        shadowView.layer.shadowColor   = UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        shadowView.layer.shadowOffset  = CGSize(width: 0.75, height: 0.75)
        shadowView.layer.shadowRadius  = 3
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.cornerRadius  = 10
        
        noteImageView.layer.cornerRadius = 2
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
               contentView.frame = contentView.frame.inset(by: margins)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.noteImageView.image = nil
      }
    
    func configureCell(note: Note) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        let dateString = dateFormatter.string(from: note.date ?? Date() )
        self.dateLabel.text = dateString
        self.noteNameLabel.text = note.noteName
        self.noteDescriptionLabel.text = note.noteDescription
       
        if let noteImage = note.noteImage {
            self.noteImageView.image = UIImage(data: noteImage as Data)
            self.noteImageView.contentMode = .scaleAspectFill
            self.noteImageView.layer.borderColor = UIColor("#E0E0E0").cgColor
            self.noteImageView.layer.borderWidth = 3
            self.noteImageView.roundedCorner()
            self.noteImageView.backgroundColor   = UIColor.white
            
        }else {
            self.noteImageView.image = UIImage(named: "diaryBaru")
            self.noteImageView.contentMode = .scaleAspectFill
        }
    }
}
