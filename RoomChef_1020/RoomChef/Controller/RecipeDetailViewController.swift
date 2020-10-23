//
//  RecipeDetailViewController.swift
//  RoomChef
//
//  Created by 유영훈 on 2020/09/10.
//  Copyright © 2020 RoomChef. All rights reserved.
//

import UIKit
class RecipeDetailViewController: UIViewController{
    
    // 에러 리스트
    enum ThrowsError: Error{
        case indexOutOfRange
    }
    
//    @IBOutlet weak var likeBarButton: UIBarButtonItem!
    @IBOutlet weak var recipeDetailTableView: UITableView!
    @IBOutlet weak var recipeLikeBarButton: UIBarButtonItem!
    
    //create a new button
    let button = UIButton.init(type: .custom)
    var isLike = false
    var likeBarButtonImage = "unlike.png"
    
    // RecipeViewController (레시피목록) 에서 넘어온 정보
    var rSeqno: String = ""
    var rTitle: String = ""
    var rfThumbnailImage: String = ""
    var rCategory: Int = 0
    var rIntro: String = ""
    var rTip: String = ""
    var rDate: String = ""

    // DB에서 새로가져온 정보
    var step01: [String] = []       // 주 내용
    var step02: [String] = []       // 서브 내용
    var recipeImages: [UIImage] = []       // 레시피이미지
    var keys: [String] = []         // 재료 keys
    var ingredients: [String] = [] // 재료정보
    
    // 레시피 상세 내용이 담길 배열
    var feedRecipeItems = RecipeModel()
    
    // 개요, 재료 , 조리순서
    var data: [[String]] = []
    
    
    
    override func viewDidLoad() {
//        print("viewDidLoad()")
        super.viewDidLoad()
        
        self.recipeLikeBarButton.tintColor = isLike == true ? UIColor.red : UIColor.black
        
        // self cell resizing
        recipeDetailTableView.estimatedRowHeight = 50.0 // 기본
        recipeDetailTableView.rowHeight = UITableView.automaticDimension
        
        // recipeStepCell 레시피 조리순서 커스텀 셀
        let nibName = UINib(nibName: "RecipeDetailTableViewRecipeStepCell", bundle: nil)
        recipeDetailTableView.register(nibName, forCellReuseIdentifier: "recipeStepCell")

        createHeaderSection()
        createFooterSection()
//        setBarButton()
        
    }
    
    @IBAction func pressedLikeButton(_ sender: UIBarButtonItem) {
        print("press Like")
        self.isLike = !self.isLike
        self.recipeLikeBarButton.tintColor = isLike == true ? UIColor.red : UIColor.black
//        sender.image = UIImage(named: isLike == true ? "like.png" : "unlike.png")
    }
    
    // 화면이 종료되기 전 좋아요 업데이트
    override func viewWillDisappear(_ animated: Bool) {
        let likeUpdateModel = RecipeLikeUpdateQueryModel()
        DispatchQueue.global().sync{
            guard self.isLike else{
                print("좋아요 제거")
                likeUpdateModel.updateLike(rSeqno: self.rSeqno, uSeqno: 4, swap: 0)
                return
            }
            likeUpdateModel.updateLike(rSeqno: self.rSeqno, uSeqno: 4, swap: 1)
        }
    }
    
//    // 바 버튼 관리 메소드
//    func setBarButton(){
//        // like bar button 색상
//        self.likeButton.tintColor = UIColor.gray
//
//        // UIBarButtonItem() 상단에 선언
//        likeButton = UIBarButtonItem.init(image: UIImage(named: likeBarButtonImage), style: UIBarButtonItem.Style.plain, target: self, action: #selector(RecipeDetailViewController.likeButtonPressed))
//        // 오른쪽에 버튼 추가 ButtonItems 로 해야함.
//        self.navigationItem.rightBarButtonItems?.append(likeButton)
//    }
//    
//    @objc func likeButtonPressed(){
//        print("pressed like")
//        self.isLike = !self.isLike
//        self.likeButton.tintColor = isLike == true ? UIColor.red : UIColor.gray
//        self.likeBarButtonImage = isLike == true ? "like.png" : "unlike.png"
//    }
    
    func initImageView(image: UIImage){
        let view = UIImageView()
        view.image = UIImage(named: "person")
    }
    
