//
//  UserSignUpModel.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation

class UserSignUpModel: NSObject {
    
    func userSignUp() -> String { // 2
        let urlPath = URLPATH + "userSignUp.jsp"
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        var uSeqno: String = "0"
        
        // task 가 끝날때까지 기다리기위한 준비
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = defaultSession.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print("Failed to Insert Data : \(String(describing: error))")
            } else {
                print("Data is Inserted")
                
                // Data to String
                uSeqno = String(data: data!, encoding: .utf8)!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                print("uSeqno = \(uSeqno)")
            }
            
            // task 가 끝나면 신호를 준다.
            semaphore.signal()
        }
        
        task.resume()
        
        // task 의 신호를 기다렷다가 받는다.
        _ = semaphore.wait(timeout: .distantFuture)
        
        print("return uSeqno = \(uSeqno)")
        return uSeqno
    }
}
