//
//  TextEditCell.swift
//  CardsMulti
//
//  Created by Victor on 2021-06-14.
//  Copyright © 2021 Victorius Software Inc. All rights reserved.
//

import UIKit

class TextEditCell: UITableViewCell {
    var delegate: TextEditCellDelegate?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var value: UITextField!
    @IBAction func editingDidEnd(_ sender: Any) {
        self.delegate?.didFinishEditing(self.value.text ?? "")
    }
}

extension TextEditCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        self.endEditing(true)
        return true
    }
}

// MARK: - TextEditCellDelegate protocol

protocol TextEditCellDelegate {
    func didFinishEditing(_ text: String)
}

