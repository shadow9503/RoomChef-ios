//
//  QuertModel.swift
//  Review
//
//  Created by leesu on 2020/09/09.
//  Copyright © 2020 leesu. All rights reserved.
//

import Foundation

protocol ReviewSelectModelProtocol: class {
    func itemDownloaded(items: NSArray)
}

class ReviewSelectModel: NSObject {
    
    var delegate: ReviewSelectModelProtocol!
    let urlPath = URLPATH + "Review_Select_ios.jsp?uSeqno=" + String(USERSEQNO) + "&rSeqno=" + String(RECIPESEQNO)  //"testInsert_query_ios.jsp" - 테스트용 jsp 이미지 없이 사용한 것 (후기목록)
    
    func downloadItems() { // 2
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print("Failed to download Data : \(String(describing: error))")
            } else {
                print("Data is downloaded")
                
                self.parseJson(data!)
            }
        }
        
        task.resume()
    }
    
    func parseJson(_ data: Data) {
        var jsonResult = NSArray()
        
        do {
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError {
            print("Json Parse Error : \(error)")
        }
        
        var jsonElement = NSDictionary()
        let locations = NSMutableArray()
        
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let query = ReviewDBModel()
            
            if let rSeqno: String = jsonElement["rSeqno"] as? String,
                let rName = jsonElement["rName"] as? String,
                let rImagePath = jsonElement["rImagePath"] as? String,
                let rContent = jsonElement["rContent"] as? String,
                let rDate = jsonElement["rDate"] as? String,
                let User_uSeqno = jsonElement["User_uSeqno"] as? String,
                let Recipe_rSeqno = jsonElement["Recipe_rSeqno"] as? String {
                                
                query.rSeqno = rSeqno
                query.rName = rName
                query.rContent = rContent
                query.rImagePath = rImagePath
                query.User_uSeqno = User_uSeqno
                query.Recipe_rSeqno = Recipe_rSeqno
                query.rDate = rDate
            }
            
            locations.add(query)
        }
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownloaded(items: locations)
        })
    }
}


