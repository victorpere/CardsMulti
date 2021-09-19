//
//  FlashMessageLabel.swift
//  CardsMulti
//
//  Created by Victor on 2021-09-06.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import SpriteKit

// MARK: - Protocol Flashing

protocol Flashing {
    init(position: CGPoint, width: CGFloat)
    func flash(message: String?)
}

// MARK: - Class FlashMessageLabel

class FlashMessageLabel: UILabel, Flashing {
    
    // MARK: - Initializers
    
    required convenience init(position: CGPoint, width: CGFloat) {
        let frame = CGRect(x: position.x, y: position.y, width: width, height: Config.flashMessageLabelHeight)
        
        self.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = UIFont(name: Config.uiFontName, size: Config.flashMessageFontSize)
        self.textColor = Config.flashMessageColor
        self.textAlignment = .center
        self.alpha = 0
        self.text = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func flash(message: String?) {
        if message == nil {
            return
        }
        
        DispatchQueue.main.async {
            self.alpha = 0
            self.text = message

            UIView.animate(withDuration: Config.flashMessageFadeDuration, animations: { () -> Void in
                self.alpha = 1
            }) { (Bool) -> Void in
                UIView.animate(withDuration: Config.flashMessageFadeDuration, delay: Config.flashMessageDuration, options: .curveEaseInOut, animations: { () -> Void in
                    self.alpha = 0
                }, completion: { (Bool) -> Void in
                    self.text = nil
                })
            }
        }
    }
}

// MARK: - Class FlashMessageNode

class FlashMessageNode: SKLabelNode, Flashing {
    
    // MARK: - Properties
    
    let fadeInAction = SKAction.fadeIn(withDuration: Config.flashMessageFadeDuration)
    let fadeOutAction = SKAction.fadeOut(withDuration: Config.flashMessageFadeDuration)
    let waitAction = SKAction.wait(forDuration: Config.flashMessageDuration)
    
    // MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    required init(position: CGPoint, width: CGFloat) {
        super.init(fontNamed: Config.uiFontName)
        self.position = position
        self.alpha = 0
        self.text = nil
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
        self.isUserInteractionEnabled = false
        self.isHidden = true
        self.zPosition = 1000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func flash(message: String?) {
        if message == nil {
            return
        }
        
        self.text = message
        self.isHidden = false
        self.run(self.fadeInAction) {
            self.run(self.waitAction) {
                self.run(self.fadeOutAction) {
                    self.text = nil
                    self.isHidden = true
                }
            }
        }
    }
}
