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
    
    /// Location of the touch that triggered the menu to pop up
    var touchLocation: CGPoint?
    
    /// Whether to presend flip cards down option
    var flipFaceDown = true
    
    /// Wnether to present flip cards up option
    var flipFaceUp = true
    
    // MARK: - Initializers
    
    convenience init(numberOfCards: Int, delegate: PopUpMenuDelegate?) {
        self.init(title: String(format: "%d cards selected".localized, numberOfCards), message: nil, preferredStyle: .actionSheet)
        
        self.delegate = delegate
        let maxNumberOfCardsToDeal = numberOfCards / (self.delegate == nil ? 1 : self.delegate!.numberOfPlayers)
        if numberOfCards == 0 {
            for position in Position.allCases.filter( { $0.rawValue > 0 } ) {
                if let numberOfCardsInPosition = self.delegate?.numberOfCards(inPosition: position), numberOfCardsInPosition > 0 {
                    let recallAction = UIAlertAction(title: String(format: "recall cards from %@".localized, "\(position)".localized), style: .default, handler: {
                        (alert) -> Void in
                        self.delegate?.recall(from: position, to: self.touchLocation)
                    })
                    self.addAction(recallAction)
                }
            }
        } else {
            let shuffleAction = UIAlertAction(title: "shuffle".localized, style: .default, handler: {
                (alert) -> Void in
                self.delegate?.shuffle()
            })
            self.addAction(shuffleAction)
            
            let stackAction = UIAlertAction(title: "stack".localized, style: .default, handler: {
                (alert) -> Void in
                self.delegate?.stack()
            })
            self.addAction(stackAction)
            
            let fanAction = UIAlertAction(title: "fan".localized, style: .default, handler: {
                (alert) -> Void in
                self.delegate?.fan()
            })
            self.addAction(fanAction)
            
            if self.flipFaceDown {
                let flipFaceDownAction = UIAlertAction(title: "flip face down".localized, style: .default, handler: {
                    (alert) -> Void in
                    // TODO: delegate method to flip
                })
                self.addAction(flipFaceDownAction)
            }
            
            if self.flipFaceUp {
                let flipFaceUpAction = UIAlertAction(title: "flip face up".localized, style: .default, handler: {
                    (alert) -> Void in
                    // TODO: delegate method to flip
                })
                self.addAction(flipFaceUpAction)
            }
            
            for index in 1...maxNumberOfCardsToDeal {
                let dealAction = UIAlertAction(title: "\("deal".localized) \(index)", style: .default, handler: { (alert) -> Void in
                    self.delegate?.deal(index)
                })
                self.addAction(dealAction)
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in
            self.delegate?.cancel()
        }
        self.addAction(cancelAction)
    }
}

// MARK: - PopUpMenuDelegate protocol

protocol PopUpMenuDelegate {
    var numberOfPlayers: Int { get }
    func numberOfCards(inPosition position: Position) -> Int
    func deal(_ cards: Int)
    func fan()
    func shuffle()
    func stack()
    func cancel()
    func recall(from position: Position?, to location: CGPoint?)
}
