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
    //var host: MCPeerID!
    
    var safeFrame: CGRect!
    var configured = false
    
    var connectionsLabel: UILabel!
    var positionLabel: UILabel!
    var playerLeftLabel: PlayerStatusLabel!
    var playerAcrossLabel: PlayerStatusLabel!
    var playerRightLabel: PlayerStatusLabel!
    var awsStatusLabel: UILabel!
    
    var backGroundView: UIView!
    var skView: SKView!
    var scene: GameScene!
    
    
    var restartButton: BottomButton!
    var settingsButton: BottomButton!
    var numberOfPlayersButton: BottomButton!
    var lineUpCardsButton: BottomButton!
    var sortCardsButton: BottomButton!
    var scoresButton: BottomButton!
    
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
        
        let playersIcon = UIImage(named: "icon_players")
        
        let barHeight = (playersIcon?.size.height)! + 2 * buttonMargin
        
        self.backGroundView = UIView(frame: view.frame)
        self.backGroundView.backgroundColor = UIColor.black
        self.backGroundView.backgroundColor = UIColor(patternImage: UIImage(named: UIDevice.current.backgroundFileName)!)
        self.view.addSubview(self.backGroundView)
        
        self.connectionsLabel = UILabel(frame: CGRect(x: self.view.safeAreaInsets.left, y: self.view.frame.width, width: self.safeFrame.width, height: 15))
        self.connectionsLabel.textColor = UIColor.green
        self.connectionsLabel.font = UIFont(name: "Helvetica", size: 12)
        self.connectionsLabel.text = "\("connections".localized): "
        self.view.addSubview(self.connectionsLabel)
        
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
        self.positionLabel.text = "\(self.connectionService.myPeerId)\n\(self.connectionService.hostPeerID)\n\(self.connectionService.myPosition)\n"
        for player in self.connectionService.players {
            self.positionLabel.text?.append("\(String(describing: player))\n")
        }
        self.view.addSubview(self.positionLabel)
        self.positionLabel.isHidden = true
        
        self.lineUpCardsButton = BottomButton(withIconNamed: "icon_cards", viewFrame: self.safeFrame, buttonNumber: 0, numberOfButtons: self.numberOfButtons, tag: 3)
        self.lineUpCardsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.lineUpCardsButton)
        
        self.sortCardsButton = BottomButton(withIconNamed: "icon_cards_sort", viewFrame: self.safeFrame, buttonNumber: 1, numberOfButtons: self.numberOfButtons, tag: 5)
        self.sortCardsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.sortCardsButton)
        
        self.settingsButton = BottomButton(withIconNamed: "icon_settings", viewFrame: self.safeFrame, buttonNumber: 2, numberOfButtons: self.numberOfButtons, tag: 4)
        self.settingsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.settingsButton)
        
        self.numberOfPlayersButton = BottomButton(withIconNamed: "icon_players", viewFrame: self.safeFrame, buttonNumber: 3, numberOfButtons: self.numberOfButtons, tag: 2)
        self.numberOfPlayersButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.numberOfPlayersButton)
        
        self.restartButton = BottomButton(withIconNamed: "icon_restart", viewFrame: self.safeFrame, buttonNumber: 4, numberOfButtons: self.numberOfButtons, tag: 1)
        self.restartButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.restartButton)
        
        self.scoresButton = BottomButton(withIconNamed: "icon_cards", viewFrame: self.view.frame, buttonNumber: 5, numberOfButtons: self.numberOfButtons, tag: 6)
        self.scoresButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        //view.addSubview(self.scoresButton)
        
        //let skView = self.view as! SKView
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
        self.startGame()
    }
    
    // MARK: - Action methods
    
    @objc func buttonAction(sender: UIButton!) {
        let btnsendtag: UIButton = sender
        switch btnsendtag.tag {
        case 1:
            self.resetGame()
        case 2:
            if self.connectionService.connected {
                self.showConnectedMenu()
            } else {
                self.showNotConnectedMenu()
            }
        case 3:
            self.lineUpCards()
        case 4:
            self.openSettings()
        case 5:
            self.sortCards()
        case 6:
            // test websockets
            //WsRequestSender.instnc.connect()
            //WsRequestSender.instance.disconnect()
            
            // scores
            //self.openScores()
            break
        default: break
        }
    }
    
    // MARK: - Public methods
    
    func saveGame() {
        self.scene.saveGame()
    }
    
    func startGame(loadFromSave: Bool = true) {

        //connectionsLabel.isHidden = true
        
        switch StoredSettings.instance.game {
        case GameType.freePlay.rawValue:
            self.connectionsLabel.isHidden = false
            self.playerLeftLabel.isHidden = false
            self.playerAcrossLabel.isHidden = false
            self.playerRightLabel.isHidden = false
            self.awsStatusLabel.isHidden = false
            self.scene = GameScene(size: self.skView.frame.size, loadFromSave: loadFromSave)
        case GameType.solitare.rawValue:
            self.connectionsLabel.isHidden = true
            self.playerLeftLabel.isHidden = true
            self.playerAcrossLabel.isHidden = true
            self.playerRightLabel.isHidden = true
            self.awsStatusLabel.isHidden = true
            self.scene = Solitaire(size: self.skView.frame.size, loadFromSave: loadFromSave)
//        case GameType.GoFish.rawValue:
//            self.connectionsLabel.isHidden = false
//            self.playerLeftLabel.isHidden = false
//            self.playerAcrossLabel.isHidden = false
//            self.playerRightLabel.isHidden = false
//            self.awsStatusLabel.isHidden = false
//            self.scene = GameGoFish(size: self.skView.frame.size, loadFromSave: loadFromSave)
        default:
            self.connectionsLabel.isHidden = false
            self.playerLeftLabel.isHidden = false
            self.playerAcrossLabel.isHidden = false
            self.playerRightLabel.isHidden = false
            self.awsStatusLabel.isHidden = false
            self.scene = GameScene(size: self.skView.frame.size, loadFromSave: loadFromSave)
        }
        
        self.checkForceTouch()
        self.scene.gameSceneDelegate = self
        self.updateScenePlayers()
        
        /* Set the scale mode to scale to fit the window */
        self.scene.scaleMode = .aspectFill
        self.scene.backgroundColor = UIColor.clear
        
        self.skView.presentScene(self.scene)
    }
    
    func resetGame() {
        self.scene.shuffleAndStackAllCards(sync: true)
    }
    
    func lineUpCards() {
        self.scene.resetHand(sort: false)
    }
    
    func sortCards() {
        self.scene.resetHand(sort: true)
    }
    
    func showNotConnectedMenu() {
        if let gameConfig = GameConfigs.sharedInstance.gameConfig(for: self.scene.gameType), gameConfig.maxPlayers < 2 {
            self.showActionDialog(title: "sigle player game".localized, text: "you can switch to a multiplayer game in settings".localized, actionTitle: "open settings".localized, action: { () -> Void in
                self.openSettings()
            })
            return
        }
        
        var title = "create or join a game".localized
        if self.connectionService.foundPeers.count > 0 {
            title = "Join a nearby device, or create or join a remote game"
        }
        
        let peerBrowser = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for peerID in self.connectionService.foundPeers {
            let peerAction = UIAlertAction(title: peerID.displayName, style: .default, handler: { (alert) -> Void in
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
        presentationController?.sourceView = self.numberOfPlayersButton
        presentationController?.sourceRect = self.numberOfPlayersButton.bounds
        
        self.present(peerBrowser, animated: true, completion: nil)
    }
    
    func showConnectedMenu() {
        var title: String?
        if let gameCode = self.connectionService.gameCode {
            title = "\("connected to game".localized) \(gameCode)"
        }
        
        let connectionAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let inviteButton = UIAlertAction(title: "invite a friend to join".localized, style: .default, handler: { (alert) -> Void in
            self.createInvitation()
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
        presentationController?.sourceView = self.numberOfPlayersButton
        presentationController?.sourceRect = self.numberOfPlayersButton.bounds
        
        self.present(connectionAlert, animated: true, completion: nil)
    }
    
    func openSettings() {
        let settingsViewController = SettingsTableContoller(nibName: nil, bundle: nil)
        settingsViewController.delegate = self
        let navSettingsViewController = UINavigationController(rootViewController: settingsViewController)
        navSettingsViewController.modalPresentationStyle = .popover
        settingsViewController.preferredContentSize = CGSize(width: 375, height: 676)
        
        let presentationController = navSettingsViewController.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = self.settingsButton
        presentationController?.sourceRect = self.settingsButton.bounds
        
        self.present(navSettingsViewController, animated: true, completion: nil)
    }
    
    func openScores() {
        let scoresViewController = ScoresViewController(withScene: self.scene)
        
        let navScoresViewController = UINavigationController(rootViewController: scoresViewController)
        navScoresViewController.modalPresentationStyle = .popover
        scoresViewController.preferredContentSize = CGSize(width: 375, height: 676)
        
        let presentationConroller = navScoresViewController.popoverPresentationController
        presentationConroller?.permittedArrowDirections = .down
        presentationConroller?.sourceView = self.scoresButton
        presentationConroller?.sourceRect = self.scoresButton.bounds
        
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
            self.positionLabel.text = "\(self.connectionService.myPeerId)\n\(self.connectionService.hostPeerID)\n\(self.connectionService.myPosition)\n"
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
    
    /**
     Creates an invitation link to the current game and opens a sharing dialog
     */
    private func createInvitation() {
        let params = [URLQueryItem(name: "gamecode", value: self.connectionService.gameCode)]
        guard let url = Global.appLinkUrl(method: "join", params: params) else {
            self.showAlert(title: "something went wrong".localized, text: "couldn't retrieve the game information".localized)
            return
        }
        
        let inviteViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        let presentationController = inviteViewController.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = self.numberOfPlayersButton
        presentationController?.sourceRect = self.numberOfPlayersButton.bounds

        self.present(inviteViewController, animated: true, completion: nil)
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
        self.scene.playerPosition = self.connectionService.myPositionAWS
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
        self.showAlert(title: "", text: "\(player.displayName) \("joined the game".localized)")
    }
    
    
    func syncToMe(recipients: [Player]?) {
        //self.scene.syncSettingsToMe()
        if let syncData = self.scene.syncSettingsAndGameData() {
            self.connectionService.sendData(data: syncData)
            self.connectionService.sendDataAWS(data: syncData, type: .game)
        }
    }
    
    func newDeviceConnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        DispatchQueue.main.async {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionsLabel.text = "\("connections".localized): \(connectedDevicesNames)"
            self.updateLabels()
            self.updatePlayerLabels()
        }
        
        self.scene.playerPosition = self.connectionService.myPosition
        self.updateScenePlayers()
        
    }
    
    func playerDisconnected(player: Player, connectedPlayers: [Player?]) {
        self.showAlert(title: "", text: "\(player.displayName) \("disconnected".localized)")
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
        self.createInvitation()
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
        self.showAlert(title: "\("joined game code".localized) \(gameCode)", text: "\("Created by".localized) \(creator)")
    }
    
    func didDisconnectFromGameAWS() {
        self.awsStatusLabel.text = "⚡︎"
        self.updateConnectionLabels()
        self.showAlert(title: "disconnected from game".localized, text: nil)
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
    
    func presentPopUpMenu(numberOfCards: Int, numberOfPlayers: Int, at location: CGPoint) {
        print("touch location: \(location)")
        let popUpMenu = PopUpMenu(numberOfCards: numberOfCards, delegate: self)
        popUpMenu.touchLocation = location
        
        let sourceRect = CGRect(center: CGPoint(x: location.x, y: self.skView.frame.height - location.y), size: CGSize(width: 1, height: 1))
        
        print("rect: \(sourceRect)")
        
        let presentationController = popUpMenu.popoverPresentationController
        presentationController?.permittedArrowDirections = .any
        presentationController?.sourceView = self.skView
        presentationController?.sourceRect = sourceRect
        presentationController?.canOverlapSourceViewRect = true
        
        self.present(popUpMenu, animated: true, completion: nil)
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
}

// MARK: - SettingsViewControllerDelegate

extension GameViewController : SettingsTableControllerDelegate {
    func uiSettingsChanged() {
        self.scene.updateUISettings()
    }
    
    func settingsChanged() {
        self.scene.resetGame(sync: true)
    }
    
    func gameChanged() {
        self.scene.saveGame()
        self.startGame(loadFromSave: false)
    }
    
    func resetScores() {
        self.scene.resetScores()
    }
}

// MARK: - PopUpMenuDelegate

extension GameViewController : PopUpMenuDelegate {
    func numberOfCards(inPosition position: Position) -> Int {
        return self.scene.numberOfCards(inPosition: position)
    }
    
    var numberOfPlayers: Int {
        return self.scene.numberOfPlayers
    }
    
    func stack() {
        self.scene.stackSelectedCards()
    }
    
    func fan() {
        self.scene.fan(cards: self.scene.selectedNodes, faceUp: true)
    }
    
    func deal(_ cards: Int) {
        self.scene.deal(numberOfCards: cards)
    }
    
    func shuffle() {
        self.scene.shuffle(cards: self.scene.selectedNodes)
    }
    
    func cancel() {
        self.scene.endTouchesReset()
    }

    func recall(from position: Position?, to location: CGPoint?) {
        self.scene.endTouchesReset()
        self.scene.recallCards(from: position, to: location)
    }
}
