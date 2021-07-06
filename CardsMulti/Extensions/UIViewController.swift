//
//  UIViewController.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-26.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    /**
     Displays information alert with OK button that dismisses the alert
     */
    func showAlert(title: String, text: String?) {
        DispatchQueue.main.async {
            let messageAlert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "ok".localized, style: .cancel) { (alert) -> Void in }
            
            messageAlert.addAction(cancelButton)
            self.present(messageAlert, animated: true, completion: nil)
        }
    }
    
    /**
     Displays an alert with a text entry and OK and Cancel buttons
     */
    func showTextDialog(title: String, text: String, keyboardType: UIKeyboardType, okAction: @escaping ((String) -> Void)) {
        DispatchQueue.main.async {
            let textInputAlert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            textInputAlert.addTextField()
            textInputAlert.textFields![0].keyboardType = keyboardType
            
            let okButton = UIAlertAction(title: "ok".localized, style: .default) { (alert) -> Void in
                if let inputText = textInputAlert.textFields![0].text {
                    okAction(inputText)
                }
            }
            let cancelButton = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in }
            
            textInputAlert.addAction(okButton)
            textInputAlert.addAction(cancelButton)        
        
            self.present(textInputAlert, animated: true, completion: nil)
        }
    }
    
    /**
     Displays an alert with OK and Cancel buttons
     */
    func showActionDialog(title: String?, text: String?, actionTitle: String, action: @escaping (() -> Void), cancelAction: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            
            let action = UIAlertAction(title: actionTitle, style: .default) { (alert) -> Void in
                action()
            }

            let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in
                if cancelAction != nil {
                    cancelAction!()
                }
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
