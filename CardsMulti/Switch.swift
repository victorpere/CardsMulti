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
    
    convenience init(width: CGFloat) {
        let frame = CGRect(x: 0, y: 0, width: width, height: 51)
        self.init(frame: frame)
        self.onTintColor = Config.mainColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

