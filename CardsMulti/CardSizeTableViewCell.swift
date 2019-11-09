//
//  CardSizeTableViewCell.swift
//  CardsMulti
//
//  Created by Victor on 2019-11-06.
//  Copyright © 2019 Victorius Software Inc. All rights reserved.
//

import UIKit

class CardSizeTableViewCell : UITableViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    
    func scaleImage(to width: CGFloat) {
        if let cardImage = self.cardImage {
            let newSize = CGSize(width: width, height: cardImage.frame.height)
            self.cardImage.frame = CGRect(center: self.cardImage.center, size: newSize)
        }
    }
}

