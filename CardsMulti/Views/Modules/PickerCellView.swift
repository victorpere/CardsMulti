//
//  PickerCellView.swift
//  CardsMulti
//
//  Created by Victor on 2023-10-23.
//  Copyright © 2023 Victorius Software Inc. All rights reserved.
//

import SwiftUI

struct PickerCellView<Content: View>: View {
    
    /// Value representing the item
    var value: Int
    
    /// Binding for the value representing the selected item
    @Binding var selectedValue: Int
    
    /// Title for confirmation dialog
    var confirmationAlertTitle: String = ""
    
    /// Closure to determine whether the item can be selected or requires a confirmation dialog
    var canBePickedWithoutConfirmation: ((Int) -> Bool) = { _ in return true }
    
    /// Closer to be executed after confirmation
    var confirmationAction: ((Int) -> Void)?
    
    /// Main content of the item
    @ViewBuilder let content: Content
    
    @State private var showingAlert = false
    
    /// Content to be displayed on the right side of the item
    func rightContent<RightContent: View>(@ViewBuilder _ rightContent: () -> RightContent) -> some View {
        HStack {
            self
            Spacer()
            rightContent()
        }
    }
    
    var body: some View {
        Button(action: {
            if self.selectedValue != self.value {
                if self.canBePickedWithoutConfirmation(self.value) {
                    self.selectedValue = self.value
                } else {
                    self.showingAlert = true
                }
            }
        }) {
            HStack {
                self.content
                Spacer()
                if self.selectedValue == self.value {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }.buttonStyle(.automatic)
            .foregroundColor(.primary)
            .confirmationDialog(self.confirmationAlertTitle, isPresented: self.$showingAlert, titleVisibility: .visible) {
                Button(UIStrings.ok) {
                    self.confirmationAction?(self.value)
                }
            }
    }
}
