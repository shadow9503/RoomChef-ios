//
//  ViewController.swift
//  tableViewTest
//
//  Created by 유영훈 on 2020/09/09.
//  Copyright © 2020 yh. All rights reserved.
//

import UIKit

class RecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RecipeQueryModelProtocol, UISearchBarDelegate {
    
    @IBOutlet weak var swDateFilter: UISwitch!
    @IBOutlet weak var swLikeFilter: UISwitch!
    
    @IBOutlet weak var lblListNotFound: UILabel!
    @IBOutlet weak var recipeLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var recipeTableView: UITableView!
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    
    var feedRecipeListItems: NSArray = NSArray()
    var stackRecipeListItems: NSMutableArray = NSMutableArray()
    
    var recipeListTitle: String = ""
    var uSeqno: Int = 4
    var rLike: Int = 0
    var order: String = "DESC"
    var startIndex: Int = 0
    var count: Int = 10
    let categoryNameList: [Int : String] = [22:"밑반찬", 23:"메인반찬", 24:"국/탕", 25:"찌개", 26:"디저트", 27:"면/만두", 28:"밥/죽/떡", 29:"퓨전", 30:"김치/젓갈/장류", 31:"양념/소스/잼", 32:"양식", 33:"샐러드", 34:"스프", 35:"빵", 36:"과자", 37:"차/음료/술"]
    
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipeSearchBar.delegate = self
        
        // row Height
        recipeTableView.rowHeight = 306
        
        // tableview 구분선 제거
        recipeTableView.separatorStyle = .none
        
        // indicator 설정
        recipeLoadingIndicator.layer.cornerRadius = 8
        recipeLoadingIndicator.isHidden = false
        recipeLoadingIndicator.center = self.view.center
        recipeLoadingIndicator.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: IBAction
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // 검색 버튼
    @IBAction func btnSearchRecipe(_ sender: UIButton) {
        re_SearchRecipe()
//        print(String(categoryNum), rLike, order, recipeSearchBar.text!, startIndex)
        
    }
    
    // 최신순 필터 스위치
    @IBAction func dateFilterSwitch(_ sender: UISwitch) {
        order = sender.isOn ? "DESC" : "ASC"
        re_SearchRecipe()
    }
    
    // 좋아요 필터 스위치
    @IBAction func likeFilterSwitch(_ sender: UISwitch) {
        rLike = sender.isOn ? 1 : 0
        re_SearchRecipe()
    }
    
    // 스크롤 애니메이션이 멈추었을때 구동
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let height : CGFloat = scrollView.frame.size.height
        let contentYOffset: CGFloat = scrollView.contentOffset.y
        let scrollViewHeight: CGFloat = scrollView.contentSize.height
        let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
        
