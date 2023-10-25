//
//  TextFieldView.swift
//  Notifications-Form
//
//  Created by Victor on 2023-10-16.
//

import SwiftUI

struct TextFieldView: View {
    @Binding var text: String
    var label: String
    
    var body: some View {
        NavigationLink(destination: TextEditView(text: self.$text, label: self.label)) {
            HStack {
                Text(self.label)
                Spacer()
                Text(self.text).foregroundColor(.secondary)
            }
        }
    }
}
