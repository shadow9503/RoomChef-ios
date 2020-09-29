//
//  RefrigratorSelectAllModel.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

protocol RefrigratorModelProtocol: class {
    func itemDownloaded(items: NSArray, count: Int)
}

class RefrigratorSelectAllModel: NSObject {
    
    var delegate: RefrigratorModelProtocol!
    let urlPath = URLPATH + "Refrigerator_Select_All.jsp?uSeqno=\(USERSEQNO)"
    
    func downloadItems() { // 2
        print("Refrigrator : \(urlPath)")
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
        
        let decoder = JSONDecoder()
        let locations = NSMutableArray()
        var count: Int = 0
        
        if let jsonData = try? decoder.decode(RefrigratorDBModelStruct.self, from: data) {
            print(jsonData)
            count = jsonData.recent!.count
            
            for i in 0 ..< jsonData.recent!.count {
                let arrayData = RefrigratorDBModel()
                arrayData.rSeqno = jsonData.recent![i].rSeqno
                arrayData.rCategory = jsonData.recent![i].rCategory // 수정
                arrayData.rIngredient = jsonData.recent![i].rIngredient
                arrayData.rShelfLife = jsonData.recent![i].rShelfLife
                arrayData.User_uSeqno = jsonData.recent![i].User_uSeqno
                
                print(arrayData)
                locations.add(arrayData)
            }
            
            for i in 0 ..< jsonData.next!.count {
                let arrayData = RefrigratorDBModel()
                arrayData.rSeqno = jsonData.next![i].rSeqno
                arrayData.rCategory = jsonData.next![i].rCategory// 수정
                arrayData.rIngredient = jsonData.next![i].rIngredient
                arrayData.rShelfLife = jsonData.next![i].rShelfLife
                arrayData.User_uSeqno = jsonData.next![i].User_uSeqno
                
                print(arrayData)
                locations.add(arrayData)
            }
        }
        
        DispatchQueue.main.async(execute: {() -> Void in
            self.delegate.itemDownloaded(items: locations, count: count)
        })
    }
}
