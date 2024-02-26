//
//  TextFieldView.swift
//  Notifications-Form
//
//  Created by Victor on 2023-10-16.
//

import SwiftUI

struct TextFieldView: View {
    @Binding var text: String
    let label: String
    
    let doneAction: (() -> Void)
    
    var body: some View {
        NavigationLink(destination: TextEditView(text: self.$text, label: self.label, trailingBarItem: {
            Button("done".localized) {
                self.doneAction()
            }
        })) {
            HStack {
                Text(self.label)
                Spacer()
                Text(self.text).foregroundColor(.secondary)
            }
        }
    }
}
