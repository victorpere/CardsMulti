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
    
    convenience init(numberOfCards: Int, numberOfPlayers: Int) {
        let maxNumberOfCardsToDeal = numberOfCards / numberOfPlayers
        self.init(title: String(format: "%d cards selected".localized, numberOfCards), message: nil, preferredStyle: .actionSheet)
        
        let shuffleButton = UIAlertAction(title: "shuffle".localized, style: .default, handler: {
            (alert) -> Void in
            self.delegate?.shuffle()
        })
        self.addAction(shuffleButton)
        
        let stackButton = UIAlertAction(title: "stack".localized, style: .default, handler: {
            (alert) -> Void in
            self.delegate?.stack()
        })
        self.addAction(stackButton)
        
        let fanButton = UIAlertAction(title: "fan".localized, style: .default, handler: {
            (alert) -> Void in
            self.delegate?.fan()
        })
        self.addAction(fanButton)
        
        for index in 1...maxNumberOfCardsToDeal {
            let dealButton = UIAlertAction(title: "\("deal".localized) \(index)", style: .default, handler: { (alert) -> Void in
                self.delegate?.deal(index)
            })
            self.addAction(dealButton)
        }
        
        let cancelButton = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in
            self.delegate?.cancel()
        }
        self.addAction(cancelButton)
    }
}

// MARK: - PopUpMenuDelegate protocol

protocol PopUpMenuDelegate {
    func deal(_ cards: Int)
    func fan()
    func shuffle()
    func stack()
    func cancel()
}
