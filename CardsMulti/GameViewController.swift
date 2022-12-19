//
//  GameViewController.swift
//  CardsMulti
//
//  Created by Victor on 2017-02-10.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import MultipeerConnectivity
import ContactsUI
import MessageUI

class GameViewController: UIViewController {
        
    let buttonMargin: CGFloat = 8.0
    let numberOfButtons: CGFloat = 5
    
    let connectionService = ConnectionServiceManager()
    
    var safeFrame: CGRect!
    var configured = false
    
    var connectionsLabel: UILabel!
    var positionLabel: UILabel!
    var playerLeftLabel: PlayerStatusLabel!
    var playerAcrossLabel: PlayerStatusLabel!
    var playerRightLabel: PlayerStatusLabel!
    var awsStatusLabel: UILabel!
    var flashMessageLabel: FlashMessageLabel!
    
    var backGroundView: UIView!
    var skView: SKView!
    var scene: GameScene!
    
    var buttons: [BottomButton] = []
//    var restartButton: BottomButton!
//    var settingsButton: BottomButton!
//    var numberOfPlayersButton: BottomButton!
//    var lineUpCardsButton: BottomButton!
//    var sortCardsButton: BottomButton!
//    var scoresButton: BottomButton!
    
    // MARK: - View methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectionService.delegate = self
        self.configured = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.configured {
            return
        }
        
        // Configure the view.
                
        self.configured = true
        
        self.safeFrame = CGRect(x: self.view.safeAreaInsets.left,
                                y: self.view.safeAreaInsets.top,
                                width: self.view.frame.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,
                                height: self.view.frame.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom)
        
        let playersIcon = (UIImage(named: "icon_players"))!
        
        let barHeight = playersIcon.size.height + 2 * buttonMargin
        
        self.backGroundView = UIView(frame: view.frame)
        self.backGroundView.backgroundColor = UIColor.black
        self.backGroundView.backgroundColor = UIColor(patternImage: UIImage(named: UIDevice.current.backgroundFileName)!)
        self.view.addSubview(self.backGroundView)
        
        self.connectionsLabel = UILabel(frame: CGRect(x: self.view.safeAreaInsets.left, y: self.view.frame.width, width: self.safeFrame.width, height: 15))
        self.connectionsLabel.textColor = UIColor.green
        self.connectionsLabel.font = UIFont(name: "Helvetica", size: 12)
        self.connectionsLabel.text = "\("connections".localized): "
        self.view.addSubview(self.connectionsLabel)
        
        self.flashMessageLabel = FlashMessageLabel(frame: CGRect(center: CGPoint(x: self.safeFrame.midX, y: self.safeFrame.width + 15), size: CGSize(width: self.safeFrame.width, height: 40)))
        self.view.addSubview(self.flashMessageLabel)
        
        self.awsStatusLabel = UILabel(frame: CGRect(x: self.view.frame.width - self.view.safeAreaInsets.right - 35, y: self.view.frame.width, width: 35, height: 15))
        self.awsStatusLabel.textColor = UIColor.green
        self.awsStatusLabel.font = UIFont(name: "Helvetica", size: 12)
        self.view.addSubview(self.awsStatusLabel)
        
        self.playerAcrossLabel = PlayerStatusLabel(withFrameDimension: self.safeFrame.width, inPosition: .top, withInsets: self.view.safeAreaInsets)
        self.view.addSubview(self.playerAcrossLabel)
        
        self.playerLeftLabel = PlayerStatusLabel(withFrameDimension: self.safeFrame.width, inPosition: .left, withInsets: self.view.safeAreaInsets)
        self.view.addSubview(self.playerLeftLabel)
        
        self.playerRightLabel = PlayerStatusLabel(withFrameDimension: self.safeFrame.width, inPosition: .right, withInsets: self.view.safeAreaInsets)
        self.view.addSubview(self.playerRightLabel)

        self.positionLabel = UILabel(frame: CGRect(x: 0, y: 15, width: self.view.frame.width, height: 120))
        self.positionLabel.textColor = UIColor.green
        self.positionLabel.font = UIFont(name: "Helvetica", size: 10)
        self.positionLabel.numberOfLines = 0
        self.positionLabel.text = "\(self.connectionService.myPeerId)\n\(self.connectionService.myPosition)\n"
        for player in self.connectionService.players {
            self.positionLabel.text?.append("\(String(describing: player))\n")
        }
        self.view.addSubview(self.positionLabel)
        self.positionLabel.isHidden = true
        
