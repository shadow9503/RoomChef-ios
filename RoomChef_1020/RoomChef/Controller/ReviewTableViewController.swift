//
//  TableViewController.swift
//  Review
//
//  Created by leesu on 2020/09/09.
//  Copyright © 2020 leesu. All rights reserved.
//

import UIKit

class ReviewTableViewController: UITableViewController, ReviewSelectModelProtocol {
        
    @IBOutlet var ReviewlistView: UITableView!
    
    var feedItem:NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ReviewlistView.delegate = self
        self.ReviewlistView.dataSource = self
        
        let reviewSelectModel = ReviewSelectModel()
        reviewSelectModel.delegate = self
        reviewSelectModel.downloadItems()
    }
    
    // MARK: - DB Select Data Downloaded
    
    func itemDownloaded(items: NSArray) {
        feedItem = items
        ReviewlistView.reloadData()
    }
    
    // 이창이 새로 떳을때
    override func viewWillAppear(_ animated: Bool) {
        let reviewSelectModel = ReviewSelectModel()
        reviewSelectModel.delegate = self
        reviewSelectModel.downloadItems()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return feedItem.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! ReviewTableViewCell
        
        let item: ReviewDBModel = feedItem[indexPath.row] as! ReviewDBModel
        let myUrl = URL(string: URLPATH + item.rImagePath!)
        let myRequest = URLRequest(url: myUrl!)
        cell.myWebView.load(myRequest)
        cell.title.text = item.rName
        
        return cell
    }
    
    // 테이블 높이 조절
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    // MARK:- DetailView DataSend
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewDetail" {
            let cell = sender as! UITableViewCell
            let indexPath = self.ReviewlistView.indexPath(for: cell)
            let detailView = segue.destination as! ReviewDetailViewController

            let item = feedItem[indexPath!.row] as! ReviewDBModel
            detailView.receiveModel(item: item)
        }
    }

}
