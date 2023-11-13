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
    
    @State private var cardWidth: Float = 0
    private let screenWidth = Float(UIScreen.main.bounds.width)
    private let minCardWidth = Float(UIScreen.main.bounds.width) / Config.maxCardWidthsPerScreen
    private let maxCardWidth = Float(UIScreen.main.bounds.width) / Config.minCardWidthsPerScreen
    private let uiImage = UIImage(named: "back")
    
    var body: some View {
        Form {
            List {
                VStack() {
                    if let uiImage = self.uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: CGFloat(self.cardWidth), height: uiImage.size.height * CGFloat(self.maxCardWidth) / uiImage.size.width)
                    }
                    
                    Picker("" ,selection: self.$cardWidth.animation()) {
                        ForEach (Config.presetCardWidthsPerScreen, id: \.self.value) { presetCardWidth in
                            Text(presetCardWidth.key.localized).tag(self.screenWidth / presetCardWidth.value)
                        }
                    }
                    .padding([.top], 20)
                    .pickerStyle(.segmented)
                    
                    Slider(value: self.$cardWidth.animation(), in: self.minCardWidth...self.maxCardWidth)
                        .padding([.leading,.trailing], 10)
                        .padding([.top], 40)
                    
                }
                .onChange(of: self.cardWidth) { _ in
                    self.cardWidthsPerScreen = self.screenWidth / self.cardWidth
                }
                .onAppear() {
                    self.cardWidth = self.screenWidth / self.cardWidthsPerScreen
                }
            }
        }
    }
}
