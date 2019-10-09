//
//  CardSlider.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-03.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class CardSlider : UISlider {
    let SLIDER_ICON = "icon_card_slider"
    let MIN: Float = 3.0
    let MAX: Float = 10.0
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        self.minimumValue = MIN
        self.maximumValue = MAX
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Events
    
    @objc func sliderMoved(sender: CardSlider) {
        self.value = sender.value
        self.setThumbImage()
    }
    
    // MARK: - Methods
    
    func setThumbImage() {
        if self.value >= MIN && self.value <= MAX {
            var cardValue = Int(self.value)
            if self.value == MIN {
                cardValue = Int(MIN) - 1
            }
            let imageName = SLIDER_ICON + String(cardValue)
            let image = UIImage(named: imageName)
            
            DispatchQueue.main.async {
                self.setThumbImage(image, for: .normal)
            }
        }
    }
}