        self.setUpButtons()
        
        let sceneFrame = CGRect(x: self.safeFrame.minX,
                                y: self.safeFrame.minY,
                                width: self.safeFrame.width,
                                height: self.safeFrame.height - barHeight)
        self.skView = SKView(frame: sceneFrame)
        self.view.addSubview(self.skView)
        
        self.skView.showsFPS = false
        self.skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView.ignoresSiblingOrder = true
        self.skView.allowsTransparency = true
        
        //self.skView.isMultipleTouchEnabled = true
        
        self.startGame(loadFromSave: true)
    }
    
    // MARK: - Action methods
    
    @objc func buttonAction(sender: BottomButton) {
        switch sender.name {
        case "restart":
            self.scene.restartGame(sync: true)
            break
        case "players":
            if self.connectionService.connected {
                self.showConnectedMenu(fromButton: sender)
            } else {
                self.showNotConnectedMenu(fromButton: sender)
            }
            break
        case "settings":
            self.openSettings(fromButton: sender)
            break
        default:
            if let buttonName = sender.name {
                self.scene.performAction(action: buttonName)
            }
            break
        }
    }
    
    // MARK: - Public methods
    
    func saveGame() {
        self.scene.saveGame()
    }
    
    func showNotConnectedMenu(fromButton button: BottomButton) {
        if let gameConfig = GameConfigs.sharedInstance.gameConfig(for: self.scene.gameType), gameConfig.maxPlayers < 2 {
            self.showActionDialog(title: "sigle player game".localized, text: "you can switch to a multiplayer game in settings".localized, actionTitle: "open settings".localized, action: { () -> Void in
                self.openSettings(fromButton: button)
            })
            return
        }
        
        var title = "create or join a game".localized
        if self.connectionService.foundPeers.count > 0 {
            title = "Join a nearby device, or create or join a remote game"
        }
        
        let peerBrowser = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for peerID in self.connectionService.foundPeers {
            let peerAction = UIAlertAction(title: String(format: "join %@".localized, peerID.displayName), style: .default, handler: { (alert) -> Void in
                self.connectionService.invitePeer(peerID)
            } )
            peerBrowser.addAction(peerAction)
        }
        
        // button to create AWS game
        let createGameAction = UIAlertAction(title: "invite a friend to join".localized, style: .default,
                                             handler: { (alert) -> Void in
                                                self.connectionService.createGame()
        })
        peerBrowser.addAction(createGameAction)
        
        // button to join AWS game
        let joinGameAction = UIAlertAction(title: "join a game".localized, style: .default, handler: { (alert) -> Void in
            self.showTextDialog(title: "join a game".localized, text: "game code".localized, keyboardType: .numberPad, okAction: { (gameCode) -> Void in
                self.connectionService.findGames(withGameCode: gameCode)
            })
        })
        peerBrowser.addAction(joinGameAction)
        
        let cancelButton = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in }
        peerBrowser.addAction(cancelButton)
        
        let presentationController = peerBrowser.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = button
        presentationController?.sourceRect = button.bounds
        
        self.present(peerBrowser, animated: true, completion: nil)
    }
    
    func showConnectedMenu(fromButton button: BottomButton) {
        var title: String?
        if let gameCode = self.connectionService.gameCode {
            title = "\("connected to game".localized) \(gameCode)"
        }
        
        let connectionAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let inviteButton = UIAlertAction(title: "invite a friend to join".localized, style: .default, handler: { (alert) -> Void in
            self.createInvitation(fromButton: button)
        })
        
        let disconnectButton = UIAlertAction(title: "disconnect from the game".localized, style: .default, handler: { (alert) -> Void in
            self.connectionService.disconnectFromGame()
            self.connectionService.disconnect()
        } )
        let cancelButton = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in }
        
        connectionAlert.addAction(inviteButton)
        connectionAlert.addAction(disconnectButton)
        connectionAlert.addAction(cancelButton)
        
        let presentationController = connectionAlert.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = button
        presentationController?.sourceRect = button.bounds
        
        self.present(connectionAlert, animated: true, completion: nil)
    }
    
    func openSettings(fromButton button: BottomButton) {
        let settingsViewController = SettingsTableContoller(nibName: nil, bundle: nil)
        settingsViewController.delegate = self
        let navSettingsViewController = UINavigationController(rootViewController: settingsViewController)
        navSettingsViewController.modalPresentationStyle = .popover
        settingsViewController.preferredContentSize = CGSize(width: 375, height: 676)
        
        let presentationController = navSettingsViewController.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = button
        presentationController?.sourceRect = button.bounds
        
        self.present(navSettingsViewController, animated: true, completion: nil)
    }
    
    func openScores(fromButton button: BottomButton) {
        let scoresViewController = ScoresViewController(withScene: self.scene)
        
        let navScoresViewController = UINavigationController(rootViewController: scoresViewController)
        navScoresViewController.modalPresentationStyle = .popover
        scoresViewController.preferredContentSize = CGSize(width: 375, height: 676)
        
        let presentationConroller = navScoresViewController.popoverPresentationController
        presentationConroller?.permittedArrowDirections = .down
        presentationConroller?.sourceView = button
        presentationConroller?.sourceRect = button.bounds
        
        self.present(navScoresViewController, animated: true, completion: nil)
    }
    
    func checkForceTouch() {
        if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            print("force touch available")
            if self.scene != nil {
                self.scene.forceTouchEnabled = true
            }
        }
    }


    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func updateLabels() {
        DispatchQueue.main.async {
            self.positionLabel.text = "\(self.connectionService.myPeerId)\n\(self.connectionService.myPosition)\n"
            for player in self.connectionService.players {
                self.positionLabel.text?.append("\(String(describing: player))\n")
            }
        }
    }
    
    func updatePlayerLabels() {
        DispatchQueue.global(qos: .default).async {
            let positionToLeft = self.connectionService.myPosition.positionToLeft
            let positionAcross = self.connectionService.myPosition.positionAcross
            let positionToRight = self.connectionService.myPosition.positionToRight
            if let playerToLeft = self.connectionService.players[positionToLeft.rawValue] {
                //self.playerLeftLabel.text = playerToLeft.displayName
                self.playerLeftLabel.update(playerName: playerToLeft.displayName)
            } else {
                //self.playerLeftLabel.text = ""
                self.playerLeftLabel.update(playerName: "")
            }
            if let playerAcross = self.connectionService.players[positionAcross.rawValue] {
                //self.playerAcrossLabel.text = playerAcross.displayName
                self.playerAcrossLabel.update(playerName: playerAcross.displayName)
            } else {
                //self.playerAcrossLabel.text = ""
                self.playerAcrossLabel.update(playerName: "")
            }
            if let playerToRight = self.connectionService.players[positionToRight.rawValue] {
                //self.playerRightLabel.text = playerToRight.displayName
                self.playerRightLabel.update(playerName: playerToRight.displayName)
            } else {
                //self.playerRightLabel.text = ""
                self.playerRightLabel.update(playerName: "")
            }
        }
    }
    
    /**
     Instructs connection service to find games matching the specified game code
     - parameters:
        - withGameCode: game code to search
     */
    func findGames(withGameCode gameCode: String) {
        print("find gameCode \(gameCode)")
        
        if self.connectionService.gameId == nil {
            self.connectionService.findGames(withGameCode: gameCode)
        } else {
            self.showAlert(title: "already joined a game".localized, text: "disconnect from the current game before joining another one".localized)
        }
    }
    
    /**
     Instructs connection service to find a game with the matching game Id
     - parameter gameId: game Id to match
     */
    func findGame(byGameId gameId: String) {
        if self.connectionService.gameId == nil {
            self.connectionService.findGame(byGameId: gameId)
        } else {
            self.showAlert(title: "already joined a game".localized, text: "disconnect from the current game before joining another one".localized)
        }
    }
    
    /**
     Joins game with specified gameId
     - parameter gameId: gameId to join
     */
    func joinGame(gameId: String) {
        print("join gameId \(gameId)")
        
        if self.connectionService.gameId == nil {
            self.connectionService.joinGame(gameId: gameId)
        } else {
            self.showAlert(title: "already joined a game".localized, text: "disconnect from the current game before joining another one".localized)
        }
    }
    
    // MARK: - Private methods
    
    private func startGame(loadFromSave: Bool = true) {
        let gameType = GameType(rawValue: StoredSettings.instance.game)
        let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType)
        
        self.connectionsLabel.isHidden = gameConfig?.maxPlayers == 1
        self.playerLeftLabel.isHidden = gameConfig?.maxPlayers == 1
        self.playerAcrossLabel.isHidden = gameConfig?.maxPlayers == 1
        self.playerRightLabel.isHidden = gameConfig?.maxPlayers == 1
        self.awsStatusLabel.isHidden = gameConfig?.maxPlayers == 1
        
        self.scene = GameSceneFactory.CreateGameScene(ofType: gameType ?? .freePlay, ofSize: self.skView.frame.size, loadFromSave: loadFromSave) as? GameScene
        
        self.checkForceTouch()
        self.scene.gameSceneDelegate = self
        self.updateScenePlayers()
        
        /* Set the scale mode to scale to fit the window */
        self.scene.scaleMode = .aspectFill
        self.scene.backgroundColor = UIColor.clear
        
        self.skView.presentScene(self.scene)
    }
    
    /**
     Sets up buttons for the current game type
     */
    private func setUpButtons() {
        for button in self.buttons {
            button.removeFromSuperview()
        }
        
        self.buttons.removeAll()
        
        let gameType = GameType(rawValue: StoredSettings.instance.game)
        let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType)
        
        let numberOfGlobalButtons = 3
        let numberOfButtons = (gameConfig?.buttons.count ?? 0) + numberOfGlobalButtons
        var buttonNumber = 0
        
        if let gameButtons = gameConfig?.buttons {
            for buttonName in gameButtons {
                let button = BottomButton(withIconNamed: "icon_\(buttonName)", viewFrame: self.safeFrame, buttonNumber: CGFloat(buttonNumber), numberOfButtons: CGFloat(numberOfButtons), tag: numberOfButtons, name: buttonName)
                button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                self.buttons.append(button)
                self.view.addSubview(button)
                buttonNumber += 1
            }
        }
        
        let settingsButton = BottomButton(withIconNamed: "icon_settings", viewFrame: self.safeFrame, buttonNumber: CGFloat(buttonNumber), numberOfButtons: CGFloat(numberOfButtons), tag: 4, name: "settings")
        settingsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.buttons.append(settingsButton)
        self.view.addSubview(settingsButton)
        buttonNumber += 1
        
        let playersButton = BottomButton(withIconNamed: "icon_players", viewFrame: self.safeFrame, buttonNumber: CGFloat(buttonNumber), numberOfButtons: CGFloat(numberOfButtons), tag: 2, name: "players")
        playersButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.buttons.append(playersButton)
        self.view.addSubview(playersButton)
        buttonNumber += 1
        
        let restartButton = BottomButton(withIconNamed: "icon_restart", viewFrame: self.safeFrame, buttonNumber: CGFloat(buttonNumber), numberOfButtons: CGFloat(numberOfButtons), tag: 1, name: "restart")
        restartButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.buttons.append(restartButton)
        self.view.addSubview(restartButton)
    }
    
    /**
     Creates an invitation link to the current game and opens a sharing dialog
     */
    private func createInvitation(fromButton button: BottomButton?) {
        if self.connectionService.gameId != nil {
            let params = [URLQueryItem(name: "gameid", value: self.connectionService.gameId)]
            guard let url = Global.appLinkUrl(method: "join", params: params) else {
                self.showAlert(title: "something went wrong".localized, text: "couldn't retrieve the game information".localized)
                return
            }
            
            let inviteViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            let presentationController = inviteViewController.popoverPresentationController
            presentationController?.permittedArrowDirections = .down
            presentationController?.sourceView = button
            presentationController?.sourceRect = button?.bounds ?? CGRect(x: 0, y: 0, width: 0, height: 0)

            self.present(inviteViewController, animated: true, completion: nil)
        } else {
            print("No connected game")
        }
    }
    
    fileprivate func updateConnectionLabels() {
        DispatchQueue.main.async {
            let connectedPlayerNames = self.connectionService.playersAWS.filter({$0 != nil}).map({$0!.displayName})
            let connectionLabels = connectedPlayerNames.count == 0 ? "" : "\(connectedPlayerNames)"
            self.connectionsLabel.text = "\("connections".localized): \(connectionLabels)"
            self.updateLabels()
            self.updatePlayerLabels()
        }
    }
    
    fileprivate func updateScenePlayers() {
        self.scene.peers = self.connectionService.players
        self.scene.players = self.connectionService.playersAWS
        
        if self.connectionService.gameId != nil {
            self.scene.playerPosition = self.connectionService.myPositionAWS
        } else {
            self.scene.playerPosition = self.connectionService.myPosition
        }
    }
    
    // MARK: - System method overrides
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.checkForceTouch()
    }
}

