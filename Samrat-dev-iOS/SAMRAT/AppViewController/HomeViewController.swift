import UIKit
import SVProgressHUD
import KRProgressHUD
import KRActivityIndicatorView

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //MARK:- @IBOutlets
    
    @IBOutlet weak var tblViewHeichCon: NSLayoutConstraint!
    @IBOutlet weak var lblAlertText: UILabel!
    @IBOutlet weak var popUpContainView: UIView!
    @IBOutlet weak var popupbottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var popupHeight: NSLayoutConstraint!
    @IBOutlet var btnSamrat: UIButton!{
        didSet{
            btnSamrat.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var btnJalsat: UIButton!{
        didSet{
            btnJalsat.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var btnFraqShamia: UIButton!{
        didSet{
            btnFraqShamia.layer.cornerRadius = 22.5
        }
    }
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(UINib.init(nibName: "HomeTCell", bundle: nil), forCellReuseIdentifier: "HomeTCell")
        }
    }
    @IBOutlet weak var viewWhatspp: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWhatspp.layer.cornerRadius = viewWhatspp.frame.width/2
        viewWhatspp.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWhatspp.addGestureRecognizer(panGesture)
        
        AppConstant.shared.firstTimeHome = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tabBarController?.navigationItem.hidesBackButton = true
    //    self.updateTableContentInset()
        //self.tableView.backgroundColor = .red
        // Call api for updated data if language changed
        
        

//        if CategoriesModel.shared.categoriesObj?.data?.count == 1 {
//            let cat = CategoriesModel.shared.categoriesObj?.data?[0]
//            self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
//        } else {
//            self.tableView.reloadData()
//        }
        
        self.tableView.reloadData()
        
        if (CategoriesModel.shared.settingResponse?.settings?.enable_first_time_open_message ?? "") == "1" {
            if let getSaveDate  = UserDefaults.standard.object(forKey: "saveDate") as? Date {
                var calender = Calendar.current
                calender.timeZone = TimeZone.current
                let result = calender.compare(getSaveDate, to: Date(), toGranularity: .day)
                let isSameDay = result == .orderedSame
                if isSameDay == true {
                    
                }else {
                    self.openBottompoupMessage()
                }
            }else {
                self.openBottompoupMessage()
            }
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // Get the translation (movement) of the drag
        let translation = gesture.translation(in: view)
        
        // Update the center of the view by adding the translation
        var newCenter = CGPoint(x: viewWhatspp.center.x + translation.x, y: viewWhatspp.center.y + translation.y)
        
        // Get the safe area insets (top, bottom, left, right)
        let safeAreaInsets = view.safeAreaInsets
        
        // Define boundaries within the safe area
        let minX = safeAreaInsets.left + viewWhatspp.frame.width / 2
        let maxX = view.bounds.width - safeAreaInsets.right - viewWhatspp.frame.width / 2
        let minY = safeAreaInsets.top + viewWhatspp.frame.height / 2
        let maxY = view.bounds.height - safeAreaInsets.bottom - viewWhatspp.frame.height / 2
        
        // Ensure the new center stays within the boundaries of the safe area
        newCenter.x = max(minX, min(newCenter.x, maxX))
        newCenter.y = max(minY, min(newCenter.y, maxY))
        
        // Set the new center for the movable view
        viewWhatspp.center = newCenter
        
        // Reset the translation to 0 after applying the change
        gesture.setTranslation(.zero, in: view)

    }
    
    @IBAction func clickedWhatsapp(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func openBottompoupMessage() {
        UserDefaults.standard.set(Date(), forKey: "saveDate")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 3) {
                self.popupbottomConstrain.constant = isIphoneX() ? 90 : 60
                self.lblAlertText.text = CategoriesModel.shared.settingResponse?.settings?.enable_first_time_open_message_text ?? ""
                self.view.layoutIfNeeded()
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                UIView.animate(withDuration: 3) {
                    self.popupbottomConstrain.constant = -1000
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // param required because cat should come with country id
//        if SamratGlobal.loggedInUser()?.user == nil {
//            self.apiGetCategories()
//        }else {
        
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                   
        if appDelegate?.isFromCalender == true
        {
            appDelegate?.isFromCalender = false
        }
        else
        {
            self.apiGetCategoriesWithParameters()
        }
        
        //}
        
        self.view.bringSubviewToFront(self.popUpContainView)
        self.navigationController?.navigationBar.isHidden = false
        if CategoriesModel.shared.categoriesObj?.data?.count == 1 {
            self.tabBarController?.navigationItem.title = Localized("singersList").uppercased()
        } else {
            self.tabBarController?.navigationItem.title = ""
        }
        
        self.apiGetSettingDetails()
    }
    
    fileprivate func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        CategoriesModel.shared.settingResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                        
                        if (CategoriesModel.shared.settingResponse?.countries?.count ?? 0) == 1
                        {
                            let selectedCountry = CategoriesModel.shared.settingResponse?.countries![0]
                            UserDefaults.standard.encode(for: selectedCountry, using: "selectedCountryObj")
                        }
                         
                    }
 
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    //self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                //self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
            }
        }
    }
    
    
    func openMusicianWhenOneData(categoriesDetails:CategoriesData?){
        let controller = CatSingerListVC()
        controller.categoriesDetails = categoriesDetails
        //        controller.singerObjBasedOnCat = CategoriesModel.shared.singerObjBasedOnCat
        //        controller.settingsResponse = CategoriesModel.shared.settingResponse
        
        controller.view.frame = self.view.frame
        self.addChild(controller)
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        //        let catSingerListVC = CatSingerListVC()
        //        catSingerListVC.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
        //        self.navigationController?.pushViewController(catSingerListVC, animated: true)
    }
    
    func updateTableContentInset() {
        let numRows = self.tableView.numberOfRows(inSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height/2
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop+25,left: 0,bottom: 0,right: 0)

    }
    
    //MARK:- Table View delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CategoriesModel.shared.categoriesObj?.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HomeTCell", for: indexPath) as! HomeTCell
        let categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
        cell.lblTitle.text = categoriesDetails?.name?.uppercased() ?? ""
        //        cell.contentView.transform = CGAffineTransform (scaleX: 1,y: -1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let catSingerListVC = CatSingerListVC()
