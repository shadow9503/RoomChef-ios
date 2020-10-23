//
//  DBModel.swift
//  Review
//
//  Created by leesu on 2020/09/09.
//  Copyright © 2020 leesu. All rights reserved.
//

import Foundation

class ReviewDBModel: NSObject{
    var rSeqno : String?
    var rName: String?
    var rContent: String?
    var rImagePath: String?
    var rDate:String?
    var User_uSeqno:String?
    var Recipe_rSeqno:String?
    
    override init(){
        
    }    
    
    init(rSeqno:String, rName:String, rContent:String, rImagePath:String, rDate:String, User_uSeqno:String, Recipe_rSeqno:String){
        self.rSeqno = rSeqno
        self.rImagePath = rImagePath
        self.rContent = rContent
        self.rName = rName
        self.rDate = rDate
        self.User_uSeqno = User_uSeqno
        self.Recipe_rSeqno = Recipe_rSeqno
        
    }
}
