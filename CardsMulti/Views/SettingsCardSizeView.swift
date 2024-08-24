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
    var editable: Bool
    
    @State private var cardWidth: Float = 0
    @State private var customSize = false
    
    private let minCardWidth: Float
    private let maxCardWidth: Float
    private let uiImageBack = UIImage(named: "back")
    private let uiImageFront = UIImage(named: "queen_of_hearts")
    
    init(cardWidthsPerScreen: Binding<Float>, screenWidth: Float, editable: Bool) {
        self._cardWidthsPerScreen = cardWidthsPerScreen
        self.screenWidth = screenWidth
        self.minCardWidth = screenWidth / Config.maxCardWidthsPerScreen
        self.maxCardWidth = screenWidth / Config.minCardWidthsPerScreen
        self.editable = editable
    }
    
    var body: some View {
        Form {
            List {
                VStack() {
                    HStack() {
                        if let uiImageBack = self.uiImageBack, let uiImageFront = self.uiImageFront {
                            let imageHeight = uiImageBack.size.height * CGFloat(self.maxCardWidth) / uiImageBack.size.width
                            
                            Image(uiImage: uiImageBack)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CGFloat(self.cardWidth), height: imageHeight)
                            
                            Image(uiImage: uiImageFront)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: CGFloat(self.cardWidth), height: imageHeight)
                        }
                    }
                    
                    if self.editable || !self.customSize {
                        Picker("" ,selection: self.$cardWidth.animation()) {
                            ForEach (Config.presetCardWidthsPerScreen, id: \.self.value) { presetCardWidth in
                                Text(presetCardWidth.key.localized).tag(self.screenWidth / presetCardWidth.value)
                            }
                        }
                        .disabled(!self.editable)
                        .padding([.top], 20)
                        .pickerStyle(.segmented)
                    }
                    
                    if self.customSize {
                        Slider(value: self.$cardWidth.animation(), in: self.minCardWidth...self.maxCardWidth)
                            .disabled(!self.editable)
                            .padding([.leading,.trailing], 10)
                            .padding([.top], 40)
                    } else if self.editable {
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
