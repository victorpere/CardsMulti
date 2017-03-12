//
//  SettingsViewController.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    var delegate: SettingsViewControllerDelegate?
    
    let settings = Settings()
    
    var minRankSlider: UISlider!
    var maxRankSlider: UISlider!
    
    var pipsSwitch: UISwitch!
    var jackSwitch: UISwitch!
    var queenSwitch: UISwitch!
    var kingSwitch: UISwitch!
    var aceSwitch: UISwitch!
    
    var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        let minRankLabel = UILabel(frame: CGRect(x: 10, y:30, width: self.view.frame.width / 2 - 10, height: 51))
        minRankLabel.text = "Minimum rank:"
        
        self.minRankSlider = UISlider(frame: CGRect(x: self.view.frame.width / 2, y: 30, width: self.view.frame.width / 2 - 10, height: 51))
        self.minRankSlider.minimumValue = 3
        self.minRankSlider.maximumValue = 10
        self.minRankSlider.value = Float(settings.minRank)
        self.minRankSlider.addTarget(self, action: #selector(minRankSliderChanged), for: .valueChanged)
        self.setSliderThumbImage(slider: self.minRankSlider)
        
        let maxRankLabel = UILabel(frame: CGRect(x: 10, y:100, width: self.view.frame.width / 2 - 10, height: 51))
        maxRankLabel.text = "Maximum rank:"
        
        self.maxRankSlider = UISlider(frame: CGRect(x: self.view.frame.width / 2, y: 100, width: self.view.frame.width / 2 - 10, height: 51))
        self.maxRankSlider.minimumValue = 3
        self.maxRankSlider.maximumValue = 10
        self.maxRankSlider.value = Float(settings.maxRank)
        self.maxRankSlider.addTarget(self, action: #selector(maxRankSliderChanged), for: .valueChanged)
        self.setSliderThumbImage(slider: self.maxRankSlider)
        
        self.doneButton = UIButton(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50))
        self.doneButton.setTitle("Done", for: .normal)
        self.doneButton.setTitleColor(.black, for: .normal)
        self.doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        self.doneButton.tag = 1
        
        let pipsLabel = UILabel(frame: CGRect(x: 10, y: 170, width: self.view.frame.width / 2 - 10, height: 51))
        pipsLabel.text = "Pip cards:"
        let jackLabel = UILabel(frame: CGRect(x: 10, y: 230, width: self.view.frame.width / 2 - 10, height: 51))
        jackLabel.text = "Jack:"
        let queenLabel = UILabel(frame: CGRect(x: 10, y: 290, width: self.view.frame.width / 2 - 10, height: 51))
        queenLabel.text = "Queen:"
        let kingLabel = UILabel(frame: CGRect(x: 10, y: 350, width: self.view.frame.width / 2 - 10, height: 51))
        kingLabel.text = "King:"
        let aceLabel = UILabel(frame: CGRect(x: 10, y: 410, width: self.view.frame.width / 2 - 10, height: 51))
        aceLabel.text = "Ace:"

        self.pipsSwitch = UISwitch(frame: CGRect(x: self.view.frame.width / 2, y: 170, width: self.view.frame.width / 2 - 10, height: 51))
        self.pipsSwitch.isOn = settings.pips
        self.jackSwitch = UISwitch(frame: CGRect(x: self.view.frame.width / 2, y: 230, width: self.view.frame.width / 2 - 10, height: 51))
        self.jackSwitch.isOn = settings.jack
        self.queenSwitch = UISwitch(frame: CGRect(x: self.view.frame.width / 2, y: 290, width: self.view.frame.width / 2 - 10, height: 51))
        self.queenSwitch.isOn = settings.queen
        self.kingSwitch = UISwitch(frame: CGRect(x: self.view.frame.width / 2, y: 350, width: self.view.frame.width / 2 - 10, height: 51))
        self.kingSwitch.isOn = settings.king
        self.aceSwitch = UISwitch(frame: CGRect(x: self.view.frame.width / 2, y: 410, width: self.view.frame.width / 2 - 10, height: 51))
        self.aceSwitch.isOn = settings.ace

        self.view.addSubview(minRankLabel)
        self.view.addSubview(maxRankLabel)
        self.view.addSubview(self.minRankSlider)
        self.view.addSubview(self.maxRankSlider)
        self.view.addSubview(pipsLabel)
        self.view.addSubview(jackLabel)
        self.view.addSubview(queenLabel)
        self.view.addSubview(kingLabel)
        self.view.addSubview(aceLabel)
        self.view.addSubview(self.pipsSwitch)
        self.view.addSubview(self.jackSwitch)
        self.view.addSubview(self.queenSwitch)
        self.view.addSubview(self.kingSwitch)
        self.view.addSubview(self.aceSwitch)
        self.view.addSubview(self.doneButton)
    }
    
    func minRankSliderChanged(sender: UISlider) {
        setSliderThumbImage(slider: sender)
        if sender.value > self.maxRankSlider.value {
            DispatchQueue.main.async {
                self.maxRankSlider.value = sender.value
                self.setSliderThumbImage(slider: self.maxRankSlider)
            }
        }
    }
    
    func maxRankSliderChanged(sender: UISlider) {
        setSliderThumbImage(slider: sender)
        if sender.value < self.minRankSlider.value {
            DispatchQueue.main.async {
                self.minRankSlider.value = sender.value
                self.setSliderThumbImage(slider: self.minRankSlider)
            }
        }
    }
    
    func setSliderThumbImage(slider: UISlider) {
        if slider.value >= 3 && slider.value <= 10 {
            var cardValue = Int(slider.value)
            if slider.value == 3.0 {
                cardValue = 2
            }
            let imageName = "icon_card_slider" + String(cardValue)
            let image = UIImage(named: imageName)
            slider.setThumbImage(image, for: .normal)
        }
    }
    
    func done(sender: UIButton) {
        switch sender.tag {
        case 1:
            var minRankValue = Int(self.minRankSlider.value)
            if self.minRankSlider.value == 3.0 {
                minRankValue = 2
            }
            var maxRankValue = Int(self.maxRankSlider.value)
            if self.maxRankSlider.value == 3.0 {
                maxRankValue = 2
            }
            
            if minRankValue != settings.minRank ||
                maxRankValue != settings.maxRank ||
                self.pipsSwitch.isOn != settings.pips ||
                self.jackSwitch.isOn != settings.jack ||
                self.queenSwitch.isOn != settings.queen ||
                self.kingSwitch.isOn != settings.king ||
                self.aceSwitch.isOn != settings.ace {
                
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Settings have changed, are you sure you want to proceed? (Game will be restarted)", message: nil, preferredStyle: .alert)
                    let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert) -> Void in
                        self.saveSettingsAndExit()
                    } )
                    let cancelButton = UIAlertAction(title: "No", style: .cancel) { (alert) -> Void in }
                    
                    
                    alert.addAction(cancelButton)
                    alert.addAction(yesAction)
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        default: break
        }
    }
    
    func saveSettingsAndExit() {
        var minRankValue = Int(self.minRankSlider.value)
        if self.minRankSlider.value == 3.0 {
            minRankValue = 2
        }
        var maxRankValue = Int(self.maxRankSlider.value)
        if self.maxRankSlider.value == 3.0 {
            maxRankValue = 2
        }
        
        settings.minRank = minRankValue
        settings.maxRank = maxRankValue
        settings.pips = self.pipsSwitch.isOn
        settings.jack = self.jackSwitch.isOn
        settings.queen = self.queenSwitch.isOn
        settings.king = self.kingSwitch.isOn
        settings.ace = self.aceSwitch.isOn
        
        self.delegate?.settingsChanged()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

protocol SettingsViewControllerDelegate {
    func settingsChanged()
}

