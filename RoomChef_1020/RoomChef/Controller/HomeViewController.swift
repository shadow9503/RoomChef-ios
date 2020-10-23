//
//  HomeViewController.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/04.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import UIKit
import SQLite3

var USERSEQNO: Int = 4
var RECIPESEQNO: Int = 1
var CATEGORYNUM: Int = 22
var URLPATH: String = "http://192.168.219.102:8080/RoomChef/"
//var URLPATH: String = "http://172.30.71.158:8080/RoomChef/"


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, LimitIngredientsQueryProtocol{
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    // 유통기한 다되어가는 재료 3가지
    @IBOutlet weak var lblLimitIngredient1: UILabel!
    @IBOutlet weak var lblLimitIngredient2: UILabel!
    @IBOutlet weak var lblLimitIngredient3: UILabel!
    
    @IBOutlet weak var lblLimitDate1: UILabel!
    @IBOutlet weak var lblLimitDate2: UILabel!
    @IBOutlet weak var lblLimitDate3: UILabel!
    
    // 유저 시퀀스

    // 요리 종류
    let text = ["밑반찬", "메인반찬", "국/탕", "찌개", "디저트", "면/만두", "밥/죽/떡", "퓨전", "김치/젓갈/장류", "양념/소스/잼", "양식", "샐러드", "스프", "빵", "과자", "차/음료/술", "기타"]
    
    // 요리 이미지
    let images = ["1.JPG", "2.JPG", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.JPG", "9.jpg", "10.jpg", "11.jpg", "12.jpg", "13.jpg", "14.JPG", "15.JPG", "16.JPG", "17.jpg"] // 수정
    
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 유저 시퀀스 값을 가져가 DB 데이터 가져오기
        user()
        
        let limitIngredientsQuery = LimitIngredientsQuery()
        limitIngredientsQuery.delegate = self
        limitIngredientsQuery.downloadItems(seq: USERSEQNO)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let limitIngredientsQuery = LimitIngredientsQuery()
        limitIngredientsQuery.delegate = self
        limitIngredientsQuery.downloadItems(seq: USERSEQNO)
    }
    
    // MARK: - CollectionView
        
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // CollectionView 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 17
    }
        
    // 컬렉션 뷰의 셀의 크기를 정하는 함수 ( class 이름 옆에 UICollectionViewDelegateFlowLayout Protocol 을 추가해야한다. )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 5
            
        return CGSize(width: width, height: width + 40)
    }
        
    // CollectionView 의 Cell 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! HomeCollectionViewCell
        
        // 이미지와 음식 종류 넣기
        cell.imgView.image = UIImage(named: images[indexPath.row])
        cell.lblSort.text = text[indexPath.row]
        
        return cell
    }
        
    // 컬렉션 뷰의 셀을 클릭했을때 나오는 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let categoryNum = indexPath.row + 22
        CATEGORYNUM = categoryNum
        
        tabBarController?.selectedIndex = 1
    }
    
    // MARK: - DB Data Downlod
    // DB 데이터 가져오기
    func itemDownloaded(items: NSArray) {
        let limitIngredients = [lblLimitIngredient1, lblLimitIngredient2, lblLimitIngredient3]
        
        let limitDates = [lblLimitDate1, lblLimitDate2, lblLimitDate3]
        
        let limitItems = items
            
        for i in 0..<limitItems.count{
            // 유통기한이 지나지 않은 유통기한이 가장 가까운 3개 가져오기
            let item: LimitIngredients = limitItems[i] as! LimitIngredients
            limitIngredients[i]?.text = item.limitIngredient
            limitDates[i]?.text = item.limitDate
        }
    }

    // MARK: - User Check
    func user() {
        // SQLite 생성하기
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("UserData.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening databases")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS User (uSeqno INTEGER PRIMARY KEY AUTOINCREMENT)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if userCheck() {
            let userSignUpModel = UserSignUpModel()
            print("유저",USERSEQNO)
            USERSEQNO = Int(userSignUpModel.userSignUp())!
            print("유저",USERSEQNO)
            userInsert(uSeqno: USERSEQNO)
        } else {
            print("유저/",USERSEQNO)
            USERSEQNO = userSelect()
            print("유저/",USERSEQNO)
        }
        
        print("UserSeqno = \(USERSEQNO)")
    }
    
    // App 에 User 등록
    func userInsert(uSeqno: Int) {
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO User(uSeqno) VALUES(?)"
        
        // query 문 준비
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(uSeqno)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding id: \(errmsg)")
        }
        
        // Data 를 저장하는 부분
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure insert data: \(errmsg)")
            
            return
        }
        
        print("Student saved successfully")
    }
    
    // User 가 앱에 등록되어있는지 확인
    func userCheck() -> Bool {
        let queryString = "SELECT count(uSeqno) FROM User"
        
        var stmt: OpaquePointer?
        var check: Bool = false
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return check
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            let count = sqlite3_column_int(stmt, 0)
            
            print("count : \(count)")
            
            if count == 0 {
                check = true
            } else {
                check = false
            }
        }
        
        return check
    }
    
    // userSeqno 찾아오기
    func userSelect() -> Int {
        let queryString = "SELECT uSeqno FROM User"
        
        var stmt: OpaquePointer?
        var uSeqno: Int = USERSEQNO
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            return uSeqno
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            let seqno = sqlite3_column_int(stmt, 0)
            uSeqno = Int(seqno)
        }
        
        return uSeqno
    }

}
