//
//  LimitIngredients.swift
//  RoomChef
//
//  Created by TJ on 2020/09/07.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

class LimitIngredients: NSObject{
    var limitIngredient: String?
    var limitDate: String?
    
    override init(){
        
    }
    
    init(limitIngredient: String, limitDate: String){
        self.limitIngredient = limitIngredient
        self.limitDate = limitDate
    }
}
