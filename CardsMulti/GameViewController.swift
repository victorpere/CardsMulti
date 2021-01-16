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

class GameViewController: UIViewController {
    
    let buttonMargin: CGFloat = 8.0
    let numberOfButtons: CGFloat = 5
    
    let connectionService = ConnectionServiceManager()
    //var host: MCPeerID!
    
    
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
        
        // Configure the view.
        
        let playersIcon = UIImage(named: "icon_players")
        
        let barHeight = (playersIcon?.size.height)! + 2 * buttonMargin
        
        self.backGroundView = UIView(frame: view.frame)
        self.backGroundView.backgroundColor = UIColor.black
        self.backGroundView.backgroundColor = UIColor(patternImage: UIImage(named: UIDevice.current.backgroundFileName)!)
        self.view.addSubview(self.backGroundView)
        
        self.connectionsLabel = UILabel(frame: CGRect(x: 0, y: self.view.frame.width, width: self.view.frame.width, height: 15))
        self.connectionsLabel.textColor = UIColor.green
        self.connectionsLabel.font = UIFont(name: "Helvetica", size: 12)
        self.connectionsLabel.text = "Connections: "
        self.view.addSubview(self.connectionsLabel)
        
        self.awsStatusLabel = UILabel(frame: CGRect(x: self.view.frame.width - 35, y: self.view.frame.width, width: 35, height: 15))
        self.awsStatusLabel.textColor = UIColor.green
        self.awsStatusLabel.font = UIFont(name: "Helvetica", size: 12)
        self.view.addSubview(self.awsStatusLabel)
        
        self.playerAcrossLabel = PlayerStatusLabel(withFrameDimension: self.view.frame.width, inPosition: .top)
        self.view.addSubview(self.playerAcrossLabel)
        
        self.playerLeftLabel = PlayerStatusLabel(withFrameDimension: self.view.frame.width, inPosition: .left)
        self.view.addSubview(self.playerLeftLabel)
        
        self.playerRightLabel = PlayerStatusLabel(withFrameDimension: self.view.frame.width, inPosition: .right)
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
        
