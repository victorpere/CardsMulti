//
//  PopUpMenu.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-07.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class PopUpMenu : UIAlertController {
    
    var delegate: PopUpMenuDelegate?
    
    // MARK: - Initializers
    
    convenience init(title: String?, menuItems: [PopUpMenuItem]) {
        self.init(title: title, message: nil, preferredStyle: .actionSheet)
        
        for menuItem in menuItems {
            self.addMenuItem(title: menuItem.title, action: menuItem.action, parameter: menuItem.parameter)
        }
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in
            self.delegate?.cancel()
        }
        self.addAction(cancelAction)
    }
    
    // MARK: - public methods
    
    func addMenuItem(title: String, action: @escaping ((Any?) -> Void), parameter: Any?) {
        let action = UIAlertAction(title: title, style: .default, handler: { (alert) -> Void in
            action(parameter)
        })
        self.addAction(action)
    }
}

// MARK: - PopUpMenuDelegate protocol

protocol PopUpMenuDelegate {
    func cancel()
}

struct PopUpMenuItem {
    let title: String
    let action: (Any?) -> Void
    let parameter: Any?
}
