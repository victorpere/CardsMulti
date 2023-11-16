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
    var screenWidth: Float
    
    @State private var cardWidth: Float = 0
    @State private var customSize = false
    
    private let minCardWidth: Float
    private let maxCardWidth: Float
    private let uiImage = UIImage(named: "back")
    
    init(cardWidthsPerScreen: Binding<Float>, screenWidth: Float) {
        self._cardWidthsPerScreen = cardWidthsPerScreen
        self.screenWidth = screenWidth
        self.minCardWidth = screenWidth / Config.maxCardWidthsPerScreen
        self.maxCardWidth = screenWidth / Config.minCardWidthsPerScreen
    }
    
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
                    
                    if self.customSize {
                        Slider(value: self.$cardWidth.animation(), in: self.minCardWidth...self.maxCardWidth)
                            .padding([.leading,.trailing], 10)
                            .padding([.top], 40)
                    } else {
                        Button("custom".localized) {
                            withAnimation() {
                                self.customSize = true
                            }
                        }.padding([.top], 40)
                            .padding([.bottom],10)
                    }
                }
                .onChange(of: self.cardWidth) { cardWidth in
                    self.cardWidthsPerScreen = self.screenWidth / cardWidth
                    if Config.presetCardWidthsPerScreen.contains(where: { w in w.value == self.cardWidthsPerScreen }) {
                        withAnimation() {
                            self.customSize = false
                        }
                    }
                }
                .onAppear() {
                    self.cardWidth = self.screenWidth / self.cardWidthsPerScreen
                    if !Config.presetCardWidthsPerScreen.contains(where: { w in w.value == self.cardWidthsPerScreen }) {
                        self.customSize = true
                    }
                }
            }
        }
    }
}
