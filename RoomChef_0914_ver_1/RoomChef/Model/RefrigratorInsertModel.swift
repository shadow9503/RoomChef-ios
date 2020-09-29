//
//  RefrigratorInsertModel.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/09.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

class RefrigratorInsertModel: NSObject {
    
    var urlPath = URLPATH + "Refrigrator_Insert.jsp"
    
    func insertItems(rCategory: String, rIngredient: String, rShelfLife: String) { // 2
        let urlAdd = "?rCategory=\(rCategory)&rIngridents=\(rIngredient)&rShelfLife=\(rShelfLife)&uSeqno=\(USERSEQNO)" // urlPath 뒤에 입력할 내용을 추가하기위해 만든 변수
        urlPath = urlPath + urlAdd
        
        // 한글 url encoding
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print("Failed to Insert Data : \(String(describing: error))")
            } else {
                print("Data is Inserted")
            }
        }
        
        task.resume()
    }
}
