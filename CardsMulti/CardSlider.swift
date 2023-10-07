//
//  CardSlider.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-03.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class CardSlider : UISlider {
    let slider_icon = "icon_card_slider"
    let slider_track = "slider_frame"
    let MIN: Float = 2.0
    let MAX: Float = 10.0
    let minRank: Int
    let maxRank: Int
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    var thumbImages = Dictionary<Int, UIImage>()
    
    weak var minSlider: CardSlider?
    weak var maxSlider: CardSlider?
    
    var rank: Int { Int(round(self.value)) }
    var lastRank: Int!
    
    /// Action to be performed when the rank has changed
    var onRankChanged: () -> Void = { () in }
    
    // MARK: - Initializers
    
    convenience init(width: CGFloat, initialRank: Int) {
        let frame = CGRect(x: 0, y: 0, width: width, height: 51)
        self.init(frame: frame)
        self.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        self.addTarget(self, action: #selector(stoppedMoving), for: .touchUpInside)
        self.addTarget(self, action: #selector(stoppedMoving), for: .touchUpOutside)
        self.minimumValue = MIN
        self.maximumValue = MAX
        
        self.initThumbImages()
        
        var sliderTrackImage = UIImage(named: self.slider_track)
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sliderTrackImage = sliderTrackImage?.resizableImage(withCapInsets: insets)
        self.setMinimumTrackImage(sliderTrackImage, for: .normal)
        self.setMaximumTrackImage(sliderTrackImage, for: .normal)
        
        self.value = Float(initialRank)
        self.lastRank = initialRank
        self.setThumbImage()
    }
    
    private override init(frame: CGRect) {
        self.minRank = Int(self.MIN)
        self.maxRank = Int(self.MAX)
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
        if self.rank != self.lastRank {
            self.setThumbImage()
            self.selectionFeedbackGenerator.selectionChanged()
            self.lastRank = self.rank
            self.onRankChanged()
        }

        if self.minSlider?.value ?? self.MIN > self.value {
            self.minSlider?.setValue(to: self.value)
        }

        if self.maxSlider?.value ?? self.MAX < self.value {
            self.maxSlider?.setValue(to: self.value)
        }
    }
    
    @objc func stoppedMoving(sender: CardSlider) {
        self.value = Float(self.rank)
    }
    
    // MARK: - Public methods
    
    func setValue(to newValue: Float) {
        self.value = newValue
        
        if self.rank != self.lastRank {
            self.setThumbImage()
            self.lastRank = self.rank
        }
    }
    
    // MARK: - Private methods
    
    private func setThumbImage() {
        DispatchQueue.main.async {
            self.setThumbImage(self.thumbImages[self.rank], for: .normal)
        }
    }
    
    private func initThumbImages() {
        for i in self.minRank...self.maxRank {
            let imageName = self.slider_icon + String(i)
            let image = UIImage(named: imageName)
            self.thumbImages[i] = image
        }
    }
}
