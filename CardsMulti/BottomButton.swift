//
//  BottomButton.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-11.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class BottomButton: UIButton {
    
    let buttonMargin: CGFloat = 8.0
    let name: String?
    var action: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withIconNamed icon: String, viewFrame: CGRect, buttonNumber: CGFloat, numberOfButtons: CGFloat, tag: Int, name: String? = nil, action: (() -> Void)? = nil) {
        let icon = UIImage(named: icon)
        let gapBetweenButtons = (viewFrame.width - 2 * self.buttonMargin - (icon?.size.width)!) / (numberOfButtons - 1)
        let frame = CGRect(x: viewFrame.minX + self.buttonMargin + gapBetweenButtons * buttonNumber, y: viewFrame.minY + viewFrame.height - self.buttonMargin - (icon?.size.height)!, width: (icon?.size.width)!, height: (icon?.size.height)!)
        self.name = name
        self.action = action
        
        super.init(frame: frame)
        
        self.setImage(icon, for: .normal)
        self.tag = tag
    }
}
