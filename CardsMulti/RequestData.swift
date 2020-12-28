//
//  GameData.swift
//  CardsMulti
//
//  Created by Victor on 2020-11-22.
//  Copyright © 2020 Victorius Software Inc. All rights reserved.
//

import Foundation

/// Class responsible for encoding and decoding received and sent game data
class RequestData {
    
    // MARK: - Properties
    
    let type: RequestType
    let sender: String?
    
    // MARK: - Private properties
    
    private var data: NSObject?
    
    // MARK: - Computed properties
    
    var dataDictionary: NSDictionary? {
        if let dataDictionary = self.data as? NSDictionary {
            return dataDictionary
        }
        return nil
    }
    
    var dataArray: NSArray? {
        if let dataArray = self.data as? NSArray {
            return dataArray
        }
        return nil
    }
    
    // MARK: - Initializers
    
    init(withType type: RequestType, andSender sender: Player) {
        self.type = type
        
        if let playerConnectionId = sender.connectionId {
            self.sender = playerConnectionId
        } else if let playerPeerId = sender.peerId {
            self.sender = playerPeerId.displayName
        } else {
            self.sender = nil
        }
    }
    
    init(withType type: RequestType, andDictionary dataDictionary: NSDictionary) {
        self.type = type
        self.sender = nil
        self.data = dataDictionary
    }
    
    init(withType type: RequestType, andArray dataArray: Array<Any>) {
        self.type = type
        self.sender = nil
        self.data = NSArray(array: dataArray)
    }
    
    init(withData data: Data) throws {
        do {
            let dataDictionary = try JSONSerialization.jsonObject(with: data) as! NSDictionary

            if let value = dataDictionary[dataKey.type.rawValue] as? String {
                if let type = RequestType.init(rawValue: value) {
                    self.type = type
                } else {
                    self.type = .unknown
                }
            } else {
                throw GameDataError.MissingGameDataTypeError
            }
            
            if let value = dataDictionary[dataKey.sender.rawValue] as? String {
                self.sender = value
            } else {
                self.sender = nil
            }
            
            if let value = dataDictionary[dataKey.data.rawValue] as? NSDictionary {
                self.data = value
            } else if let value = dataDictionary[dataKey.data.rawValue] as? NSArray {
                self.data = value
            }
            
        } catch {
            throw GameDataError.FailedToDecodeGameDataError
        }
    }
    
    init(withDecodedData dataDictionary: NSDictionary) throws {
        if let value = dataDictionary[dataKey.type.rawValue] as? String {
            if let type = RequestType.init(rawValue: value) {
                self.type = type
            } else {
                self.type = .unknown
            }
        } else {
            throw GameDataError.MissingGameDataTypeError
        }
        
        if let value = dataDictionary[dataKey.sender.rawValue] as? String {
            self.sender = value
        } else {
            self.sender = nil
        }
        
        if let value = dataDictionary[dataKey.data.rawValue] as? NSDictionary {
            self.data = value
        } else if let value = dataDictionary[dataKey.data.rawValue] as? NSArray {
            self.data = value
        }
    }
    
    // MARK: - Public methods
    
    /**
     Returns encoded data to be sent
     */
    func encodedData() throws -> Data? {

        let requestDictionary = self.dictionary()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestDictionary)
            return jsonData
        } catch {
            throw GameDataError.FailedToSerializeGameDataError
        }
    }
    
    func dictionary() -> NSDictionary {
        let requestDictionary = NSMutableDictionary()
        
        requestDictionary[dataKey.type.rawValue] = self.type.rawValue

        if self.sender != nil {
            requestDictionary[dataKey.sender.rawValue] = self.sender!
        }
        
        if self.data != nil {
            requestDictionary[dataKey.data.rawValue] = self.data!
        }
        
        return requestDictionary
    }
    
    // MARK: - Enums
    
    enum dataKey : String {
        case type = "type"
        case data = "data"
        case sender = "sender"
    }
}

// MARK: - GameDataError enum

enum GameDataError : Error {
    case FailedToDecodeGameDataError
    case MissingGameDataTypeError
    case FailedToSerializeGameDataError
}

// MARK: - RequestType enum

enum RequestType : String {
    case game = "Game"
    case settings = "Settings"
    case requestToSync = "RequestToSync"
    case unknown = "Unknown"
}

// MARK: - Array of RequestData extension

extension Array where Element:RequestData {
    
    init(withData data: Data) throws {
        self.init()
        
        do {
            if let dataArray = try JSONSerialization.jsonObject(with: data) as? NSArray {
                for element in dataArray {
                    if let dictionary = element as? NSDictionary {
                        if let requestData = try? RequestData(withDecodedData: dictionary) {
                            self.append((requestData as? Element)!)
                        }
                    }
                }
            } else {
                throw GameDataError.FailedToDecodeGameDataError
            }
        } catch {
            throw GameDataError.FailedToDecodeGameDataError
        }
    }
    
    /**
     Returns encoded data to be sent
     */
    func encodedData() throws -> Data? {
        do {
            let requestDataArray = NSMutableArray()
            
            for requestData in self {
                let requestDictionary = requestData.dictionary()
                requestDataArray.add(requestDictionary)
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestDataArray)
            return jsonData
        } catch {
            throw GameDataError.FailedToSerializeGameDataError
        }
    }
    
}