    func createFooterSection(){
        // footer view 생성
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
        // footer view에 서브뷰 추가
        let tipSize = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50)
        let dateSize = CGRect(x: 0, y: 50, width: view.frame.size.width, height: 50)
        footer.addSubview(initLabel(text: self.rTip == "None" ? "" : "- 팁 - \n\(self.rTip)", cgRect: tipSize, targetFrame: footer))
        footer.addSubview(initLabel(text: self.rDate == "None" ? "" : "- 등록일 - \n\(self.rDate)", cgRect: dateSize, targetFrame: footer))
        // tableFooterView로 footer 추가
        recipeDetailTableView.tableFooterView = footer
    }
    
    // 헤더섹션 생성 메소드
    func createHeaderSection(){
//        print("createHeaderSection()")
        // 헤더 뷰 생성
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 500))

        // MARK: Thumbnail create
        
        // 썸네일 다운로드
        let url: URL! = URL(string: self.rfThumbnailImage)
        let imageData = try! Data(contentsOf: url)
        
        // rThumbnail 추가
        let thumbnail = UIImageView(image: UIImage(data: imageData))
        thumbnail.frame = CGRect(x: 0, y: 70, width: view.frame.size.width, height: 250)
        thumbnail.contentMode = .scaleAspectFill
        header.addSubview(thumbnail)
        
        // rTitle 추가
        let titleViewcenter: CGRect = CGRect(x: 0, y: 350, width: view.frame.size.width, height: 120)
        let titleView = initTextView(text: rTitle, cgRect: titleViewcenter, textAlignment: .center, targetFrame: header)
        header.addSubview(titleView)
        
        // 테이블 headerView에 header 추가
        recipeDetailTableView.tableHeaderView = header
    }
    
    // MARK: 이미지 불러오기 & 이미지 객체화
    // url을 가지고 image를 불러온다 -> 이미지 객체화 -> 한번의 네트워크 통신 이후는 개체에 저장된 이미지 활용
    func getImage(_ item: RecipeModel,_ row: Int) throws -> UIImage{
        print("getImage()", row)
        guard recipeImages.count != 0 else{
            throw ThrowsError.indexOutOfRange
        }
        return recipeImages[row]
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
    
    func convertDataToString(_ item: RecipeModel){
//        print("convertDataToString()")
        
        var infoIngredients: [NSArray] = [] // 재료정보
        
        // 재료 키값 확보
        for key in item.rIngredient!.allKeys{
            keys.append(key as! String) // 키값 (재료 타이틀)
            infoIngredients.append(item.rIngredient![key] as! NSArray) // 각 키값에 해당하는 재료
        }
        
        // 재료 리스트
        for ingredient in infoIngredients {
            var tempString: String = ""
            for i in ingredient{
                let text = i as! String  // ex) [재료] : (재료)
//                tempString += "[\(text.split(separator: "~")[0])] : \(text.split(separator: "~")[1])\n"
                tempString += "\(text)\n"
            }
            ingredients.append(tempString)
        }
        
        // step01
//        print("step01-----")
        for step in item.rfContent!["step01"] as! NSArray{
            step01.append(step as! String)
        }
        
        // step02
//        print("step02-----")
        for step in item.rfContent!["step02"] as! NSArray{
            var tempString: String = ""
            var lap = 1
            for content in step as! NSArray{
                tempString += lap == 1 ? "\(content as! String)" : ",\(content as! String)" ; lap += 1
            }
            step02.append(tempString)
        }
        
        // 레시피 조리순서 이미지
        let imagePaths: NSArray = item.rfImagePath!["rRecipeImage"] as! NSArray
        for imagePath in imagePaths{
            let url: URL = URL(string: imagePath as! String)!
            let imageData: Data = try! Data(contentsOf: url)
            // 이미지 다운샘플링
            let image: UIImage = downsample(imageData: imageData, for: CGSize(width: 370, height: 250), scale: CGFloat(1))
            recipeImages.append(image)
        }
    }
    
    // 리스트 목록에서 segue로 item 받아옴
    func receiveItems(_ item: RecipeModel,_ rCategory: Int){
//        print("receiveItems()")
        
//        self.feedRecipeItems = item // RecipeModel
        
        self.isLike = item.lSeqno! == "null" ? false : true
        
        
        // 레시피 시퀀스, 카테고리 번호
        self.rSeqno = item.rSeqno!
        RECIPESEQNO = Int(rSeqno) ?? 6932146
        self.rCategory = rCategory
        
        // header에 들어갈 데이터
        self.rTitle = item.rTitle!
        self.rfThumbnailImage = item.rfThumbnailImage!
        self.rIntro = item.rIntro!
        
        // footer에 들어갈 데이터
        self.rTip = item.rTip!
        self.rDate = item.rDate!
        
        // 테이블 데이터로 사용하기위해 String으로 변환하여 배열에 담기
        convertDataToString(item)

        // 테이블에 뿌려질 배열 데이터
        // Array<Array<String>> 타입
        
        // 개요 저장
        var summary: [String] = []
        summary.append(item.rSummary!)
        data.append(summary)
        
        // 재료의 키값을 저장
        for key in keys{
            var temp: [String] = []
            temp.append(key)
            data.append(temp)
        }
        
        // table에 뿌려준 조리순서의 번호를 저장
        var stepNumber: [String] = []
        for i in 0..<step01.count{
            stepNumber.append(String(i))
        }
        data.append(stepNumber)
        
        
    }
 
    // 임의의 label을 생성한다.
    func initLabel(text: String, color: UIColor = UIColor.darkText, cgRect: CGRect, targetFrame frame: UIView) -> UILabel{
        let view = UILabel(frame: frame.bounds)
        view.text = text
        view.textColor = color
        view.frame = cgRect
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }
    
    // 임의의 textView를 생성한다.
    func initTextView(text: String, color: UIColor = UIColor.darkText, fontSize: CGFloat = 20, cgRect: CGRect, textAlignment: NSTextAlignment = .left, targetFrame frame: UIView) -> UITextView{
        let view = UITextView(frame: frame.bounds)
        view.text = text
        view.textColor = color
        view.font = UIFont.systemFont(ofSize: fontSize)
        view.textAlignment = textAlignment
        view.frame = cgRect
        view.isEditable = false
        return view
    }
    
}

