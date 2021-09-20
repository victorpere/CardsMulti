//
//  ReceivedDataHandler.swift
//  CardsMulti
//
//  Created by Victor on 2020-12-13.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import Foundation

/// Class that handles received game data
class ReceivedDataHandler {
    
    // MARK: - Private properties
    
    private let scene: GameScene
    private let connectionServiceManager: ConnectionServiceManager
    
    // MARK: - Initializers
    
    init(withScene scene: GameScene, connectionServiceManager: ConnectionServiceManager) {
        self.scene = scene
        self.connectionServiceManager = connectionServiceManager
    }
    
    // MARK: - Public methods
    
    /**
     Handles received sychronization data (settings or cards)
     
     - parameter data: data containing synchronization array or dictionary
     */
    func handle(data receivedData: Data) {
        if let requestDataArray = try? Array(withData: receivedData) {
            for requestDataElement in requestDataArray {
                self.handleRequestData(requestDataElement)
            }
        } else {
            do {
                let receivedGameData = try RequestData(withData: receivedData)
                self.handleRequestData(receivedGameData)
            } catch {
                // TODO: handle error deserializing received data
                print("Error deserializing received data")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func handleRequestData(_ receivedGameData: RequestData) {
        switch receivedGameData.type {
        case .requestToSync:
            if self.connectionServiceManager.isHost {
                self.scene.syncSceneToMe()
            }
        case .settings:
            print("Received settings")
            if let receivedDictionary = receivedGameData.dataDictionary {
                StoredSettings.instance.syncTo(settingsDictionary: receivedDictionary)
                self.scene.resetCards()
            }
        case .uiSettings:
            print("Received UI settings")
            if let receivedDictionary = receivedGameData.dataDictionary {
                StoredSettings.instance.syncTo(settingsDictionary: receivedDictionary)
                self.scene.updateUISettings()
            }
        case .game:
            print("Received game data")
            if let receivedArray = receivedGameData.dataArray {
                self.scene.allCards.handle(recievedCardDictionaryArray: receivedArray, forScene: self.scene)
            }
        case .message:
            print("Received message")
            if let receivedDictionary = receivedGameData.dataDictionary {
                let message = Message(with: receivedDictionary)
                
                if let displayMessage = message.flashMessage {
                    self.scene.flash(message:displayMessage, at: message.location)
                }
            }
        default:
            print("Received unknown data type")
            break
        }
    }
}
