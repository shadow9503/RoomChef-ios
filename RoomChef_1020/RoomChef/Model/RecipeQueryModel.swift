//
//  RecipeQueryModel.swift
//  RoomChef
//
//  Created by 유영훈 on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

protocol RecipeQueryModelProtocol: class{
    func itemDownloaded(items: NSArray, category: String) // TableViewController 에서 호출할 함수 선언
}

class RecipeQueryModel: NSObject{
    var delegate: RecipeQueryModelProtocol!
    var urlPath = URLPATH + "Recipe_QueryAll.jsp"
    
    // 서버에 jsp파일을 실행시켜 쿼리결과물을 가져온다.
    func downloadItems(uSeqno: Int, rCategory: Int, rLike: Int, order: String, keyword: String, startIndex: Int, count: Int){
        
        let urlAddr = "?uSeqno=\(uSeqno)&rCategory=\(rCategory)&rLike=\(rLike)&order=\(order)&keyword=\(keyword)&startIndex=\(startIndex)&count=\(count)"
        urlPath += urlAddr
        print(urlPath)
        
        // 한글 url encoding
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        // task 가 끝날때까지 기다리기위한 준비
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil{
                print("Failed to download data")
            }else{
                print("Data is downloaded")
                // parse. data에 쿼리결과물이 담김
                self.parseJSON(data!)
            }
            // task 가 끝나면 신호를 준다.
            semaphore.signal()


        }
        task.resume()
        
        // task 의 신호를 기다렷다가 받는다.
        _ = semaphore.wait(timeout: .distantFuture)


    }
    
    // JSON파싱 메소드
    func parseJSON(_ data: Data){
//        print("parseJSON()")
        var category: String = ""
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        }catch let error as NSError{
            print(error)
        }
        // JSON을 NSDictionary로 담아온다.
        var jsonElement = NSDictionary()
        let locations = NSMutableArray()
        
        for i in 0..<jsonResult.count{
            jsonElement = jsonResult[i] as! NSDictionary
            let query = RecipeModel()
            if let rSeqno = jsonElement["rSeqno"] as? String,
                let rTitle = jsonElement["rTitle"] as? String,
                let rLikeNum = jsonElement["rLikeNum"] as? String,
                let rfThumbnailImage = jsonElement["rfThumbnailImage"] as? String,
                let rCategory = jsonElement["rCategory"] as? String,
                let rIntro = jsonElement["rIntro"] as? String,
                let rSummary = jsonElement["rSummary"] as? String,
                let rIngredient = jsonElement["rIngredient"] as? Dictionary<String, Any>,
                let rTip = jsonElement["rTip"] as? String,
                let rDate = jsonElement["rDate"] as? String,
                let rfImagePath = jsonElement["rfImagePath"] as? Dictionary<String, Any>,
                let rfContent = jsonElement["rfContent"] as? Dictionary<String, Any>,
                let lSeqno = jsonElement["lSeqno"] as? String{
                query.rSeqno = rSeqno
                query.rTitle = rTitle
                query.rLikeNum = rLikeNum
                query.rfThumbnailImage = rfThumbnailImage
                query.rIntro = rIntro
                query.rSummary = rSummary
                query.rIngredient = rIngredient as NSDictionary
                query.rTip = rTip
                query.rDate = rDate
                query.rfImagePath = rfImagePath as NSDictionary
                query.rfContent = rfContent as NSDictionary
                query.lSeqno = lSeqno
                category = rCategory
            }
            locations.add(query)
        }//--- for
        
// Async 방식 함수 호출
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownloaded(items: locations, category: category)
        })
    }

}//------
