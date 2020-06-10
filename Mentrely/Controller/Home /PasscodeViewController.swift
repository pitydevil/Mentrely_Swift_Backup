//
//  PasscodeViewController.swift
//  Mentrely
//
//  Created by Oktavianus Ricky on 31/12/19.
//  Copyright © 2019 Mikhael Adiputra. All rights reserved.
//

import UIKit
import TMPasscodeLock
import LocalAuthentication

class PasscodeViewController: UITableViewController, TMPasscodeLockControllerDelegate {
    
    @IBOutlet var changePasscodeCell: UITableViewCell!
    @IBOutlet var removePasscodeCell: UITableViewCell!
    @IBOutlet weak var biometricCell: UITableViewCell!
    @IBOutlet weak var biometricCellName: UILabel!
    @IBOutlet weak var biometricSwitch: UISwitch!
    
    private let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentType = LAContext().biometricType
        
        switch currentType {
        case .faceID:
            biometricCell.textLabel?.text = "Face ID"
            break
        case .touchID:
            biometricCell.textLabel?.text = "Touch ID"
            break
        case .none :
            biometricCell.isHidden = true
            break
        }
        let clearView = UIView()
        clearView.backgroundColor = UIColor.clear // Whatever color you like
        biometricCell.selectionStyle = .none
        
        let biometricState = defaults.bool(forKey: "biometric")
        if biometricState == true {
            biometricSwitch.setOn(true, animated: false)
        }else {
            biometricSwitch.setOn(false, animated: false)
        }
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath) == changePasscodeCell {
                
            let passcodeLockController = TMPasscodeLockController(style: .basic, state: .change)
            passcodeLockController.delegate = self
            passcodeLockController.presentIn(viewController: self, animated: true)
        
        } else if tableView.cellForRow(at: indexPath) == removePasscodeCell {
            let passcodeLockController = TMPasscodeLockController(style: .basic, state: .remove)
            passcodeLockController.delegate = self
            passcodeLockController.presentIn(viewController: self, animated: true)
         
        }
           tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func passcodeLockControllerDidCancel(passcodeLockController: TMPasscodeLockController) {
        let biometricState = defaults.bool(forKey: "biometric")
         if biometricState == true {
             biometricSwitch.setOn(true, animated: false)
         }else {
             biometricSwitch.setOn(false, animated: false)
         }
    }
    
    func passcodeLockController(passcodeLockController: TMPasscodeLockController, didFinishFor state: TMPasscodeLockState) {
        if state == .remove {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3, execute: {
                _ = self.navigationController?.popViewController(animated: true)
            })
        } else if state == .enter {
            biometricSwitch.setOn(true, animated: false)
            defaults.set(true, forKey: "biometric")
        }
    }
    
    @IBAction func `switch`(_ sender: Any) {
          let biometricState = defaults.bool(forKey: "biometric")
          if biometricState == true {
                biometricSwitch.setOn(false, animated: false)
                defaults.set(false, forKey: "biometric")
            }else {
            let passcodeLockController = TMPasscodeLockController(style: .basic, state: .enter)
            passcodeLockController.delegate = self
            passcodeLockController.presentIn(viewController: self, animated: true)
        }
    }
}
