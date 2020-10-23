//
//  reviewInsertModel.swift
//  Review
//
//  Created by leesu on 2020/09/09.
//  Copyright © 2020 leesu. All rights reserved.
//

import Foundation

class ReviewInsertModel:NSObject{
    
    // MARK: Img Upload
    func buildBody(with fileURL: URL, parameters: [String: String]?) -> Data? {
        // 파일을 읽을 수 없다면 nil을 리턴
        guard let filedata = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        // 바운더리 값을 정하고,
        // 각 파트의 헤더가 될 라인들을 배열로 만든다.
        // 이 배열을 \r\n 으로 조인하여 한 덩어리로 만들어서
        // 데이터로 인코딩한다.
        let boundary = "XXXXX"
        let mimetype = "image/jpeg"
        let headerLines = ["--\(boundary)",
            "Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"",
            "Content-Type: \(mimetype)",
            "\r\n"]
        var data = headerLines.joined(separator:"\r\n").data(using:.utf8)!
        
        // 그 다음에 파일 데이터를 붙이고
        data.append(contentsOf: filedata)
        data.append(contentsOf: "\r\n".data(using: .utf8)!)
        
        // 일반적인 데이터 넣을때 사용하는 폼
        // --\(boundary)\r\n
        // Content-Disposition: form-data; name=\"name\"\r\n\r\n
        // value\r\n
        if parameters != nil {
            for (key, value) in parameters! {
                let lines = ["--\(boundary)","Content-Disposition: form-data; name=\"\(key)\"\r\n","\(value)\r\n"]
                data.append(contentsOf: lines.joined(separator: "\r\n").data(using: .utf8)!)
            }
        }
        
        // 마지막으로 데이터의 끝임을 알리는 바운더리를 한 번 더 사용한다.
        // 이는 '새로운 개행'이 필요하므로 앞에 \r\n이 있어야 함에 유의 한다.
        data.append(contentsOf: "\r\n--\(boundary)--".data(using:.utf8)!)
        return data
    }
    
    func uploadImageFile(at filepath: URL, name: String, content: String, completionHandler: @escaping(Data?, URLResponse?) -> Void) {
        // 경로를 준비하고
        let url = URL(string: URLPATH + "Review_Insert_ios.jsp")!
        
        print(url)
        
        let parameters = [
            "name" : name,
            "content" : content,
            "User_uSeqno" : String(USERSEQNO),
            "Recipe_rSeqno" : String(RECIPESEQNO)
        ]
        print("parameters = \(parameters)")
        
        // 경로로부터 요청을 생성한다. 이 때 Content-Type 헤더 필드를 변경한다.
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\"XXXXX\"",
                         forHTTPHeaderField: "Content-Type")
        
        // 파일URL로부터 multipart 데이터를 생성하고 업로드한다.
        if let data = buildBody(with: filepath, parameters: parameters) {
            let task = URLSession.shared.uploadTask(with: request, from: data){ data, res, _ in
                completionHandler(data, res)
            }
            task.resume()
        }
    }
}
