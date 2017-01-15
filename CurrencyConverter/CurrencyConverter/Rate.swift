//
//  Rate.swift
//  CurrencyConverter
//
//  Created by Michael Wasserman on 2017-01-14.
//  Copyright © 2017 Wasserman. All rights reserved.
//

import Foundation

struct Rate {
    
    var currencyCode:String?
    var currentRate:String?
    
    init(currencyCode:String, currentRate:String) {
        self.currencyCode = currencyCode
        self.currentRate  = currentRate
    }
}
