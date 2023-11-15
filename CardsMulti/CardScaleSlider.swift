//
//  CardScaleSlider.swift
//  CardsMulti
//
//  Created by Victor on 2021-11-27.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit

class CardScaleSlider : UISlider {
    
    let sliderIconImageName = "back"
    let sliderTrackImageName = "slider_frame"
    let sliderCGImage: CGImage?
    
    weak var settingsTableController: SettingsTableContoller?
    
    private let screenWidth: Float // = Float(UIScreen.main.bounds.width)
    
    // MARK: - Computed properties
    
    var widthsPerScreen: Float {
        get {
            return self.screenWidth / self.value
        }
        set(newWidthsPerScreen) {
            self.value = self.screenWidth / newWidthsPerScreen
            self.updateThumbImage()
            self.updateRowHeight()
        }
    }
    
    // MARK: - Initializers
    
    init(width: CGFloat, viewWidth: CGFloat) {
        let sliderIconImage = UIImage(named: self.sliderIconImageName)
        self.sliderCGImage = sliderIconImage?.cgImage
        self.screenWidth = Float(viewWidth)

        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 51))
        
        var sliderTrackImage = UIImage(named: self.sliderTrackImageName)
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        sliderTrackImage = sliderTrackImage?.resizableImage(withCapInsets: insets)
        self.setMinimumTrackImage(sliderTrackImage, for: .normal)
        self.setMaximumTrackImage(sliderTrackImage, for: .normal)
        
        self.minimumValue = self.screenWidth / Config.maxCardWidthsPerScreen
        self.maximumValue = self.screenWidth / Config.minCardWidthsPerScreen
        self.value = self.screenWidth / StoredSettings.instance.cardWidthsPerScreen
        
        self.updateThumbImage()
        self.addTarget(self, action: #selector(sliderMoved), for: .valueChanged)
        self.addTarget(self, action: #selector(sliderMoveDidEnd), for: .touchUpInside)
        self.addTarget(self, action: #selector(sliderMoveDidEnd), for: .touchUpOutside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Events
    
    @objc private func sliderMoved() {
        self.updateThumbImage()
    }
    
    @objc private func sliderMoveDidEnd() {
        print("size slider move end")
        self.settingsTableController?.selectedSettings.cardWidthsPerScreen = self.widthsPerScreen
        self.updateRowHeight()
    }
    
    // MARK: - Private methods
    
    private func updateThumbImage() {
        if let cgImage = self.sliderCGImage {
            let scale = Float(cgImage.width) / self.value
            let thumbImage = UIImage(cgImage: cgImage, scale: CGFloat(scale), orientation: .up)
            self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: thumbImage.size.height)
            self.setThumbImage(thumbImage, for: .normal)
        }
    }
    
    private func updateRowHeight() {
        //self.settingsTableController?.tableView.reloadData()
        
        self.settingsTableController?.tableView.reloadRows(at: [IndexPath(row: 0, section: SettingsSection.size.rawValue)], with: .automatic)
    }
}
