//
//  SettingsView.swift
//  CardsMulti
//
//  Created by Victor on 2023-10-22.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    
    @StateObject private var selectedSettings: TemporarySettings
    
    @StateObject private var productManager: ProductManager
    
    weak private var delegate: SettingsDelegate?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedGameConfig: GameConfig?
    
    // MARK: - Initializers
    
    init(delegate: SettingsDelegate?) {
        self.delegate = delegate
        self._selectedSettings = .init(wrappedValue: TemporarySettings(with: StoredSettings.instance))
        self._selectedGameConfig = .init(wrappedValue: GameConfigs.sharedInstance.gameConfig(for: GameType(rawValue: StoredSettings.instance.game)))
        self._productManager = .init(wrappedValue: ProductManager.instance)
    }
    
    // MARK: - View builder
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("player".localized)) {
                    List {
                        TextFieldView(text: self.$selectedSettings.displayName, label: "name".localized)
                    }
                }
                
                Section(header: Text("game".localized)) {
                    List {
                        NavigationLink(destination: {
                            List {
                                ForEach(GameConfigs.sharedInstance.configArray, id: \.self.gameType) { gameConfig in
                                    PickerCellView(value: gameConfig.gameType.rawValue, selectedValue: self.$selectedSettings.game, confirmationAlertTitle: String(format: UIStrings.wouldYouLikeToPurchase, gameConfig.gameType.name.localized), canBePickedWithoutConfirmation: self.canGameBeSelected, confirmationAction: self.purchaseGame) {
                                        Text(gameConfig.gameType.name.localized)
                                    }
                                    .rightContent {
                                    if let productId = gameConfig.productId, let productInfo = self.productManager.products[productId] {
                                            if !productInfo.purchased {
                                                if productInfo.purchasing {
                                                    ProgressView()
                                                } else {
                                                    Text(productInfo.price)
                                                }
                                            }
                                        }

                                    }
                                }
                            }.navigationTitle("game".localized)
                                .navigationBarTitleDisplayMode(.inline)
                        }) {
                            HStack {
                                Text("game".localized)
                                Spacer()
                                Text(GameType(rawValue: self.selectedSettings.game)?.name.localized ?? "").foregroundColor(.secondary)
                            }
                        }
                        
                        if let gameConfig = self.selectedGameConfig {
                            if gameConfig.canChangeDeck {
                                // TODO: customize deck view
                                NavigationLink(destination: {
                                    List {
                                        ForEach(CardDecks.instance.decks, id: \.self.name) { deck in
                                            //Text(deck.name)
                                            
                                            PickerCellView(value: deck, selectedValue: self.$selectedSettings.deck) {
                                                Text(deck.name.localized)
                                            }
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("deck".localized)
                                        Spacer()
                                        Text(self.selectedSettings.deck.name.localized).foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            if gameConfig.canChangeCardSize {
                                NavigationLink(destination: {
                                    GeometryReader { geo in
                                        SettingsCardSizeView(cardWidthsPerScreen: self.$selectedSettings.cardWidthsPerScreen, screenWidth: Float(geo.size.width))
                                    }
                                }) {
                                    HStack {
                                        Text("card size".localized)
                                        Spacer()
                                        Text((self.selectedSettings.presetCardSize ?? "custom").localized)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    List {
                        HStack {
                            Toggle(isOn: self.$selectedSettings.soundOn) {
                                Text("sound".localized)
                            }
                        }
                    }
                }
                
                Section(header: Text(UIStrings.store)) {
                    List {
                        HStack {
                            Button(action: {
                                self.productManager.restorePurchased()
                            }) {
                                Text(UIStrings.restorePurchases)
                            }.buttonStyle(.automatic)
                        }
                    }
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarItems(trailing: Button("done".localized) {
                dismiss()
                self.didFinish()
            })
            .onChange(of: self.selectedSettings.game) { _ in
                if let gameType = GameType(rawValue: self.selectedSettings.game) {
                    withAnimation() {
                        self.didSelectGame(ofType: gameType)
                    }
                }
            }
        }
        .onAppear() {
            self.productManager.fetchProductInformation()
        }
    }
    
    // MARK: - Private methods
    
    /// Determines whether the game can be selected or is an unpurchased product
    private func canGameBeSelected(value: Int) -> Bool {
        if let gameType = GameType(rawValue: value), let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType) {
            if gameConfig.productId == nil {
                return true
            }
            
            if let productId = gameConfig.productId, let productInfo = self.productManager.products[productId] {
                if productInfo.purchased {
                    return true
                }
                
                #if DEBUG
                return true
                #endif
            }
        }
        
        return false
    }
    
    // TODO: game purchase
    /// Purchases the game
    private func purchaseGame(value: Int) {
        if let gameType = GameType(rawValue: value), let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType), let productId = gameConfig.productId {
            
            self.productManager.purchase(productId: productId)
        }
    }
    
    // TODO: move to TemporarySettings?
    /// Loads saved or default settings based on game type
    private func didSelectGame(ofType gameType: GameType) {
        if let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType) {
            selectedGameConfig = gameConfig
            
            if gameConfig.canChangeDeck {
                let gameSettings = StoredGameSettings(with: gameType)
                self.selectedSettings.sync(to: gameSettings)
            } else if gameConfig.canChangeCardSize {
                let gameSettigs = StoredGameSettings(with: gameType)
                self.selectedSettings.sync(to: gameConfig.defaultSettings)
                self.selectedSettings.syncUI(to: gameSettigs)
            } else {
                self.selectedSettings.sync(to: gameConfig.defaultSettings)
            }
        }
    }
    
    // TODO: move to Temporary settings?
    /// Stores setting and calls delegate method
    private func didFinish() {
        if let gameType = GameType(rawValue: self.selectedSettings.game) {
            let gameSettings = StoredGameSettings(with: gameType)
            gameSettings.sync(to: self.selectedSettings)
        }
        
        if self.selectedSettings.game != StoredSettings.instance.game {
            self.selectedSettings.store()
            self.delegate?.gameChanged()
        } else if self.selectedSettings.deck != StoredSettings.instance.deck {
            self.selectedSettings.store()
            self.delegate?.settingsChanged()
        } else if self.selectedSettings.cardWidthsPerScreen != StoredSettings.instance.cardWidthsPerScreen {
            self.selectedSettings.store()
            self.delegate?.uiSettingsChanged()
        } else {
            self.selectedSettings.store()
        }
    }
}

