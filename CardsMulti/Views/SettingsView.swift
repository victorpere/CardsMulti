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
    
    @StateObject var selectedSettings: TemporarySettings
    
    weak var delegate: SettingsDelegate?
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initializers
    
    init(delegate: SettingsDelegate?) {
        self.delegate = delegate
        self._selectedSettings = .init(wrappedValue: TemporarySettings(with: StoredSettings.instance))
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
                                    PickerCellView(value: gameConfig.gameType.rawValue, selectedValue: self.$selectedSettings.game) {
                                        Text(gameConfig.gameType.name.localized)
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
                    self.didSelectGame(ofType: gameType)
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    // TODO: move to TemporarySettings?
    /// Loads saved or default settings based on game type
    private func didSelectGame(ofType gameType: GameType) {
        if let gameConfig = GameConfigs.sharedInstance.gameConfig(for: gameType) {
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
        if self.selectedSettings.game != StoredSettings.instance.game {
            self.selectedSettings.store()
            self.delegate?.gameChanged()
        } else {
            self.selectedSettings.store()
        }
    }
}

