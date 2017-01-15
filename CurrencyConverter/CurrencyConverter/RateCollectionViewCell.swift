//
//  RateCollectionViewCell.swift
//  CurrencyConverter
//
//  Created by Michael Wasserman on 2017-01-14.
//  Copyright © 2017 Wasserman. All rights reserved.
//

import UIKit

class RateCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func render(code:String, amount:String) {
        codeLabel.text       = code
        amountLabel.text     = amount
        self.backgroundColor = UIColor.white
    }
}
