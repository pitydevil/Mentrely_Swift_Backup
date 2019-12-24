//
//  UIView Extensions.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 18/09/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

extension UIView {
    func setLayer() {
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 7
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.5, height: 1)
        self.layer.shadowColor =  UIColor(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
    }
    func reminderLayer() {
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius  = 5
        self.layer.cornerRadius = 10
    }
}

extension UIButton {
    func setShadow() {
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 1.5
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }
    func setShadowDiary() {
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 1
       self.layer.shadowOpacity = 0.5
       self.layer.shadowOffset = CGSize(width: 0.25, height: 0.25)
    }
    func setRoundedButton() {
        self.layer.cornerRadius = self.layer.frame.height/2
    }
}

extension UITextField {
    func setSignUp() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
    }
    
    func setBottomBorder() {
        self.borderStyle = .none
      //  self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
   //     self.layer.shadowColor = UIColor("#D52192").cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func txtPaddingVw(txt:UITextField) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        txt.leftViewMode = .always
        txt.leftView = paddingView
    }
    
}
extension UIImageView {
    func roundedCorner() {
        self.layer.cornerRadius = self.frame.height/2
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    func shadow1Px() {
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius  = 1
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}

