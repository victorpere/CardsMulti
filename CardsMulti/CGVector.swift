//
//  CGVector.swift
//  CardsMulti
//
//  Created by Victor on 2019-10-26.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

extension CGVector {
    var direction: MovingDirection {
        get {
            return MovingDirection(transformation: CGPoint(x: self.dx, y: self.dy)) ?? .none
        }
    }
}
