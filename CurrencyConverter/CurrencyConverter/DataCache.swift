//
//  DataCache.swift
//  CurrencyConverter
//
//  Created by Michael Wasserman on 2017-01-15.
//  Copyright © 2017 Wasserman. All rights reserved.
//

import Foundation


class DataCache {
    
    var updateTime:Date
    var rates:Array<Rate> = []
    var baseCurr:String
    
    init(updateTime:Date, rates:Array<Rate>, baseCurr:String) {
        self.updateTime = updateTime
        self.rates       = rates
        self.baseCurr    = baseCurr
    }
    
}