extension RecipeDetailViewController: UITableViewDelegate{

    // 섹션 select 효과 제거
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipeDetailTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RecipeDetailViewController: UITableViewDataSource{

    // 섹션 로우 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }

    // 섹션 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 리턴할 cell 변수
        var cell: UITableViewCell = UITableViewCell()
        
        // 개요, 재료 custom cell ( tableView에 직접 넣은 cell )
        let detailCell = recipeDetailTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! RecipeDetailTableViewCell
        
        // 조리순서 custom cell ( xib로 구성한 cell )
        let recipeStepCell = recipeDetailTableView.dequeueReusableCell(withIdentifier: "recipeStepCell", for: indexPath) as! RecipeDetailTableViewRecipeStepCell
    
        let item = feedRecipeItems
        
        // 조리순서 전까지는 detailCell 적용
        switch indexPath.section{
            // 개요 파트
            case 0:
                detailCell.lblContent?.text = data[indexPath.section][indexPath.row]
                cell = detailCell
            // 재료 항목 개수 만큼
            case 1...keys.count:
                detailCell.lblContent?.text = ingredients[indexPath.row]
                cell = detailCell
            default :
                // 조리순서 넘버
                recipeStepCell.lblRecipeNumber.textColor = UIColorFromRGB(rgbValue: 0x69ba49, alpha: 1.0)
                recipeStepCell.lblRecipeNumber.text = "\(indexPath.row+1)"
                // 조리 순서 내용
                recipeStepCell.lblRecipeStep01.text = step01[indexPath.row]
                recipeStepCell.lblRecipeStep02.text = step02[indexPath.row]
                // 조리 이미지
                recipeStepCell.recipeImageView.image = try? getImage(item, indexPath.row)
                // recipeStepCell 리턴하기위해 변수에 담는다.
                cell = recipeStepCell
        }
        
        return cell
    }

    // HEX Color code -> UIColor
    func UIColorFromRGB(rgbValue: UInt, alpha: CGFloat) -> UIColor{
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    // 섹션 헤더 타이틀
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return changeSectionTitle(section)
    }
    
    // 섹션 헤더 타이틀 관리
    func changeSectionTitle(_ section: Int) -> String{
        switch section{
            case 0:
                return "개요"
            case 1...keys.count:
                return keys[section-1]
            default :
                return "조리순서"
        }
    }
    
    // 섹션 헤더 높이
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 20.0
//    }

    // footer 타이틀
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "Footer"
//    }

    // footer 높이
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section{
            case section-1:
                return 20
            default:
                return 0
        }
    }
}