// MARK: - ConnectionServiceManagerDelegate

extension GameViewController : ConnectionServiceManagerDelegate {

    func newPlayerConnected(player: Player, connectedPlayers: [Player?]) {
        self.flashMessage("\(player.displayName) \("joined the game".localized)")
    }
    
    
    func syncToMe(recipients: [Player]?) {
        if let syncData = self.scene.syncSettingsAndGameData() {
            self.connectionService.sendData(data: syncData)
            self.connectionService.sendDataAWS(data: syncData, type: .game)
        }
    }
    
    func newDeviceConnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        self.flashMessage("\(peerID.displayName) \("joined the game".localized)")
    }
    
    func playerDisconnected(player: Player, connectedPlayers: [Player?]) {
        self.flashMessage("\(player.displayName) \("disconnected".localized)")
    }
    
    func deviceDisconnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        DispatchQueue.main.async {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionsLabel.text = "\("connections".localized): \(connectedDevicesNames)"
            self.updateLabels()
            self.updatePlayerLabels()
        }
        self.scene.playerPosition = self.connectionService.myPosition
        self.updateScenePlayers()
        
        self.flashMessage("\(peerID.displayName) \("disconnected".localized)")
    }
    
    func updatePositions(myPosition: Position) {
        DispatchQueue.main.async {
            let connectedDevicesNames = self.connectionService.session.connectedPeers.map({$0.displayName})
            self.connectionsLabel.text = "\("connections".localized): \(connectedDevicesNames)"
            self.updateLabels()
            self.updatePlayerLabels()
        }
        self.scene.playerPosition = myPosition
        self.updateScenePlayers()
    }
    
    func didReceive(data receivedData: Data) {
        let dataHandler = ReceivedDataHandler(withScene: self.scene, connectionServiceManager: self.connectionService)
        dataHandler.handle(data: receivedData)
    }
    
    func receivedInvitation(from peerID: MCPeerID, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            let invitationAlert = UIAlertController(title: "\(peerID.displayName) \("wants to connect to the game".localized)", message: nil, preferredStyle: .alert)
            let allow = UIAlertAction(title: "allow".localized, style: .default, handler: { (alert) -> Void in
                    invitationHandler(true, self.connectionService.session)
                } )
            let cancelButton = UIAlertAction(title: "cancel".localized, style: .cancel) { (alert) -> Void in }
            
            invitationAlert.addAction(allow)
            invitationAlert.addAction(cancelButton)
            self.present(invitationAlert, animated: true, completion: nil)
        }
    }
    
    func updatePlayers() {
        print("updatePlayers")
        self.updateConnectionLabels()
        self.updateScenePlayers()
    }
    
    // AWS
    
    func didConnectAWS() {
        self.awsStatusLabel.text = "⚡︎"
        
        // reconnect to AWS game
        if let gameId = GameState.instance.gameId {
            self.showActionDialog(title: "do you want to reconnect to last game?".localized, text: nil, actionTitle: "reconnect".localized, action: { () -> Void in
                self.connectionService.joinGame(gameId: gameId)
            }, cancelAction: { () -> Void in
                GameState.instance.gameId = nil
            })
        }
    }
    
    func didDisconnectAWS() {
        self.awsStatusLabel.text = ""
        self.updateConnectionLabels()
    }
    
    func didGreateGameAWS(gameCode: String) {
        self.awsStatusLabel.text = gameCode
        // TODO: test on iPad
        self.createInvitation(fromButton: nil)
    }
    
    func didNotFindGame() {
        self.showAlert(title: "could not find game".localized, text: nil)
    }
    
    func didFindGamesAWS(gameIds: [(String, String)]) {
        if gameIds.count > 0 {
            //self.showAlert(title: "Found games", text: gameIds[0].1)
            self.showActionDialog(title: "found game".localized, text: "\("created by".localized) \(gameIds[0].1)", actionTitle: "join".localized, action: { () -> Void in
                self.connectionService.joinGame(gameId: gameIds[0].0)
            })
        } else {
            self.showAlert(title: "could not find game".localized, text: "")
        }
    }
    
    func didJoinGameAWS(gameId: String, gameCode: String, creator: String) {
        self.awsStatusLabel.text = gameCode
        self.flashMessage("\("joined game code".localized) \(gameCode)")
    }
    
    func didDisconnectFromGameAWS() {
        self.awsStatusLabel.text = "⚡︎"
        self.updateConnectionLabels()
        self.flashMessage("disconnected from game".localized)
    }
    
    func didReceiveTextMessageAWS(_ message: String, from sender: String) {
        self.showAlert(title: "\("message from".localized) \(sender)", text: message)
    }
}

