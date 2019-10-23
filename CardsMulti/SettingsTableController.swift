//
//  SettingsTableController.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-15.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class SettingsTableContoller : UIViewController {
    let stadardRowHeight: CGFloat = 44
    let sliderRowHeight:CGFloat = 53
    
    let numberOfSections = 2
    let settings = Settings()
    
    var tableView: UITableView!
    var delegate: SettingsTableControllerDelegate!
    
    var minSlider: CardSlider!
    var maxSlider: CardSlider!
    var pipsSwitch: Switch!
    var jackSwitch: Switch!
    var queenSwitch: Switch!
    var kingSwitch: Switch!
    var aceSwitch: Switch!
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "Settings"
        
        let elementWidth = self.view.frame.width / 2
        
        self.minSlider = CardSlider(width: elementWidth, initialRank: self.settings.minRank)
        self.maxSlider = CardSlider(width: elementWidth, initialRank: self.settings.maxRank)
        
        self.minSlider.maxDelegate = self.maxSlider
        self.maxSlider.minDelegate = self.minSlider
        
        self.pipsSwitch = Switch(width: elementWidth)
        self.jackSwitch = Switch(width: elementWidth)
        self.queenSwitch = Switch(width: elementWidth)
        self.kingSwitch = Switch(width: elementWidth)
        self.aceSwitch = Switch(width: elementWidth)
        
        self.pipsSwitch.isOn = self.settings.pips
        self.jackSwitch.isOn = self.settings.jack
        self.queenSwitch.isOn = self.settings.queen
        self.kingSwitch.isOn = self.settings.king
        self.aceSwitch.isOn = self.settings.ace
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), style: UITableView.Style.grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.view.addSubview(self.tableView)
    }
    
    // MARK: - Actions
    
    @objc func done(sender: UIButton) {
        if settingsHaveChanged() {
            self.saveSettings()
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public methods
    
    func settingsHaveChanged() -> Bool {
        if self.settings.minRank != self.minSlider.rank ||
            self.settings.maxRank != self.maxSlider.rank ||
            self.settings.pips != self.pipsSwitch.isOn ||
            self.settings.jack != self.jackSwitch.isOn ||
            self.settings.queen != self.queenSwitch.isOn ||
            self.settings.king != self.kingSwitch.isOn ||
            self.settings.ace != self.aceSwitch.isOn {
            return true
        }
        return false
    }
    
    // MARK: - Private methods
    
    private func saveSettings() {
        self.settings.minRank = self.minSlider.rank
        self.settings.maxRank = self.maxSlider.rank
        
        self.settings.pips = self.pipsSwitch.isOn
        self.settings.jack = self.jackSwitch.isOn
        self.settings.queen = self.queenSwitch.isOn
        self.settings.king = self.kingSwitch.isOn
        self.settings.ace = self.aceSwitch.isOn
        
        self.delegate?.settingsChanged()
    }
}

// MARK: - UITableViewDelegate

extension SettingsTableContoller : UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension SettingsTableContoller : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2) {
            return self.sliderRowHeight
        }
        return self.stadardRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 0:
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Pip cards"
                cell.accessoryView = self.pipsSwitch
            case 1:
                cell.textLabel?.text = "Minimum rank"
                cell.accessoryView = self.minSlider
            case 2:
                cell.textLabel?.text = "Maximum rank"
                cell.accessoryView = self.maxSlider
            default:
                break
            }
        case 1:
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Jack"
                cell.accessoryView = self.jackSwitch
            case 1:
                cell.textLabel?.text = "Queen"
                cell.accessoryView = self.queenSwitch
            case 2:
                cell.textLabel?.text = "King"
                cell.accessoryView = self.kingSwitch
            case 3:
                cell.textLabel?.text = "Ace"
                cell.accessoryView = self.aceSwitch
            default:
                break
            }
        default:
            break
        }
        
        return cell
    }
    
    
}

// MARK: - Protocol SettingsTableControllerDelegate

protocol SettingsTableControllerDelegate {
    func settingsChanged()
}
