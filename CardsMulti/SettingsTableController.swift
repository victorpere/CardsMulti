//
//  SettingsTableController.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-15.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class SettingsTableContoller : UIViewController {
    let standardRowHeight: CGFloat = 44
    let sliderRowHeight:CGFloat = 53
    
    let settings = Settings()
    
    var gameConfigs: GameConfigs!
    
    var tableView: UITableView!
    var delegate: SettingsTableControllerDelegate!
    
    var minSlider: CardSlider!
    var maxSlider: CardSlider!
    var pipsSwitch: Switch!
    var jackSwitch: Switch!
    var queenSwitch: Switch!
    var kingSwitch: Switch!
    var aceSwitch: Switch!
    
    var cardScaleSlider: UISlider!
    var soundSwitch: Switch!
    
    // MARK: - Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.gameConfigs = GameConfigs(withFile: Config.configFilePath ?? "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let popOverVC = self.parent?.popoverPresentationController {
            if UIPopoverArrowDirection.unknown.rawValue > popOverVC.arrowDirection.rawValue {
                self.view.frame = CGRect(origin: self.view.frame.origin, size: CGSize(width: 375, height: self.view.frame.height))
            }
        }
        
        self.view.backgroundColor = .white
        self.title = "settings".localized
        
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
        
        self.cardScaleSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: self.standardRowHeight))
        self.cardScaleSlider.minimumValue = -Settings.maxCardWidthsPerScreen
        self.cardScaleSlider.maximumValue = -Settings.minCardWidthsPerScreen
        self.cardScaleSlider.value = -Settings.instance.cardWidthsPerScreen
        
        self.soundSwitch = Switch(width: elementWidth)
        self.soundSwitch.isOn = self.settings.soundOn
        self.soundSwitch.onValueChanged = { () in
            self.settings.soundOn = self.soundSwitch.isOn
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationController?.view.frame.height ?? self.view.frame.height), style: UITableView.Style.grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionFooterHeight = 0
        
        self.gameSelected()
        
        self.view.addSubview(self.tableView)
    }
    
    // MARK: - Actions
    
    @objc func done(sender: UIButton) {
        if settingsHaveChanged() {
            self.saveSettings()
        }

        self.saveUISettings()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public methods
    
    func setFrameSize(to size: CGSize) {
        self.tableView.frame = CGRect(origin: self.tableView.frame.origin, size: size)
    }
    
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
    
    private func saveUISettings() {
        if Settings.instance.cardWidthsPerScreen != -self.cardScaleSlider.value {
            Settings.instance.cardWidthsPerScreen = -self.cardScaleSlider.value
            self.delegate?.uiSettingsChanged()
        }
    }
    
    private func gameSelected() {
        if let gameConfig = self.gameConfigs.configs[GameType(rawValue: self.settings.game) ?? .freePlay] {
            self.cardScaleSlider.isEnabled = gameConfig.canChangeCardSize
            self.pipsSwitch.isEnabled = gameConfig.canChangeDeck
            self.minSlider.isEnabled = gameConfig.canChangeDeck
            self.maxSlider.isEnabled = gameConfig.canChangeDeck
            self.jackSwitch.isEnabled = gameConfig.canChangeDeck
            self.queenSwitch.isEnabled = gameConfig.canChangeDeck
            self.kingSwitch.isEnabled = gameConfig.canChangeDeck
            self.aceSwitch.isEnabled = gameConfig.canChangeDeck
        } else {
            self.cardScaleSlider.isEnabled = true
            self.pipsSwitch.isEnabled = true
            self.minSlider.isEnabled = true
            self.maxSlider.isEnabled = true
            self.jackSwitch.isEnabled = true
            self.queenSwitch.isEnabled = true
            self.kingSwitch.isEnabled = true
            self.aceSwitch.isEnabled = true
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingsTableContoller : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SettingsSection.game.rawValue:
            // reset score
            // TODO: create a score page
            self.delegate.resetScores()
            
            // change game
            if true || Settings.instance.game != indexPath.row {
                Settings.instance.game = indexPath.row
                self.gameSelected()
                self.delegate?.gameChanged()
            }
            
            self.dismiss(animated: true, completion: nil)
            break
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableContoller : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SettingsSection.player.rawValue:
            return 1
        case SettingsSection.game.rawValue:
            return GameType.allCases.count
        case SettingsSection.cards1.rawValue:
            return 3
        case SettingsSection.cards2.rawValue:
            return 4
        case SettingsSection.size.rawValue:
            return 1
        case SettingsSection.sound.rawValue:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SettingsSection.cards1.rawValue && (indexPath.row == 1 || indexPath.row == 2) {
            return self.sliderRowHeight
        }
        return self.standardRowHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let settingsSection = SettingsSection(rawValue: section) {
            return settingsSection.title
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        switch indexPath.section {
        case SettingsSection.player.rawValue:
            switch indexPath.row {
            case 0:
                let textEditCell = (UINib(nibName: "TextEditCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TextEditCell)!
                textEditCell.selectionStyle = .none
                textEditCell.name.text = "name".localized
                textEditCell.value.text = self.settings.displayName
                textEditCell.value.delegate = textEditCell
                textEditCell.delegate = self
                
                return textEditCell
            default:
                break
            }
            
            break
        case SettingsSection.game.rawValue:
            cell.textLabel?.text = GameType(rawValue: indexPath.row)?.name
            
            if Settings.instance.game == indexPath.row {
                cell.accessoryType = .checkmark
            }
            
            break
        case SettingsSection.cards1.rawValue:
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "pip cards".localized
                cell.accessoryView = self.pipsSwitch
            case 1:
                cell.textLabel?.text = "minimum rank".localized
                cell.accessoryView = self.minSlider
            case 2:
                cell.textLabel?.text = "maximum rank".localized
                cell.accessoryView = self.maxSlider
            default:
                break
            }
        case SettingsSection.cards2.rawValue:
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "jack".localized
                cell.accessoryView = self.jackSwitch
            case 1:
                cell.textLabel?.text = "queen".localized
                cell.accessoryView = self.queenSwitch
            case 2:
                cell.textLabel?.text = "king".localized
                cell.accessoryView = self.kingSwitch
            case 3:
                cell.textLabel?.text = "ace".localized
                cell.accessoryView = self.aceSwitch
            default:
                break
            }
        case SettingsSection.size.rawValue:
            cell.selectionStyle = .none
            cell.textLabel?.text = "card size".localized
            cell.accessoryView = self.cardScaleSlider
        case SettingsSection.sound.rawValue:
            cell.selectionStyle = .none
            cell.textLabel?.text = "sound".localized
            cell.accessoryView = self.soundSwitch
        default:
            break
        }
        
        return cell
    }
    
    
}

// MARK: - Protocol SettingsTableControllerDelegate

protocol SettingsTableControllerDelegate {
    func settingsChanged()
    func uiSettingsChanged()
    func gameChanged()
    func resetScores()
}

// MARK: - Enum sections

/**
 Enumeration of settings sections
 */
enum SettingsSection: Int, CaseIterable {
    case player = 0, game, cards1, cards2, size, sound
    
    var title: String? {
        switch self {
        case .player:
            return "player".localized
        case .game:
            return "game".localized
        case .cards1:
            return "cards".localized
        default:
            return nil
        }
    }
}

// MARK: - Protocol

extension SettingsTableContoller : TextEditCellDelegate {
    func didFinishEditing(_ text: String) {
        self.settings.displayName = text
    }
}