// MARK: - GameSceneDelegate

extension GameViewController : GameSceneDelegate {
    func updatePlayer(numberOfCards: Int, inPosition position: Position) {
        switch position {
        case .left:
            self.playerLeftLabel.update(numberOfCards: numberOfCards)
        case .top:
            self.playerAcrossLabel.update(numberOfCards: numberOfCards)
        case .right:
            self.playerRightLabel.update(numberOfCards: numberOfCards)
        default:
            break
        }
    }
    
    /// NEW POP UP MENU METHOD
    func presentPopUpMenu(title: String?, withItems items: [PopUpMenuItem]?, at location: CGPoint) {
        if let popUpMenuitems = items {
            let popUpMenu = PopUpMenu(title: title, menuItems: popUpMenuitems)
            popUpMenu.delegate = self
            
            let sourceRect = CGRect(center: CGPoint(x: location.x, y: self.skView.frame.height - location.y), size: CGSize(width: 1, height: 1))
            
            print("rect: \(sourceRect)")
            
            let presentationController = popUpMenu.popoverPresentationController
            presentationController?.permittedArrowDirections = .any
            presentationController?.sourceView = self.skView
            presentationController?.sourceRect = sourceRect
            presentationController?.canOverlapSourceViewRect = true
            
            self.present(popUpMenu, animated: true, completion: nil)
        }
    }
    
