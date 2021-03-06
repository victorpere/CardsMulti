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
    let popoverWidth: CGFloat = 375
    
    let storedSettings = StoredSettings()
    let selectedSettings: TemporarySettings
    var selectedConfig: GameConfig
    
    var tableView: UITableView!
    var delegate: SettingsTableControllerDelegate!
    
    weak var minSlider: CardSlider?
    weak var maxSlider: CardSlider?
    
    var jackSwitch: Switch!
    var queenSwitch: Switch!
    var kingSwitch: Switch!
    var aceSwitch: Switch!
    
    var cardScaleSlider: UISlider!
    var soundSwitch: Switch!
        
    var elementWidth: CGFloat = 0
    
    // MARK: - Computed properties
    
    var gameHasBeenChanged: Bool {
        return self.selectedSettings.game != self.storedSettings.game
    }
    
    var settingsHaveBeenChanged: Bool {
        if self.storedSettings.minRank != self.selectedSettings.minRank ||
            self.storedSettings.maxRank != self.selectedSettings.maxRank ||
            self.storedSettings.pipsEnabled != self.selectedSettings.pipsEnabled ||
            self.storedSettings.jacksEnabled != self.jackSwitch.isOn ||
            self.storedSettings.queensEnabled != self.queenSwitch.isOn ||
            self.storedSettings.kingsEnabled != self.kingSwitch.isOn ||
            self.storedSettings.acesEnabled != self.aceSwitch.isOn {
            return true
        }
        return false
    }
    
    // MARK: - Initializers
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.selectedSettings = TemporarySettings(with: self.storedSettings)
        self.selectedConfig = GameConfig(gameType: GameType(rawValue: selectedSettings.game) ?? .freePlay)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let popOverVC = self.parent?.popoverPresentationController {
            if UIPopoverArrowDirection.unknown.rawValue > popOverVC.arrowDirection.rawValue {
                self.view.frame = CGRect(origin: self.view.frame.origin, size: CGSize(width: self.popoverWidth, height: self.view.frame.height))
            }
        }
        
        self.view.backgroundColor = .white
        self.title = "settings".localized
        
        self.elementWidth = self.view.frame.width / 2
        
        self.jackSwitch = Switch(width: elementWidth)
        self.queenSwitch = Switch(width: elementWidth)
        self.kingSwitch = Switch(width: elementWidth)
        self.aceSwitch = Switch(width: elementWidth)
        
        self.jackSwitch.isOn = self.storedSettings.jacksEnabled
        self.queenSwitch.isOn = self.storedSettings.queensEnabled
        self.kingSwitch.isOn = self.storedSettings.kingsEnabled
        self.aceSwitch.isOn = self.storedSettings.acesEnabled
        
        self.cardScaleSlider = UISlider(frame: CGRect(x: 0, y: 0, width: self.view.frame.width / 2, height: self.standardRowHeight))
        self.cardScaleSlider.minimumValue = -StoredSettings.maxCardWidthsPerScreen
        self.cardScaleSlider.maximumValue = -StoredSettings.minCardWidthsPerScreen
        self.cardScaleSlider.value = -StoredSettings.instance.cardWidthsPerScreen
        
        self.soundSwitch = Switch(width: elementWidth)
        self.soundSwitch.isOn = self.storedSettings.soundOn
        self.soundSwitch.onValueChanged = { () in
            self.storedSettings.soundOn = self.soundSwitch.isOn
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        self.tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.navigationController?.view.frame.height ?? self.view.frame.height), style: UITableView.Style.grouped)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionFooterHeight = 0
        
        self.gameSelected(ofType: GameType(rawValue: self.storedSettings.game))
        
        self.view.addSubview(self.tableView)
    }
    
    // MARK: - Actions
    
    @objc func done(sender: UIButton) {
        if self.gameHasBeenChanged {
            self.showActionDialog(title: "game will restart".localized, text: "are you sure?".localized, actionTitle: "ok".localized, action: {() -> Void in
                self.storedSettings.game = self.selectedSettings.game
                self.saveSettings()
                self.saveUISettings()
                self.delegate?.resetScores()
                self.delegate?.gameChanged()
                self.dismiss(animated: true, completion: nil)
            })
        } else if self.settingsHaveBeenChanged {
            self.showActionDialog(title: "game will restart".localized, text: "are you sure?".localized, actionTitle: "ok".localized, action: {() -> Void in
                self.saveSettings()
                self.saveUISettings()
                self.delegate?.settingsChanged()
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            self.saveUISettings()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Public methods
    
    func setFrameSize(to size: CGSize) {
        self.tableView.frame = CGRect(origin: self.tableView.frame.origin, size: size)
    }
    
    // MARK: - Private methods
    
    private func saveSettings() {
        self.storedSettings.minRank = self.selectedSettings.minRank
        self.storedSettings.maxRank = self.selectedSettings.maxRank
        
        self.storedSettings.pipsEnabled = self.selectedSettings.pipsEnabled
        self.storedSettings.jacksEnabled = self.jackSwitch.isOn
        self.storedSettings.queensEnabled = self.queenSwitch.isOn
        self.storedSettings.kingsEnabled = self.kingSwitch.isOn
        self.storedSettings.acesEnabled = self.aceSwitch.isOn
    }
    
    private func saveUISettings() {
        if StoredSettings.instance.cardWidthsPerScreen != -self.cardScaleSlider.value {
            StoredSettings.instance.cardWidthsPerScreen = -self.cardScaleSlider.value
            self.delegate?.uiSettingsChanged()
        }
    }
    
    private func gameSelected(ofType gameType: GameType?) {
        if let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType) {
            self.selectedConfig = gameConfig
            
            if !gameConfig.canChangeDeck {
                self.selectedSettings.pipsEnabled = gameConfig.defaultSettings.pipsEnabled
                self.selectedSettings.minRank = gameConfig.defaultSettings.minValue
                self.selectedSettings.maxRank = gameConfig.defaultSettings.maxValue
                self.jackSwitch.isOn = gameConfig.defaultSettings.jacksEnabled
                self.queenSwitch.isOn = gameConfig.defaultSettings.queensEnabled
                self.kingSwitch.isOn = gameConfig.defaultSettings.kingsEnabled
                self.aceSwitch.isOn = gameConfig.defaultSettings.acesEnabled
            }
            
            if !gameConfig.canChangeCardSize {
                self.cardScaleSlider.value = -gameConfig.defaultSettings.cardWidthsPerScreen
            }
            
            self.cardScaleSlider.isEnabled = gameConfig.canChangeCardSize
            self.jackSwitch.isEnabled = gameConfig.canChangeDeck
            self.queenSwitch.isEnabled = gameConfig.canChangeDeck
            self.kingSwitch.isEnabled = gameConfig.canChangeDeck
            self.aceSwitch.isEnabled = gameConfig.canChangeDeck
        } else {
            self.cardScaleSlider.isEnabled = true
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
            if indexPath.row != self.selectedSettings.game {
                self.selectedSettings.game = indexPath.row
                self.gameSelected(ofType: GameType(rawValue: self.selectedSettings.game))
                self.tableView.reloadSections(IndexSet([SettingsSection.game.rawValue, SettingsSection.cards1.rawValue]), with: .none)
            }
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
            if self.selectedSettings.pipsEnabled {
                return 3
            }
            return 1
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
                textEditCell.value.text = self.storedSettings.displayName
                textEditCell.value.delegate = textEditCell
                textEditCell.delegate = self
                
                return textEditCell
            default:
                break
            }
            
            break
        case SettingsSection.game.rawValue:
            if let gameConfig = GameConfigs.sharedInstance.gameConfig(for: GameType(rawValue: indexPath.row)), gameConfig.maxPlayers > 1 {
                cell.imageView?.image = UIImage(named: "icon_players")
            }
            
            cell.textLabel?.text = GameType(rawValue: indexPath.row)?.name
            
            if indexPath.row == self.selectedSettings.game {
                cell.accessoryType = .checkmark
            }
            
            break
        case SettingsSection.cards1.rawValue:
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "pip cards".localized
                
                let pipsSwitch = Switch(width: self.elementWidth)
                pipsSwitch.isOn = self.selectedSettings.pipsEnabled
                pipsSwitch.isEnabled = self.selectedConfig.canChangeDeck
                pipsSwitch.onValueChanged = { () in
                    self.selectedSettings.pipsEnabled = pipsSwitch.isOn
                    self.tableView.reloadSections(IndexSet(integer: SettingsSection.cards1.rawValue), with: .bottom)
                }
                cell.accessoryView = pipsSwitch
                
            case 1:
                cell.textLabel?.text = "minimum rank".localized
                
                let minSlider = CardSlider(width: elementWidth, initialRank: self.selectedSettings.minRank)
                minSlider.isEnabled = self.selectedConfig.canChangeDeck
                minSlider.onRankChanged = { () -> Void in
                    self.selectedSettings.minRank = minSlider.rank
                }
                self.minSlider = minSlider
                minSlider.maxSlider = self.maxSlider
                self.maxSlider?.minSlider = minSlider
                cell.accessoryView = minSlider
            case 2:
                cell.textLabel?.text = "maximum rank".localized
                
                let maxSlider = CardSlider(width: elementWidth, initialRank: self.selectedSettings.maxRank)
                maxSlider.isEnabled = self.selectedConfig.canChangeDeck
                maxSlider.onRankChanged = { () -> Void in
                    self.selectedSettings.maxRank = maxSlider.rank
                }
                self.maxSlider = maxSlider
                maxSlider.minSlider = self.minSlider
                self.minSlider?.maxSlider = maxSlider
                cell.accessoryView = maxSlider
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
        self.storedSettings.displayName = text
    }
}
