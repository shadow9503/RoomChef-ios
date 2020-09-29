//
//  ReviewViewController.swift
//  Review
//
//  Created by leesu on 2020/09/09.
//  Copyright © 2020 leesu. All rights reserved.
//

import UIKit

class ReviewInsertViewController: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var reviewName: UITextField!
    @IBOutlet weak var reviewcontent: UITextField!
    @IBOutlet weak var reviewImage: UIImageView!
    
    let imagePickerController = UIImagePickerController()
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePickerController.delegate = self
    }
    
    // 사진 추가 버튼
    @IBAction func btnPhoto(_ sender: UIBarButtonItem) {
        // 앨범 호출
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // 입력 버튼 ( DB Insert )
    @IBAction func btnReviewInsert(_ sender: UIButton) {
        let name = reviewName.text!
        let content = reviewcontent.text!
        
        let reviewInsertModel = ReviewInsertModel()
        reviewInsertModel.uploadImageFile(at: imageURL!, name: name, content: content, completionHandler: {_,_ in })
    }
    
    // Image 앨범에서 가져오기
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            reviewImage.image = image
            
            imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
        }
        
        // 켜놓은 앨범 화면 없애기
        dismiss(animated: true, completion: nil)
    }
}
