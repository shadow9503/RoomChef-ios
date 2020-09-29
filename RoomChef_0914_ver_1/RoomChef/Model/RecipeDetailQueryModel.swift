//
//  RecipeDetailQueryModel.swift
//  RoomChef
//
//  Created by 유영훈 on 2020/09/10.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

protocol RecipeDetailQueryModelProtocol: class{
    func itemDownloaded(items: NSArray) // TableViewController 에서 호출할 함수 선언
}

class RecipeDetailQueryModel: NSObject{
    var delegate: RecipeDetailQueryModelProtocol!
    var urlPath = URLPATH + "RecipeDetail_Query.jsp"
    
    // 레시피 상세 페이지에 관한 정보만 가져옴
    func downloadSingleItem(rSeqno: String){
        let urlAddr = "?rSeqno=\(rSeqno)"
        urlPath += urlAddr
        
        // 한글 url encoding
        urlPath = urlPath.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        print(urlPath)
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        // task 가 끝날때까지 기다리기위한 준비
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil{
                print("Failed to download data")
            }else{
                print("Recipe Single Data downloaded")
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
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        }catch let error as NSError{
            print("RecipeSingleDataJSONParse.Error :", error)
        }
//        print("jsonResult:", jsonResult)
        
        // JSON을 NSDictionary로 담아온다.
        var jsonElement = NSDictionary()
        let locations = NSMutableArray()
//        print(jsonResult.count)
        for i in 0..<jsonResult.count{
            jsonElement = jsonResult[i] as! NSDictionary
            let query = RecipeModel()
            if let rIntro = jsonElement["rIntro"] as? String,
                let rSummary = jsonElement["rSummary"] as? String,
                let rIngredient = jsonElement["rIngredient"] as? Dictionary<String, Any>,
                let rTip = jsonElement["rTip"] as? String,
                let rDate = jsonElement["rDate"] as? String,
                let rfImagePath = jsonElement["rfImagePath"] as? Dictionary<String, Any>,
                let rfContent = jsonElement["rfContent"] as? Dictionary<String, Any>{
                    query.rIntro = rIntro
                    query.rSummary = rSummary
                    query.rIngredient = rIngredient as NSDictionary
                    query.rTip = rTip
                    query.rDate = rDate
                    query.rfImagePath = rfImagePath as NSDictionary
                    query.rfContent = rfContent as NSDictionary
//                    print(rfContent as Any)
//                    print("query: ", query)
            }//--- if
            locations.add(query)
            
        }//--- for
        
        // Async 방식 함수 호출
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownloaded(items: locations)
        })
        
        
    }//-------Parse
    
    
}//------END
