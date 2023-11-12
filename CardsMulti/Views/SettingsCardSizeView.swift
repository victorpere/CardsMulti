//
//  SettingsCardSizeView.swift
//  CardsMulti
//
//  Created by Victor on 2023-11-11.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct SettingsCardSizeView: View {
    @Binding var cardWidthsPerScreen: Float
    
    @State private var cardSize: Float = 0
    private let screenWidth = Float(UIScreen.main.bounds.width)
    
    var body: some View {
        VStack {
            Text(String(format: "%.2f", self.cardSize))
            
            Slider(value: self.$cardSize, in: self.screenWidth / Config.maxCardWidthsPerScreen...self.screenWidth / Config.minCardWidthsPerScreen, onEditingChanged: { _ in
                self.cardWidthsPerScreen = self.screenWidth / self.cardSize
            })
                .padding([.leading,.trailing], 10)
            
        }
        .onAppear() {
            self.cardSize = self.screenWidth / self.cardWidthsPerScreen
        }
    }
}
