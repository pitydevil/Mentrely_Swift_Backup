//
//  ChatMessageCell.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 08/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
protocol profileButton {
    func indexpath(indexpath: Int)
}

class ChatMessageCell: UICollectionViewCell {
    
    var indexpath: Int = 0
    let textView: UITextView = {
        let tv = UITextView()
        tv.text = "text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        return tv
    }()
    let textViewNama: UITextView = {
          let tv = UITextView()
          tv.text = "namaUser"
          tv.font = UIFont.systemFont(ofSize: 16)
          tv.translatesAutoresizingMaskIntoConstraints = false
          tv.backgroundColor = UIColor.clear
          return tv
      }()
    
    let timeLabel : UILabel = {
       let label = UILabel()
        label.text = "time"
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.blue
        
        return label
        
    }()
    
    let bubble : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemTeal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    let imageView : UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(named: "finalProfile")
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
        
    }()
    let profileButton : UIButton =  {
        let sendButton = UIButton()
        sendButton.backgroundColor = UIColor.clear
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("", for: .normal)
        return sendButton
    }()
    
    var bubbleWidth : NSLayoutConstraint?
    var bubbleViewRightAnchor :NSLayoutConstraint?
    var bubbleViewLeftAnchor : NSLayoutConstraint?
    var timeTableLeftAnchor : NSLayoutConstraint?
    var timeTableRightAnchor : NSLayoutConstraint?
    var delegate : profileButton?

    
    override init (frame: CGRect) {
        super.init(frame:frame)
        addSubview(bubble)
        addSubview(textView)
        addSubview(imageView)
        addSubview(textViewNama)
        addSubview(timeLabel)
        addSubview(profileButton)
      
        
        bubbleViewRightAnchor = bubble.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        
        bubbleViewLeftAnchor = bubble.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8)
        bubbleViewLeftAnchor?.isActive = false
        
        bubble.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubble.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleWidth = bubble.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidth?.isActive = true
        
        timeTableLeftAnchor =  timeLabel.leftAnchor.constraint(equalTo: bubble.rightAnchor, constant: 4)
        timeTableLeftAnchor?.isActive = true
        timeTableRightAnchor = timeLabel.rightAnchor.constraint(equalTo: bubble.leftAnchor, constant: 14)
        timeTableRightAnchor?.isActive = false
        
        //timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: 0).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 42).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        timeLabel.font = UIFont.systemFont(ofSize: 9)
        timeLabel.textColor =  UIColor.gray
        
        //constrain TextViewMain
        textView.rightAnchor.constraint(equalTo: bubble.rightAnchor).isActive = true
        textView.leftAnchor.constraint(equalTo: bubble.leftAnchor, constant: 8).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textView.isEditable = false
        textView.isSelectable = false
        
        //constrain profileImageView
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -26).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.isHidden = true

        //constrain imageButton
        profileButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -26).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileButton.isHidden = true
        profileButton.addTarget(self, action: #selector(doThisWhenButtonIsTapped(_:)), for: .touchUpInside)

        //constrain TextViewNama
        textViewNama.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 45).isActive = true
        textViewNama.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        textViewNama.topAnchor.constraint(equalTo: bubble.topAnchor, constant: -30).isActive = true
        textViewNama.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        textViewNama.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        textViewNama.isEditable = false
    }
    
    @IBAction private func doThisWhenButtonIsTapped(_ sender: Any) {
        if imageView.image != UIImage(named: "finalProfile") {
              delegate?.indexpath(indexpath: self.indexpath)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
