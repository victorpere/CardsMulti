//
//  FlashMessageLabel.swift
//  CardsMulti
//
//  Created by Victor on 2021-09-06.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit

class FlashMessageLabel: UILabel {
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.font = UIFont(name: Config.uiFontName, size: Config.flashMessageFontSize)
        self.textColor = Config.flashMessageColor
        self.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func flash(message: String?) {
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
