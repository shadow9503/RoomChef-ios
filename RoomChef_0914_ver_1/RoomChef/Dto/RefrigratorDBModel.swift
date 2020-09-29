//
//  RefrigratorDBModel.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

struct RefrigratorDBModelStruct: Codable {
    var recent: [RefrigratorStruct]?
    var next: [RefrigratorStruct]?
}

struct RefrigratorStruct: Codable {
    var rSeqno: String?
    var rCategory: String? // 수정
    var rIngredient: String?
    var rShelfLife: String?
    var User_uSeqno: String?
}

class RefrigratorDBModel: NSObject {
    
    var rSeqno: String?
    var rCategory: String? // 수정
    var rIngredient: String?
    var rShelfLife: String?
    var User_uSeqno: String?
    
    override init() {
        
    }
    
    init(rSeqno: String, rCategory: String, rIngredient: String, rShelfLife: String, User_uSeqno: String) {
        self.rSeqno = rSeqno
        self.rCategory = rCategory // 수정
        self.rIngredient = rIngredient
        self.rShelfLife = rShelfLife
        self.User_uSeqno = User_uSeqno
    }
}
