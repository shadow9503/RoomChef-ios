//
//  FridgeViewController.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import UIKit

class RefrigratorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, RefrigratorModelProtocol {

    @IBOutlet weak var collectionViewFridge: UICollectionView!
    
    var feedItem: NSArray = NSArray()
    
    let imagesName = ["sogogi.jpg", "piggogi.jpg", "chikingogi.jpg", "gogi.jpg", "vegita.jpg", "fish.jpg", "milk.jpg", "gagong.jpg", "rice.jpg", "flour.jpg", "ojing.jpg", "busut.jpeg", "fruit.JPG", "kong.jpg", "gogru.jpg", "17.jpg"]
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let refrigratorModel = RefrigratorSelectAllModel()
        refrigratorModel.delegate = self
        refrigratorModel.downloadItems()
        
    }

    
    
    // MARK: - DB Items
    func itemDownloaded(items: NSArray, count: Int) {
        feedItem = items
        self.count = count
        collectionViewFridge.reloadData()
    }
    
    func imageNum(rCategory: String) -> String {
        let ingridents: [String] = ["소고기", "돼지고기", "닭고기", "육류", "채소류", "해물류", "달걀/유제품", "가공식품류", "쌀", "밀가루", "건어물류", "버섯류", "과일류", "콩/견과류", "곡류", "기타"]
        
        let index = ingridents.firstIndex(of: rCategory) ?? 15
        
        return imagesName[index]
    }
    
    
    // MARK: - Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // CollectionView 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItem.count + 1
    }
    
    // CollectionView 의 Cell 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellFridge", for: indexPath) as! RefrigratorCollectionViewCell
                
        if indexPath.row == feedItem.count {
            cell.ImageView.image = UIImage(named: "plus_icon.png")
            cell.TitleLabel.text = ""
            cell.TitleLabelTextView.text = ""
            cell.expirationDateLabel.text = ""
            cell.expirationDateTextView.text = ""
        } else if indexPath.row < count {
            let item: RefrigratorDBModel = feedItem[indexPath.row] as! RefrigratorDBModel
            cell.backgroundColor = UIColor.gray
            cell.ImageView.image = UIImage(named: imageNum(rCategory: item.rCategory!))
            cell.TitleLabel.text = "\(item.rIngredient!)"
            cell.TitleLabelTextView.text = "\(item.rIngredient!)"
            cell.expirationDateLabel.text = "\(item.rShelfLife!)"
        } else {
            let item: RefrigratorDBModel = feedItem[indexPath.row] as! RefrigratorDBModel
            cell.backgroundColor = UIColor.white
            cell.ImageView.image = UIImage(named: imageNum(rCategory: item.rCategory!))
            cell.TitleLabel.text = "\(item.rIngredient!)"
            cell.TitleLabelTextView.text = "\(item.rIngredient!)"
            cell.expirationDateLabel.text = "\(item.rShelfLife!)"
            cell.expirationDateTextView.isEditable = false
            cell.expirationDateTextView.text = "\(item.rShelfLife!)"
        }
        
        return cell
    }
    
    // 컬렉션 뷰의 셀의 크기를 정하는 함수 ( class 이름 옆에 UICollectionViewDelegateFlowLayout Protocol 을 추가해야한다. )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 114, height: 240)
    }
    
    // 컬렉션 뷰의 셀을 클릭했을때 나오는 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == feedItem.count {
            let movePage = self.storyboard?.instantiateViewController(withIdentifier: "AddRefrigrator")
            self.navigationController?.pushViewController(movePage!, animated: true)
        }
    }
    
    
    
    // MARK: - Reload
    override func viewWillAppear(_ animated: Bool) {
        let refrigratorModel = RefrigratorSelectAllModel()
        refrigratorModel.delegate = self
        refrigratorModel.downloadItems()
    }

}
