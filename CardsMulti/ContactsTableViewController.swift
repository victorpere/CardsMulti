//
//  ContactsTableViewController.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-06.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ContactsTableViewController : UIViewController {

    // MARK: - Properties
    
    var tableView : UITableView!
    var contacts = [CNContact]()
    var delegate: ContactsTableViewControllerDelegate?
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), style: UITableView.Style.plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
        
        self.loadContacts()
    }
    
    // MARK: - Private methods
    
    fileprivate func loadContacts() {
        self.contacts = [CNContact]()
        
        let store = CNContactStore()
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        do {
            try store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                self.contacts.append(contact)
            })
        } catch {
            print("Failed to fetch contacts")
        }
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

// MARK: - UITableViewDelegate

extension ContactsTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = self.contacts[indexPath.row]
        
        self.sendMessage(to: contact)
    }
}

// MARK: - UITableViewDataSource

extension ContactsTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        let contact = self.contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        return cell
    }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension ContactsTableViewController : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: {() in
            if result == .sent {
                self.delegate?.messageSent()
            }
        })
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension ContactsTableViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Protocol ContactsTableViewControllerDelegate

protocol ContactsTableViewControllerDelegate {
    func messageSent()
}
