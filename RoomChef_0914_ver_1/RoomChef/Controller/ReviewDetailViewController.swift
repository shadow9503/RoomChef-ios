//
//  ReviewDetailViewController.swift
//  RoomChef
//
//  Created by JHJ on 2020/09/12.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import UIKit
import WebKit // WKWebView

class ReviewDetailViewController: UIViewController {

    @IBOutlet weak var reviewTitle: UILabel!
    @IBOutlet weak var reviewImageView: WKWebView!
    @IBOutlet weak var reviewContent: UITextView!
    
    var receiveModel: ReviewDBModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reviewTitle.text = receiveModel?.rName
        reviewImageView.load(URLRequest(url: URL(string: URLPATH + (receiveModel?.rImagePath)!)!))
        reviewContent.text = receiveModel?.rContent
    }

    // Receive
    func receiveModel(item: ReviewDBModel) {
        receiveModel = item
    }
}
