//
//  AddRefrigratorViewController.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/08.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import UIKit

class AddRefrigratorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var ingredientPickerView: UIPickerView!
    @IBOutlet weak var ingredientName: UITextField!
    @IBOutlet weak var shelfLifeTextField: UITextField!
    
    let ingridents: [String] = ["소고기", "돼지고기", "닭고기", "육류", "채소류", "해물류", "달걀/유제품", "가공식품류", "쌀", "밀가루", "건어물류", "버섯류", "과일류", "콩/견과류", "곡류", "기타"]
    let defaultShelfLife: [String] = ["4", "4", "2", "3", "3", "1", "7", "7", "1825", "180", "180", "5", "4", "60", "1825", "365"]
    var selectIngridentCount: Int = 1
    var shelfLife: String?
    var switchOnOff: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }    
    
    // 추가 버튼
    @IBAction func ingredientInsert(_ sender: UIButton) {
        let name = ingredientName.text!
        // 유통기한 설정
        if switchOnOff {
            shelfLife = defaultShelfLife[selectIngridentCount]
        } else {
            shelfLife = shelfLifeTextField.text!
        }
                
        // 정규표현식
        let regex = try? NSRegularExpression(pattern: "[0-9]+", options: .caseInsensitive)
        // 받은 text 를 NSString 으로 변환
        let text = shelfLife! as NSString
        // 받은 shelfLife 에 숫자가 있으면 NSRange 로 반환하여 NSRange 로 문자를 찾아낸다.
        if let matches = regex?.matches(in: shelfLife!, options: [], range: NSRange(location: 0, length: text.length)) {
            if matches.count == 0 {
                shelfLife = "1"
            }
            
            for match in matches {
                shelfLife = text.substring(with: match.range) as String
            }
        }
        
        // 하루는 86400초 이다.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let shelfLifeDay: String = formatter.string(from: Date(timeIntervalSinceNow: TimeInterval(86400 * Int(shelfLife!)!)))
        
        let insertModel = RefrigratorInsertModel()
        insertModel.insertItems(rCategory: ingridents[selectIngridentCount], rIngredient: name, rShelfLife: shelfLifeDay)
        
    }
    
    @IBAction func shelfLifeSwitch(_ sender: UISwitch) {
        // 유통기한 설정 스위치
        if sender.isOn {
            switchOnOff = false
            // UItextfield 비활성화
            shelfLifeTextField.isEnabled = true
        } else {
            switchOnOff = true
            shelfLifeTextField.isEnabled = false
        }
    }
    
    // MARK: - PickerView
    // number of columns to display
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of rows in each compoenet
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ingridents.count
    }
    
    // string of title in each component
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ingridents[row]
    }
    
    // pickerView 선택했을때 실행되는 함수
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectIngridentCount = row
    }
}
