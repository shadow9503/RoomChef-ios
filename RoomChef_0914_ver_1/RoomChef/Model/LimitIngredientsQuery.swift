//
//  LimitIngredientsQuery.swift
//  RoomChef
//
//  Created by TJ on 2020/09/07.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

protocol LimitIngredientsQueryProtocol: class {
    func itemDownloaded(items: NSArray)
}

class LimitIngredientsQuery: NSObject{
    
    var delegate: LimitIngredientsQueryProtocol!
    var urlPath = URLPATH + "limit_ingredients_query.jsp"
    
    func downloadItems(seq: Int){
        let urlAdd = "?seq=\(seq)"
        urlPath += urlAdd
        print("limit = \(urlPath)")
        
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        
        let task = defaultSession.dataTask(with: url){(data, response, error) in
            if error != nil{
                print("Failed to download data")
            }else{
                print("Data is downloaded")
                self.parseJSON(data!)
            }
        }
        task.resume()
    }
    
    func parseJSON(_ data: Data){
        var jsonResult = NSArray()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        }catch let error as NSError{
            print(error)
        }
        
        var jsonElement = NSDictionary()
        let locations = NSMutableArray()
        
        for i in 0..<jsonResult.count{
            jsonElement = jsonResult[i] as! NSDictionary
            let query = LimitIngredients()
            
            if let ingredient = jsonElement["ingredient"] as? String,
               let date = jsonElement["date"] as? String{
                query.limitIngredient = ingredient
                query.limitDate = date
            }
            locations.add(query)
        }
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownloaded(items: locations)
        })
    }
}