        self.lineUpCardsButton = BottomButton(withIconNamed: "icon_cards", viewFrame: self.view.frame, buttonNumber: 0, numberOfButtons: self.numberOfButtons, tag: 3)
        self.lineUpCardsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.lineUpCardsButton)
        
        self.sortCardsButton = BottomButton(withIconNamed: "icon_cards_sort", viewFrame: self.view.frame, buttonNumber: 1, numberOfButtons: self.numberOfButtons, tag: 5)
        self.sortCardsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.sortCardsButton)
        
        self.settingsButton = BottomButton(withIconNamed: "icon_settings", viewFrame: self.view.frame, buttonNumber: 2, numberOfButtons: self.numberOfButtons, tag: 4)
        self.settingsButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.settingsButton)
        
        self.numberOfPlayersButton = BottomButton(withIconNamed: "icon_players", viewFrame: self.view.frame, buttonNumber: 3, numberOfButtons: self.numberOfButtons, tag: 2)
        self.numberOfPlayersButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.numberOfPlayersButton)
        
        self.restartButton = BottomButton(withIconNamed: "icon_restart", viewFrame: self.view.frame, buttonNumber: 4, numberOfButtons: self.numberOfButtons, tag: 1)
        self.restartButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        self.view.addSubview(self.restartButton)
        
        self.scoresButton = BottomButton(withIconNamed: "icon_cards", viewFrame: self.view.frame, buttonNumber: 5, numberOfButtons: self.numberOfButtons, tag: 6)
        self.scoresButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        //view.addSubview(self.scoresButton)
        
        //let skView = self.view as! SKView
        let sceneFrame = CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.width, height: self.view.frame.height - barHeight)
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
                self.disconnectFromPeer()
            } else {
                self.browsePeers()
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
        
        switch Settings.instance.game {
        case GameType.FreePlay.rawValue:
            self.connectionsLabel.isHidden = false
            self.playerLeftLabel.isHidden = false
            self.playerAcrossLabel.isHidden = false
            self.playerRightLabel.isHidden = false
            self.awsStatusLabel.isHidden = false
            self.scene = GameScene(size: self.skView.frame.size, loadFromSave: loadFromSave)
        case GameType.Solitare.rawValue:
            self.connectionsLabel.isHidden = true
            self.playerLeftLabel.isHidden = true
            self.playerAcrossLabel.isHidden = true
            self.playerRightLabel.isHidden = true
            self.awsStatusLabel.isHidden = true
            self.scene = Solitaire(size: self.skView.frame.size, loadFromSave: loadFromSave)
        case GameType.GoFish.rawValue:
            self.connectionsLabel.isHidden = false
            self.playerLeftLabel.isHidden = false
            self.playerAcrossLabel.isHidden = false
            self.playerRightLabel.isHidden = false
            self.awsStatusLabel.isHidden = false
            self.scene = GameGoFish(size: self.skView.frame.size, loadFromSave: loadFromSave)
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
    
    func browsePeers() {
        var title = "Create or join a game"
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
        let createGameAction = UIAlertAction(title: "Create a new game", style: .default,
                                             handler: { (alert) -> Void in
                                                self.connectionService.createGame()
        })
        peerBrowser.addAction(createGameAction)
        
        // button to join AWS game
        let joinGameAction = UIAlertAction(title: "Join a game", style: .default, handler: { (alert) -> Void in
            self.showTextDialog(title: "Join a game", text: "Game code", keyboardType: .numberPad, okAction: { (gameCode) -> Void in
                self.connectionService.findGames(gameCode: gameCode)
            })
        })
        peerBrowser.addAction(joinGameAction)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
        peerBrowser.addAction(cancelButton)
        
        let presentationController = peerBrowser.popoverPresentationController
        presentationController?.permittedArrowDirections = .down
        presentationController?.sourceView = self.numberOfPlayersButton
        presentationController?.sourceRect = self.numberOfPlayersButton.bounds
        
        self.present(peerBrowser, animated: true, completion: nil)
    }
    
    func disconnectFromPeer() {
        var title: String?
        if let gameCode = self.connectionService.gameCode {
            title = "Connected to game \(gameCode)"
        }
        
        let connectionAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let disconnectButton = UIAlertAction(title: "Disconnect from the game", style: .default, handler: { (alert) -> Void in
            self.connectionService.disconnectFromGame()
            self.connectionService.disconnect()
        } )
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
        
        connectionAlert.addAction(disconnectButton)
        connectionAlert.addAction(cancelButton)
        self.present(connectionAlert, animated: true, completion: nil)
    }
    
    func openSettings() {
        //let settingsViewController = SettingsViewController(nibName: nil, bundle: nil)
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
    
    // MARK: - Private methods
    
    /**
     Displays information alert with OK button that dismisses the alert
     */
    private func showAlert(title: String, text: String?) {
        DispatchQueue.main.async {
            let messageAlert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "OK", style: .cancel) { (alert) -> Void in }
            
            messageAlert.addAction(cancelButton)
            self.present(messageAlert, animated: true, completion: nil)
        }
    }
    
    /**
     Displays an alert with a text entry and OK and Cancel buttons
     */
    private func showTextDialog(title: String, text: String, keyboardType: UIKeyboardType, okAction: @escaping ((String) -> Void)) {
        let textInputAlert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        textInputAlert.addTextField()
        textInputAlert.textFields![0].keyboardType = keyboardType
        
        let okButton = UIAlertAction(title: "OK", style: .default) { (alert) -> Void in
            if let inputText = textInputAlert.textFields![0].text {
                okAction(inputText)
            }
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
        
        textInputAlert.addAction(okButton)
        textInputAlert.addAction(cancelButton)
        
        DispatchQueue.main.async {
            self.present(textInputAlert, animated: true, completion: nil)
        }
    }
    
    /**
     Displays an alert with OK and Cancel buttons
     */
    private func showActionDialog(title: String?, text: String?, actionTitle: String, action: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionTitle, style: .default) { (alert) -> Void in
            action()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(action)
        alert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func updateConnectionLabels() {
        DispatchQueue.main.async {
            let connectedPlayerNames = self.connectionService.playersAWS.filter({$0 != nil}).map({$0!.displayName})
            let connectionLabels = connectedPlayerNames.count == 0 ? "" : "\(connectedPlayerNames)"
            self.connectionsLabel.text = "Connections: \(connectionLabels)"
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
        self.showAlert(title: "", text: "\(player.displayName) joined the game")
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
            self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
            self.updateLabels()
            self.updatePlayerLabels()
        }
        
        self.scene.playerPosition = self.connectionService.myPosition
        self.updateScenePlayers()
        
    }
    
    func playerDisconnected(player: Player, connectedPlayers: [Player?]) {
        self.showAlert(title: "", text: "\(player.displayName) disconnected")
    }
    
    func deviceDisconnected(peerID: MCPeerID, connectedDevices: [MCPeerID]) {
        DispatchQueue.main.async {
            let connectedDevicesNames = connectedDevices.map({$0.displayName})
            self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
            self.updateLabels()
            self.updatePlayerLabels()
        }
        self.scene.playerPosition = self.connectionService.myPosition
        self.updateScenePlayers()
    }
    
    func updatePositions(myPosition: Position) {
        DispatchQueue.main.async {
            let connectedDevicesNames = self.connectionService.session.connectedPeers.map({$0.displayName})
            self.connectionsLabel.text = "Connections: \(connectedDevicesNames)"
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
            let invitationAlert = UIAlertController(title: "\(peerID.displayName) wants to connect to the game", message: nil, preferredStyle: .alert)
            let allow = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
                    invitationHandler(true, self.connectionService.session)
                } )
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (alert) -> Void in }
            
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
            self.showActionDialog(title: "Do you want to reconnect to last game?", text: nil, actionTitle: "Reconnect", action: { () -> Void in
                self.connectionService.joinGame(gameId: gameId)
            })
        }
    }
    
    func didDisconnectAWS() {
        self.awsStatusLabel.text = ""
        self.updateConnectionLabels()
    }
    
    func didGreateGameAWS(gameCode: String) {
        self.awsStatusLabel.text = gameCode
        self.showAlert(title: "Game Created", text: "Game code: \(gameCode)")
    }
    
    func didNotFindGame() {
        self.showAlert(title: "Could not find game", text: nil)
    }
    
    func didFindGamesAWS(gameIds: [(String, String)]) {
        if gameIds.count > 0 {
            //self.showAlert(title: "Found games", text: gameIds[0].1)
            self.showActionDialog(title: "Found game", text: "Created by \(gameIds[0].1)", actionTitle: "Join", action: { () -> Void in
                self.connectionService.joinGame(gameId: gameIds[0].0)
            })
        } else {
            self.showAlert(title: "No games found", text: "")
        }
    }
    
    func didJoinGameAWS(gameId: String, gameCode: String, creator: String) {
        self.awsStatusLabel.text = gameCode
        self.showAlert(title: "Joined game code \(gameCode)", text: "Created by \(creator)")
    }
    
    func didDisconnectFromGameAWS() {
        self.awsStatusLabel.text = "⚡︎"
        self.updateConnectionLabels()
        self.showAlert(title: "Disconnected from game", text: nil)
    }
    
    func didReceiveTextMessageAWS(_ message: String, from sender: String) {
        self.showAlert(title: "Message from \(sender)", text: message)
        
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
        let popUpMenu = PopUpMenu(numberOfCards: numberOfCards, numberOfPlayers: numberOfPlayers)
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
    
    func peers() -> [MCPeerID?] {
        return self.connectionService.players
    }
        
    func sendData(data: Data, type dataType: WsDataType) {
        self.connectionService.sendData(data: data)
        self.connectionService.sendDataAWS(data: data, type: dataType)
    }
}

// MARK: - SettingsViewControllerDelegate

extension GameViewController : SettingsViewControllerDelegate, SettingsTableControllerDelegate {
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
        self.scene.deselectNodeForTouch()
    }

}
