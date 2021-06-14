//
//  ContactsViewController.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-06.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit
import ContactsUI
import MessageUI

class ContactsViewController : CNContactPickerViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func sendMessage(to contact: CNContact) {
        if MFMessageComposeViewController.canSendText() {
            let messageComposeViewController = MFMessageComposeViewController()
            messageComposeViewController.body = "TEST MESSAGE"
            messageComposeViewController.recipients = ["6478339244"]
            messageComposeViewController.messageComposeDelegate = self
            
            self.present(messageComposeViewController, animated: true, completion: nil)
        } else if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.setMessageBody("TEST EMAIL", isHTML: false)
            mailComposeViewController.setToRecipients(["victor.perelman@icloud.com"])
            mailComposeViewController.mailComposeDelegate = self
            
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            print("Unable to send text or email")
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension ContactsViewController : CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.sendMessage(to: contact)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ContactsViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension ContactsViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
