//
//  RecipeLikeUpdateQueryModel.swift
//  RoomChef
//
//  Created by 유영훈 on 2020/09/14.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

class RecipeLikeUpdateQueryModel: NSObject {
    
    var urlPath = URLPATH + "RecipeDetailLike_Update.jsp"
    
    func updateLike(rSeqno: String, uSeqno: Int, swap: Int) { // 2
        let urlAdd = "?rSeqno=\(rSeqno)&uSeqno=\(uSeqno)" // urlPath 뒤에 입력할 내용을 추가하기위해 만든 변수
        switch swap{
            case 0:
                urlPath = URLPATH + "RecipeDetailLike_Delete.jsp"
                urlPath += urlAdd
            case 1:
                urlPath += urlAdd
            default:
                print("wrong num")
        }
        print("좋아요 업데이트", urlPath)
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print("Failed Like Update : \(String(describing: error))")
            } else {
                print("Like is Updated")
            }
        }
        
        task.resume()
    }
}
