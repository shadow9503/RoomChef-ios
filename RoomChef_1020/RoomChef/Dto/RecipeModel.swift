//
//  RecipeModel.swift
//  RoomChef
//
//  Created by 유영훈 on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import Foundation
import UIKit

class RecipeModel: NSObject{
    
    // Properties
    var rSeqno: String?
    var rTitle: String?
    var rIntro: String?
    var rSummary: String?
    var rIngredient: NSDictionary?
    var rLikeNum: String?
    var rTip: String?
    var rDate: String?
    var rfThumbnailImage: String?
    var rfImagePath: NSDictionary?
    var rfContent: NSDictionary?
    var rCategory: String?
    var lSeqno: String?
    
    var imageData: UIImage? // 레시피 목록 이미지 객체
    var recipeImageData: [UIImage]? // 레시피 조리순서 이미지 객체
    var imagePath: [String]?
    
    // Empty constructor.   빈 생성자를 만들수 있음.
    override init() {
        
    }
    
    // 레시피 목록데이터 모델
    init(rSeqno: String, rTitle: String, rLikeNum: String, rfThumbnailImage: String, rIntro: String, rSummary: String, rIngredient: NSDictionary, rTip: String, rDate: String, rfImagePath: NSDictionary, rfContent: NSDictionary, lSeqno: String) {
        self.rSeqno = rSeqno
        self.rTitle = rTitle
        self.rLikeNum = rLikeNum
        self.rfThumbnailImage = rfThumbnailImage
        self.rIntro = rIntro
        self.rSummary = rSummary
        self.rIngredient = rIngredient
        self.rTip = rTip
        self.rDate = rDate
        self.rfImagePath = rfImagePath
        self.rfContent = rfContent
        self.lSeqno = lSeqno
    }
    
    // 메모라이제이션 이미지 객체화에 필요한 생성자
    init(imageData: UIImage){
        self.imageData = imageData
    }
    
    init(recipeImageData: [UIImage]){
        self.recipeImageData = recipeImageData
    }
    
    init(imagePath: [String]){
        self.imagePath = imagePath
    }
    
}
