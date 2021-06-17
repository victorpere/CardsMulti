//
//  PlayerStatusLabel.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-13.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class PlayerStatusLabel : UILabel {
    // MARK: - Constants
    let height: CGFloat = 15
    let fontName = "Helvetica"
    let fontSize: CGFloat = 12
    let fontColor = UIColor.green
    
    // MARK: - Properties
    
    var playerNameLabel: String = ""
    var numberOfCardsLabel: String = String(format: "%d cards".localized, 0)
    var position: Position
    
    // MARK: - Initilizers
    init(withFrameDimension frameDimension: CGFloat, inPosition position: Position, withInsets insets: UIEdgeInsets) {
        var frame = CGRect()
        var rotationAngle: CGFloat = 0
        
        switch position {
        case .error:
            break
        case .bottom:
            break
        case .top:
            frame = CGRect(x: insets.left, y: insets.top, width: frameDimension, height: self.height)
        case .left:
            frame = CGRect(x: (self.height - frameDimension) / 2 + insets.left, y: frameDimension / 2 + insets.top, width: frameDimension, height: self.height)
            rotationAngle = CGFloat(0 - Double.pi / 2)
        case .right:
            frame = CGRect(x: (frameDimension - self.height) / 2 + insets.left - insets.right, y: frameDimension / 2 + insets.top, width: frameDimension, height: self.height)
            rotationAngle = 0 - CGFloat(0 - Double.pi / 2)
        }
        
        self.position = position
        super.init(frame: frame)
        
        self.font = UIFont(name: self.fontName, size: self.fontSize)
        self.textColor = self.fontColor
        self.textAlignment = .center
        self.transform = CGAffineTransform(rotationAngle: rotationAngle)

        self.updateText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func update(playerName: String) {
        self.playerNameLabel = playerName
        self.updateText()
    }
    
    func update(numberOfCards: Int) {
        self.numberOfCardsLabel = String(format: "%d cards".localized, numberOfCards)
        self.updateText()
    }
    
    // MARK: - Private methods
    
    private func updateText() {
        DispatchQueue.main.async {
            self.text = "\(self.numberOfCardsLabel) ↑ \(self.playerNameLabel)"
        }
    }
}
