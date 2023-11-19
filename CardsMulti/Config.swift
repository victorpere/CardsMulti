//
//  Config.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-24.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import Foundation
import UIKit

struct Config {
    
    /// AWS websocket endpoinnt
    static let awsEndpoint = "wss://8vuqtnjhvk.execute-api.us-east-2.amazonaws.com/dev"
    
    static let appLinksDomain = "victoriussoftware.com"
    
    static let configFilePath = Bundle.main.path(forResource: "gameTypes", ofType: "json")
    static let cardDecksFilePath = Bundle.main.path(forResource: "cardDecks", ofType: "json")
    static let productIdsFilePath = Bundle.main.path(forResource: "ProductIds", ofType: "plist")
    
    static let mainColor: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.5, alpha: 1.0)

    static let cardBackImageName = "back"
    
    static let cardWidthFullSizePixels: CGFloat = 500.0
    static let defaultCardWidthsPerScreen: Float = 6
    static let minCardWidthsPerScreen: Float = 3
    static let maxCardWidthsPerScreen: Float = 10
    static let presetCardWidthsPerScreen: KeyValuePairs<String, Float> = ["small": 8, "medium": 6, "large": 4, "xlarge": 3]
    
    static let snapDistance: CGFloat = 20
    static let fanRadiusCoefficient: CGFloat = 100
    static let fanWidthCoefficient: CGFloat = 1
    
    static let flashMessageFadeDuration: TimeInterval = 0.25
    static let flashMessageDuration: TimeInterval = 2.0
    static let flashMessageColor: UIColor = .white
    static let flashMessageFontSize: CGFloat = 20
    static let flashMessageLabelHeight: CGFloat = 40
    
    static let preferredPopoverSize = CGSize(width: 375, height: 676)
    
    static let uiFontName: String = "Helvetica"
    
    static let maxPlayers: Int = 4
    
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    static let useSwiftUI = true
    
    static var isDebug: Bool {
        #if DEBUG
          return true
        #else
          return false
        #endif
      }
}
