//
//  SettingsViewController.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    
    // MARK: - Variables
    
    var delegate: SettingsViewControllerDelegate?
    
    let settings = Settings()
    
    var minRankSlider: UISlider!
    var maxRankSlider: UISlider!
    
    var pipsSwitch: UISwitch!
    var jackSwitch: UISwitch!
    var queenSwitch: UISwitch!
    var kingSwitch: UISwitch!
    var aceSwitch: UISwitch!
    
    var tableView: UITableView!
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "Settings"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let minRankLabel = UILabel(frame: CGRect(x: 10, y:30, width: self.view.frame.width / 2 - 10, height: 51))
        minRankLabel.text = "Minimum rank:"
        
        var sliderTrackImage = UIImage(named: "slider_frame")
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        sliderTrackImage = sliderTrackImage?.resizableImage(withCapInsets: insets)

        self.minRankSlider = UISlider(frame: CGRect(x: self.view.frame.width / 2, y: 30, width: self.view.frame.width / 2 - 10, height: 51))
        self.minRankSlider.minimumValue = 3
        self.minRankSlider.maximumValue = 10
        self.minRankSlider.value = Float(settings.minRank)
        self.minRankSlider.addTarget(self, action: #selector(minRankSliderChanged), for: .valueChanged)
        self.minRankSlider.setMinimumTrackImage(sliderTrackImage, for: .normal)
        self.minRankSlider.setMaximumTrackImage(sliderTrackImage, for: .normal)
        self.setSliderThumbImage(slider: self.minRankSlider)
        
        let maxRankLabel = UILabel(frame: CGRect(x: 10, y:100, width: self.view.frame.width / 2 - 10, height: 51))
        maxRankLabel.text = "Maximum rank:"
        
        self.maxRankSlider = UISlider(frame: CGRect(x: self.view.frame.width / 2, y: 100, width: self.view.frame.width / 2 - 10, height: 51))
        self.maxRankSlider.minimumValue = 3
        self.maxRankSlider.maximumValue = 10
        self.maxRankSlider.value = Float(settings.maxRank)
        self.maxRankSlider.addTarget(self, action: #selector(maxRankSliderChanged), for: .valueChanged)
        self.maxRankSlider.setMinimumTrackImage(sliderTrackImage, for: .normal)
        self.maxRankSlider.setMaximumTrackImage(sliderTrackImage, for: .normal)
        self.setSliderThumbImage(slider: self.maxRankSlider)
        
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

        self.pipsSwitch = Switch(frame: CGRect(x: self.view.frame.width / 2, y: 170, width: self.view.frame.width / 2 - 10, height: 51))
        self.pipsSwitch.isOn = settings.pips
        self.jackSwitch = Switch(frame: CGRect(x: self.view.frame.width / 2, y: 230, width: self.view.frame.width / 2 - 10, height: 51))
        self.jackSwitch.isOn = settings.jack
        self.queenSwitch = Switch(frame: CGRect(x: self.view.frame.width / 2, y: 290, width: self.view.frame.width / 2 - 10, height: 51))
        self.queenSwitch.isOn = settings.queen
        self.kingSwitch = Switch(frame: CGRect(x: self.view.frame.width / 2, y: 350, width: self.view.frame.width / 2 - 10, height: 51))
        self.kingSwitch.isOn = settings.king
        self.aceSwitch = Switch(frame: CGRect(x: self.view.frame.width / 2, y: 410, width: self.view.frame.width / 2 - 10, height: 51))
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
    }
    
    @objc func minRankSliderChanged(sender: UISlider) {
        setSliderThumbImage(slider: sender)
        if sender.value > self.maxRankSlider.value {
            DispatchQueue.main.async {
                self.maxRankSlider.value = sender.value
                self.setSliderThumbImage(slider: self.maxRankSlider)
            }
        }
    }
    
    @objc func maxRankSliderChanged(sender: UISlider) {
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
    
    @objc func done(sender: UIButton) {
        var minRankValue = Int(self.minRankSlider.value)
        if self.minRankSlider.value == 3.0 {
            minRankValue = 2
        }
        var maxRankValue = Int(self.maxRankSlider.value)
        if self.maxRankSlider.value == 3.0 {
            maxRankValue = 2
        }
        
        if minRankValue != self.settings.minRank ||
            maxRankValue != self.settings.maxRank ||
            self.pipsSwitch.isOn != self.settings.pips ||
            self.jackSwitch.isOn != self.settings.jack ||
            self.queenSwitch.isOn != self.settings.queen ||
            self.kingSwitch.isOn != self.settings.king ||
            self.aceSwitch.isOn != self.settings.ace {
            
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
    }
    
    func saveSettingsAndExit() {
        DispatchQueue.main.async {
            var minRankValue = Int(self.minRankSlider.value)
            if self.minRankSlider.value == 3.0 {
                minRankValue = 2
            }
            var maxRankValue = Int(self.maxRankSlider.value)
            if self.maxRankSlider.value == 3.0 {
                maxRankValue = 2
            }
            
            self.settings.minRank = minRankValue
            self.settings.maxRank = maxRankValue
            self.settings.pips = self.pipsSwitch.isOn
            self.settings.jack = self.jackSwitch.isOn
            self.settings.queen = self.queenSwitch.isOn
            self.settings.king = self.kingSwitch.isOn
            self.settings.ace = self.aceSwitch.isOn
            
            self.delegate?.settingsChanged()
        
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension SettingsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        default:
            break
        }
        return UITableViewCell()
    }
}

extension SettingsViewController : UITableViewDelegate {
    
}

protocol SettingsViewControllerDelegate {
    func settingsChanged()
}