    func peers() -> [MCPeerID?] {
        return self.connectionService.players
    }
        
    func sendData(data: Data, type dataType: WsDataType) {
        self.connectionService.sendData(data: data)
        self.connectionService.sendDataAWS(data: data, type: dataType)
    }
    
    func presentAlert(title: String?, text: String?, actionTitle: String, action: @escaping (() -> Void), cancelAction: (() -> Void)?) {
        self.showActionDialog(title: title, text: text, actionTitle: actionTitle, action: action, cancelAction: cancelAction)
    }
    
    func flashMessage(_ message: String) {
        self.flashMessageLabel.flash(message: message)
    }
}

// MARK: - SettingsViewControllerDelegate

extension GameViewController : SettingsTableControllerDelegate {
    func uiSettingsChanged() {
        let settingsData = RequestData(withType: .uiSettings, andDictionary: StoredSettings.instance.settingsDictionary)
        do {
            if let encodedData = try settingsData.encodedData() {
                DispatchQueue.global(qos: .default).async {
                    self.connectionService.sendData(data: encodedData)
                }
                DispatchQueue.global(qos: .default).async {
                    self.connectionService.sendDataAWS(data: encodedData, type: .game)
                }
            }
        } catch {
            print("Error encoding settings data")
        }
        self.scene.updateUISettings()
        
        var message = Message()
        message.systemMessage = UIStrings.changedAppearance
        message.arguments = [StoredSettings.instance.displayName]
        self.scene.sendMessage(message)
    }
    