//        catSingerListVC.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
//        fadeTo(catSingerListVC)
        
        if (CategoriesModel.shared.categoriesObj?.data?[indexPath.row].sub_categories_recursive?.count ?? 0) > 0 {
            
            // If there is single category then skip sub-category screen
            // Release:- Aj 1.8(16)
            if (CategoriesModel.shared.categoriesObj?.data?[indexPath.row].sub_categories_recursive?.count ?? 0) == 1 {

                let catSingerListVC = CatSingerListVC()
                //catSingerListVC.categoriesDetails = self.categoriesDetails?.sub_categories_recursive?[indexPath.row]
                catSingerListVC.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row].sub_categories_recursive?[0]
                catSingerListVC.parentCatObj = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
                fadeTo(catSingerListVC)

            } else{
                
                let subObj = SubCategoriesVC()
                subObj.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
                subObj.parentCatObj = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
                fadeTo(subObj)
            }
            
        }else {
            
            let catSingerListVC = CatSingerListVC()
            catSingerListVC.parentCatObj = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
            catSingerListVC.categoriesDetails = CategoriesModel.shared.categoriesObj?.data?[indexPath.row]
            fadeTo(catSingerListVC)
        }
        
        
        
//        var homeObj = HomeViewController.object()
        
//        self.navigationController?.pushViewController(homeObj, animated: true)
//        fadeTo(homeObj)
    }
    
        func apiGetCategories() {
            ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
            APIManager.handler.GetRequest(url: ApiUrl.categories, isLoader: true, header: nil, controller: self) { (result) in
                ActivityIndicatorWithLabel.shared.hideProgressView()
                switch result {
                case .success(let data):
                    do {
                        guard let data = data else {return}
                        CategoriesModel.shared.categoriesObj = nil
                        CategoriesModel.shared.categoriesObj = try? JSONDecoder().decode(CatagoriesResponse.self, from: data)
    
                        if CategoriesModel.shared.categoriesObj?.status == true {
                            if CategoriesModel.shared.categoriesObj?.data?.count == 1{
                                let cat = CategoriesModel.shared.categoriesObj?.data?[0]
                                self.tabBarController?.navigationItem.title = cat?.name?.uppercased() ?? ""
                                self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
                            }else{
                                self.tabBarController?.navigationItem.title = ""
                                self.tableView.reloadData()
                              //  self.updateTableContentInset()
                            }
                        }else {
                            self.showAlert(title: Localized("alert"), message: CategoriesModel.shared.categoriesObj?.message ?? Localized("somethingWentWrong"))
                        }
    
                    }catch (let error) {
                        JSN.log("login uer ====>%@", error)
                    }
                    break
                case .failure(let error):
                    JSN.log("failur error login api ===>%@", error)
                    break
                }
            }
        }
    
    func apiGetCategoriesWithParameters() {
        let parameter = [
            "device_type":deviceType,
            "user_id": SamratGlobal.loggedInUser()?.user?.id ?? "",
            "device_token": devicePushToken
        ] as [String : Any]
    
        let selectedCountry = getSelectedCountry()
        
        let urlString = ApiUrl.categories + "?device_type=\(deviceType)&user_id=\(SamratGlobal.loggedInUser()?.user?.id ?? 0)&device_token=\(devicePushToken)&country_id=\(selectedCountry?.id ?? 0)"
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.GetRequest(url: urlString, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    JSN.log("Data printed ===>%@", String(data: data, encoding: .utf8))
                    CategoriesModel.shared.categoriesObj = nil
                    CategoriesModel.shared.categoriesObj = try? JSONDecoder().decode(CatagoriesResponse.self, from: data)

                    if CategoriesModel.shared.categoriesObj?.status == true {
                        
                        if (CategoriesModel.shared.categoriesObj?.data?.count ?? 0) > 0
                        {
                            DispatchQueue.main.async {
                                self.tblViewHeichCon.constant = CGFloat((54 * (CategoriesModel.shared.categoriesObj?.data!.count)!) + 60)
                            }
                        }
                      
                        
//                        if CategoriesModel.shared.categoriesObj?.data?.count == 1{
//                            let cat = CategoriesModel.shared.categoriesObj?.data?[0]
//                            self.tabBarController?.navigationItem.title = cat?.name?.uppercased() ?? ""
//                            self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
//                        }else{
                            self.tabBarController?.navigationItem.title = ""
                            self.tableView.reloadData()
                          //  self.updateTableContentInset()
//                        }
                    }else {
                        self.showAlert(title: Localized("alert"), message: CategoriesModel.shared.categoriesObj?.message ?? Localized("somethingWentWrong"))
                    }
                    
//                    if CategoriesModel.shared.categoriesObj?.status == true {
//                        if CategoriesModel.shared.categoriesObj?.data?.count == 1{
//                            let cat = CategoriesModel.shared.categoriesObj?.data?[0]
//                            self.tabBarController?.navigationItem.title = cat?.name?.uppercased() ?? ""
//                            self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
//                        }else{
//                            self.tabBarController?.navigationItem.title = ""
//                            self.tableView.reloadData()
//                          //  self.updateTableContentInset()
//                        }
//                    }else {
//                        self.showAlert(title: Localized("alert"), message: CategoriesModel.shared.categoriesObj?.message ?? Localized("somethingWentWrong"))
//                    }

                }catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
        

    }
    
}
