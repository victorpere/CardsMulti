//
//  Config.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-24.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import Foundation
import UIKit

public final class Config {
    
    /// AWS websocket endpoinnt
    public static let awsEndpoint = "wss://8vuqtnjhvk.execute-api.us-east-2.amazonaws.com/dev"
    
    public static let appLinksDomain = "victoriussoftware.com"
    
    public static let configFilePath = Bundle.main.path(forResource: "gameTypes", ofType: "json")
    
    public static let productIdsFilePath = Bundle.main.path(forResource: "ProductIds", ofType: "plist")
    
    public static let mainColor: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.5, alpha: 1.0)

    public static let cardBackImageName = "back"
    
    public static let cardWidthFullSizePixels: CGFloat = 500.0
    
    public static let snapDistance: CGFloat = 20
    public static let fanRadiusCoefficient: CGFloat = 100
    public static let fanWidthCoefficient: CGFloat = 1
    
    public static let flashMessageFadeDuration: TimeInterval = 0.25
    public static let flashMessageDuration: TimeInterval = 2.0
    public static let flashMessageColor: UIColor = .white
    public static let flashMessageFontSize: CGFloat = 20
    public static let flashMessageLabelHeight: CGFloat = 40
    
    public static let uiFontName: String = "Helvetica"
    
    public static let maxPlayers: Int = 4
    
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    public static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    public static var isDebug: Bool {
        #if DEBUG
          return true
        #else
          return false
        #endif
      }
    
    private init() {
        
    }
}
