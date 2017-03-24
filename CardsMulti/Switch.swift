//
//  Switch.swift
//  CardsMulti
//
//  Created by Victor on 2017-03-24.
//  Copyright © 2017 Victorius Software Inc. All rights reserved.
//

import UIKit

class Switch: UISwitch {
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.onTintColor = Config.mainColor
    }
}

