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
    
    convenience init(numberOfCards: Int) {
        self.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for index in 1...numberOfCards {
            let dealButton = UIAlertAction(title: "Deal \(index)", style: .default, handler: { (alert) -> Void in
                self.delegate?.deal(index)
            })
            self.addAction(dealButton)
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in
            self.delegate?.cancel()
        }
        self.addAction(cancelButton)
    }
}

// MARK: - PopUpMenuDelegate protocol

protocol PopUpMenuDelegate {
    func deal(_ cards: Int)
    func shuffle()
    func cancel()
}