        // scrollview 의 height보다 더 내려가게되면 recipe목록 갱신
        if distanceFromBottom < height + 1{
            print("recipe call")
            startIndex += 10
            recipeListQueryCall()
        }
    }
    
    // 검색 필터 변화 & 검색버튼 클릭시 테이블 새로고침 함수 모음
    func re_SearchRecipe(){
       clearTableView()
       recipeListQueryCall()
       scrollToTop()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.recipeTableView.isUserInteractionEnabled = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("endEdit")
        self.recipeTableView.isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.recipeTableView.isUserInteractionEnabled = true
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: 레시피 상세 페이지로 이동시 값을 넘기는 함수
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // 레시피 상세로 이동시 구동
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        let recipeDetailViewController = segue.destination as! RecipeDetailViewController

        if segue.identifier == "sgRecipeDetail"{
            // sender 에서 cell 정보를 받아온다.
            let cell = sender as! UITableViewCell
            // cell을 이용해 tableView에서 indexPath를 가져온다.
            let indexPath = self.recipeTableView.indexPath(for: cell)
            // indexPath를 이용해 item을 구성
            let item: RecipeModel = stackRecipeListItems[indexPath!.row] as! RecipeModel
            recipeDetailViewController.receiveItems(item, CATEGORYNUM)
        }
    }
    
    // 레시피 데이터 불러오기
    func recipeListQuery(_ userSeqno: Int, _ rCategory: Int, _ rLike: Int, _ order: String, _ keyword: String?, _ startIndex: Int, _ count: Int){
        
        // laoding Indicator start
        recipeLoadingIndicator.startAnimating()
        
        // delegate 사용 self가 하곘다.
        self.recipeTableView.delegate = self
        
        // dataSource 사용 self가 하겠다.
        self.recipeTableView.dataSource = self
        
        // recipe를 불러오는 queryModel 인스턴스 생성
        let recipeQueryModel = RecipeQueryModel()
        recipeQueryModel.delegate = self
        recipeQueryModel.downloadItems(uSeqno: userSeqno, rCategory: rCategory, rLike: rLike, order: order, keyword: keyword!, startIndex: startIndex, count: count)
        
    }
    
    // table index & array 초기화
    func clearTableView(){
        startIndex = 0
        stackRecipeListItems = NSMutableArray()
    }
    
    // 스크롤 Top 이동
    func scrollToTop(){
        // 스크롤 상단 이동
        // x를 0으로하면 위치를 제대로 찾지 못함
        recipeTableView.contentOffset = CGPoint.init(x: NSNotFound, y: 0 - Int(recipeTableView.contentInset.top))
    }
    
    // filter 초기화
    func clearFilter(){
        rLike = 0
        order = "DESC"
        swLikeFilter.isOn = false
        swDateFilter.isOn = true
    }
    
    // 테이블 데이터 쿼리함수 대리 호출함수
    func recipeListQueryCall(){
        recipeListQuery(uSeqno, CATEGORYNUM, rLike, order, recipeSearchBar.text!, startIndex, count)
    }
    
    // 화면이 보이게되면 실행( 보이기전에 실행되는느낌 )
    override func viewWillAppear(_ animated: Bool) {
        recipeListQueryCall()
        self.recipeTableView.reloadData()
        navigationController?.setNavigationBarHidden(false, animated: false) // 네비게이션바 제거
        self.navigationController?.title = "\(categoryNameList[CATEGORYNUM]!) 레시피"
        
    }
    
    // 다른 view로 이동시 데이터 초기화
    override func viewDidDisappear(_ animated: Bool) {
        clearTableView()
        scrollToTop()
        clearFilter()
    }

    // MARK: RecipeQueryModel 클래스로부터 레시피 리스트를 넘겨받는 함수
    func itemDownloaded(items: NSArray, category: String) {
        
        for item in items{
           stackRecipeListItems.add(item as! RecipeModel)
        }
        if let cat = Int(category){
            CATEGORYNUM = cat
        }
        
        if stackRecipeListItems.count == 0{
           recipeLoadingIndicator.stopAnimating()
            recipeLoadingIndicator.isHidden = true
            lblListNotFound.isHidden = false
        }else{
            lblListNotFound.isHidden = true
        }
//        print("현재 보여지는 레시피 개수: ", stackRecipeListItems.count)
        self.recipeTableView.reloadData()
    }
    
    // MARK: Status bar Style Configure
    //    override var preferredStatusBarStyle: UIStatusBarStyle{
    //        return .default
    //    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: TableView Configure
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stackRecipeListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recipeTableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! RecipeTableViewCell
        // Cell 구성
        let item: RecipeModel = stackRecipeListItems[indexPath.row] as! RecipeModel
        // 사용자 지정 레이블
        cell.lblRecipeTitle?.text = item.rTitle
        cell.ivThumbnailImage?.image = self.getImage(item)
        
        if item.lSeqno! != "null"{
            cell.ivLike.image = UIImage(named: "like.png")
        }else{
            cell.ivLike.image = UIImage(named: "unlike.png")
        }
        
        
        // laoding Indicator stop
        self.recipeLoadingIndicator.isHidden = true
        self.recipeLoadingIndicator.stopAnimating()
        return cell
    }
    
    // MARK: 이미지 불러오기 & 이미지 객체화
    // url을 가지고 image를 불러온다 -> 이미지 객체화 -> 한번의 네트워크 통신 이후는 개체에 저장된 이미지 활용
    func getImage(_ item: RecipeModel) -> UIImage{
        // 객체에 저장된 이미지가 있는지 체크하고 없으면 url로 받아오고 return
        if let imageData = item.imageData{
            return imageData
        }else{
            let url: URL! = URL(string: item.rfThumbnailImage!)
            let imageData = try! Data(contentsOf: url)
//            item.imageData = UIImage(data: imageData)
            item.imageData = downsample(imageData: imageData, for: CGSize(width: 370, height: 200), scale: CGFloat(1))
            return item.imageData!
        }
    }
    
    // image downSampling
    func downsample(imageData: Data, for size: CGSize, scale:CGFloat) -> UIImage {
            // dataBuffer가 즉각적으로 decoding되는 것을 막아줍니다.
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return UIImage() }
            let maxDimensionInPixels = max(size.width, size.height) * scale
            let downsampleOptions =
                [kCGImageSourceCreateThumbnailFromImageAlways: true,
                 kCGImageSourceShouldCacheImmediately: true, //  thumbNail을 만들 때 decoding이 일어나도록 합니다.
                 kCGImageSourceCreateThumbnailWithTransform: true,
                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
            
            // 위 옵션을 바탕으로 다운샘플링 된 `thumbnail`을 만듭니다.
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return UIImage() }
            return UIImage(cgImage: downsampledImage)
    }
}

