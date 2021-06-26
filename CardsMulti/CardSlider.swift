//
//  CardSlider.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-03.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class CardSlider : UISlider, CardSliderDelegate {
    let slider_icon = "icon_card_slider"
    let slider_track = "slider_frame"
    let MIN: Float = 3.0
    let MAX: Float = 10.0
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    var minDelegate: CardSliderDelegate?
    var maxDelegate: CardSliderDelegate?
    
    var rank: Int { return self.value == self.MIN ? Int(self.MIN - 1) : Int(self.value) }
    var lastRank: Int!
    
    // MARK: - Initializers
    
    convenience init(width: CGFloat, initialRank: Int) {
        let frame = CGRect(x: 0, y: 0, width: width, height: 51)
        self.init(frame: frame)
        self.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        self.minimumValue = MIN
        self.maximumValue = MAX
        
        var sliderTrackImage = UIImage(named: self.slider_track)
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sliderTrackImage = sliderTrackImage?.resizableImage(withCapInsets: insets)
        self.setMinimumTrackImage(sliderTrackImage, for: .normal)
        self.setMaximumTrackImage(sliderTrackImage, for: .normal)
        
        self.value = Float(initialRank) + 0.5
        self.lastRank = initialRank
        self.setThumbImage()
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.selectionFeedbackGenerator.prepare()
        return super.beginTracking(touch, with: event)
    }
    
    // MARK: - Events
    
    @objc func sliderMoved(sender: CardSlider) {
        DispatchQueue.main.async {
            self.setThumbImage()
            
            if self.rank != self.lastRank {
                self.selectionFeedbackGenerator.selectionChanged()
                self.lastRank = self.rank
            }
            
            if self.minDelegate != nil && self.minDelegate!.value > self.value {
                self.minDelegate?.value = self.value
                self.minDelegate?.setThumbImage()
            }
            
            if self.maxDelegate != nil && self.maxDelegate!.value < self.value {
                self.maxDelegate?.value = self.value
                self.maxDelegate?.setThumbImage()
            }
        }
    }
    
    // MARK: - Methods
    
    func setThumbImage() {
        let imageName = self.slider_icon + String(self.rank)
        let image = UIImage(named: imageName)
        
        DispatchQueue.main.async {
            self.setThumbImage(image, for: .normal)
        }
    }
}

// MARK: - Protocol CardSliderDelegate

protocol CardSliderDelegate {
    var value: Float { get set }
    func setThumbImage()
}