    func settingsChanged() {
        self.syncToMe(recipients: nil)
        self.scene.resetGame(sync: true)
        
        var message = Message()
        message.systemMessage = UIStrings.changedDeck
        message.arguments = [StoredSettings.instance.displayName]
        self.scene.sendMessage(message)
    }
    
    func gameChanged() {
        self.scene.saveGame()
        self.setUpButtons()
        self.startGame()
        //self.configured = false
        
        var message = Message()
        message.systemMessage = UIStrings.changedGame
        message.arguments = [StoredSettings.instance.displayName, GameType.init(rawValue: StoredSettings.instance.game)?.name ?? ""]
        self.scene.sendMessage(message)
    }
    
    func gameAndSettingsChanged() {
        self.scene.saveGame()
        self.syncToMe(recipients: nil)
        self.startGame(loadFromSave: false)
        
        var message = Message()
        message.systemMessage = UIStrings.changedGame
        message.arguments = [StoredSettings.instance.displayName, GameType.init(rawValue: StoredSettings.instance.game)?.name ?? ""]
        self.scene.sendMessage(message)
    }
    
    func resetScores() {
        self.scene.resetScores()
    }
}

// MARK: - PopUpMenuDelegate

extension GameViewController : PopUpMenuDelegate {
    
    func cancel() {
        self.scene.endTouchesReset()
    }

}
