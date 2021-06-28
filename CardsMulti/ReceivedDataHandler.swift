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
        case .game:
            print("Received game data")
            if let receivedArray = receivedGameData.dataArray {
                self.scene.allCards.handle(recievedCardDictionaryArray: receivedArray, forScene: self.scene)
            }
        default:
            break
        }
    }
}
