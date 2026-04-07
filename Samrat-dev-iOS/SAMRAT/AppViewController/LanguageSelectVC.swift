//
//  LanguageSelectVC.swift
//  SAMRAT
//
//  Created by Hardik Ramolia on 22/08/21.
//

import UIKit

class LanguageSelectVC: UIViewController
{
    @IBOutlet var lblEnglish: UILabel!
    @IBOutlet var lblArabic: UILabel!
    @IBOutlet var btnEnglish: UIButton!
    @IBOutlet var btnArabic: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var imgSplash: UIImageView!
    @IBOutlet var imgSplashLogo: UIImageView!
    @IBOutlet var imgSplashLogoNewFlower: UIImageView!

    @IBOutlet weak var viewWA: UIView!
    
    private var observer: NSObjectProtocol?

    var isSingleCountry = false
    
    override func viewDidLoad() {
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        apiGetSetting()
        
        lblEnglish.text = "Select your language"
        lblArabic.text = "اختر اللغة"
        btnEnglish.setTitle("English", for: .normal)
        btnArabic.setTitle("بالعربي", for: .normal)
        
        btnEnglish.layer.cornerRadius = btnEnglish.frame.height/2
        btnArabic.layer.cornerRadius = btnArabic.frame.height/2
        
        self.view.backgroundColor = hexStringToUIColor(hex: "#20382E")
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            self.performAction()
        }
        performAction()
    }
    
    @IBAction func clickedWA(_ sender: Any) {
        print("Buttom tapped")
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        // Get the translation (movement) of the drag
        let translation = gesture.translation(in: view)
        
        // Update the center of the view by adding the translation
        var newCenter = CGPoint(x: viewWA.center.x + translation.x, y: viewWA.center.y + translation.y)
        
        // Get the safe area insets (top, bottom, left, right)
        let safeAreaInsets = view.safeAreaInsets
        
        // Define boundaries within the safe area
        let minX = safeAreaInsets.left + viewWA.frame.width / 2
        let maxX = view.bounds.width - safeAreaInsets.right - viewWA.frame.width / 2
        let minY = safeAreaInsets.top + viewWA.frame.height / 2
        let maxY = view.bounds.height - safeAreaInsets.bottom - viewWA.frame.height / 2
        
        // Ensure the new center stays within the boundaries of the safe area
        newCenter.x = max(minX, min(newCenter.x, maxX))
        newCenter.y = max(minY, min(newCenter.y, maxY))
        
        // Set the new center for the movable view
        viewWA.center = newCenter
        
        // Reset the translation to 0 after applying the change
        gesture.setTranslation(.zero, in: view)

    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func performAction() {
        if UserDefaults.standard.bool(forKey: "isAlreadyLaunch") {
            containerView.isHidden = true
            self.apiCheckUpdate()
        } else {
            imgSplash.isHidden = true
            imgSplashLogo.isHidden = true
            imgSplashLogoNewFlower.isHidden = true
        }
    }
    
    @IBAction func btnEnglishPressed(_ sender: UIButton) {
        btnEnglish.setTitleColor(.white, for: .normal)
        btnArabic.setTitleColor(.black, for: .normal)
        btnArabic.backgroundColor = .white
        btnEnglish.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
        gotoTabBar(isArabic: false)
    }
    
    @IBAction func btnArabicPressed(_ sender: UIButton) {
        btnEnglish.setTitleColor(.black, for: .normal)
        btnArabic.setTitleColor(.white, for: .normal)
        btnArabic.backgroundColor = hexStringToUIColor(hex: "#CC8A65")
        btnEnglish.backgroundColor = .white
        gotoTabBar(isArabic: true)
    }
    
    func gotoTabBar(isArabic: Bool) {
        Language.shared.isArabic = isArabic
//        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
//        APIManager.handler.PostRequest(url: ApiUrl.saveLanguage, params: ["language": isArabic ? "ar":"en",
//                                                                          "device_type": deviceType], isLoader: true, header: nil, setLogout: false, controller: self) { result in
            UserDefaults.standard.setValue(true, forKey: "isAlreadyLaunch")
            UserDefaults.standard.synchronize()
            DispatchQueue.async {
                setSemantricFlow()
//                DispatchQueue.async {
//                    self.navigateToWelcomeScreen()
//                }
                ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
                self.apiCheckUpdate()
//            }
//            self.dismiss(animated: true)
//            let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//            self.navigationController?.pushViewController(tabbar, animated: true)
        }
    }
    
    //MARK:- CheckUpdate
    func apiCheckUpdate() {
        let parameter = [
            "version" : appVersion,
            "device_type": deviceType
        ] as [String : Any]
        APIManager.handler.PostRequest(url: ApiUrl.checkUpdate, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {
                        self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                        return
                    }
                    let contactUsResponse = try JSONDecoder().decode(CommanResponse.self, from: data)
                    if contactUsResponse.status == true {
                        
                        guard contactUsResponse.update_available == true else {
                          
//                            if SamratGlobal.loggedInUser()?.user == nil {
//                                self.apiGetCategories()
//                            }else {
                                self.apiGetCategoriesWithParameters()
                           // }
                            return
                        }
                        
                        AlertView.instance.alertViewDelegate = nil
                        AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: contactUsResponse.message ?? ""),
                                                     alertType: contactUsResponse.force_update == true ? .oneButton : .twoButton,
                                                     firstButton: contactUsResponse.ok_button_text ?? Localized("yes"),
                                                     secondButton: contactUsResponse.cancel_button_text ?? Localized("no"), okHandler: {
                                                        if let urlstr = contactUsResponse.app_link,
                                                           let url = URL(string: urlstr),
                                                           UIApplication.shared.canOpenURL(url) {
                                                            DispatchQueue.main.async {
                                                                UIApplication.shared.open(url)
                                                            }
                                                        } else {
                                                            //self.apiGetCategories()
//                                                            if SamratGlobal.loggedInUser()?.user == nil {
//                                                                self.apiGetCategories()
//                                                            }else {
                                                                self.apiGetCategoriesWithParameters()
                                                           // }
                                                        }
                                                     }, cancelHandler: {
                                                        //self.apiGetCategories()
//                                                         if SamratGlobal.loggedInUser()?.user == nil {
//                                                             self.apiGetCategories()
//                                                         }else {
                                                             self.apiGetCategoriesWithParameters()
                                                         //}
                                                     })
                    } else {
                        ActivityIndicatorWithLabel.shared.hideProgressView()
//                        self.showAlert(title: Localized("alert"), message: contactUsResponse.message ?? Localized("somethingWentWrong")) {
//                        }
                        // Instead of alert view screen
                        // System under maintenance
                        
                        guard let window = UIApplication.shared.keyWindow else {
                                 return
                             }
                             let frontViewController = MaintenanceViewController.object()
                     //        let frontViewController = TabBarViewController.object() //TabBarController.object()
                             let frontNavigationController = UINavigationController(rootViewController: frontViewController)
                             frontNavigationController.setNavigationBarHidden(false, animated: false)
                             self.view.window?.rootViewController = frontNavigationController
                             
                             let options: UIView.AnimationOptions = .transitionCrossDissolve
                             let duration: TimeInterval = 1
                             UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
                                 // maybe do something on completion here
                             })
                        
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    ActivityIndicatorWithLabel.shared.hideProgressView()
                    self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                ActivityIndicatorWithLabel.shared.hideProgressView()
                self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
            }
        }
    }
    
  
    //MARK:- Get Home API
    func apiGetCategories() {
        APIManager.handler.GetRequest(url: ApiUrl.categories, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {
                        self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                        return
                    }
                    CategoriesModel.shared.categoriesObj = nil
                    CategoriesModel.shared.categoriesObj = try? JSONDecoder().decode(CatagoriesResponse.self, from: data)
                    
                    if CategoriesModel.shared.categoriesObj?.status == true,
                       let data = CategoriesModel.shared.categoriesObj?.data {
                        if data.count < 2 {
                            self.apiGetSingerListBasedOnCategories()
                        } else {
                            ActivityIndicatorWithLabel.shared.hideProgressView()
                            if let observer = self.observer {
                                NotificationCenter.default.removeObserver(observer)
                            }
                            if let selectedCountry = getSelectedCountry()  {
                                self.navigateToWelcomeScreen()
                                
                            } else {
                                
                                if self.isSingleCountry == true
                                {
                                    self.navigateToWelcomeScreen()
                                }
                                else
                                {
                                    let vc = self.storyboard?.instantiateViewController(identifier: "CountrySelectionViewController") as! CountrySelectionViewController
                                    vc.isComingFromSetting = false
                                    self.fadeTo(vc)
                                }
                                
                            }
                        }
                        
//                        if CategoriesModel.shared.categoriesObj?.data?.count == 1{
//                            let cat = CategoriesModel.shared.categoriesObj?.data?[0]
//                            self.tabBarController?.navigationItem.title = cat?.name?.uppercased() ?? ""
////                            self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
//                        }else{
//                            self.tabBarController?.navigationItem.title = ""
////                            self.tableView.reloadData()
////                            self.updateTableContentInset()
//                        }
                    } else {
                        self.showAlert(title: Localized("alert"), message: CategoriesModel.shared.categoriesObj?.message ?? Localized("somethingWentWrong"))
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    ActivityIndicatorWithLabel.shared.hideProgressView()
                    self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                ActivityIndicatorWithLabel.shared.hideProgressView()
                self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
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
        
        APIManager.handler.GetRequest(url: urlString, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {
                        self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                        return
                    }
                    CategoriesModel.shared.categoriesObj = nil
                    CategoriesModel.shared.categoriesObj = try? JSONDecoder().decode(CatagoriesResponse.self, from: data)
                    
                    if CategoriesModel.shared.categoriesObj?.status == true,
                       let data = CategoriesModel.shared.categoriesObj?.data {
                        if data.count < 2 {
                            self.apiGetSingerListBasedOnCategories()
                        } else {
                            ActivityIndicatorWithLabel.shared.hideProgressView()
                            if let observer = self.observer {
                                NotificationCenter.default.removeObserver(observer)
                            }
                            if let selectedCountry = getSelectedCountry()  {
                                self.navigateToWelcomeScreen()
                                
                            } else {
                                
                                if self.isSingleCountry == true
                                {
                                    self.navigateToWelcomeScreen()
                                }
                                else
                                {
                                    let vc = self.storyboard?.instantiateViewController(identifier: "CountrySelectionViewController") as! CountrySelectionViewController
                                    vc.isComingFromSetting = false
                                    self.fadeTo(vc)
                                }
                                
                                
                            }
                        }
                        
//                        if CategoriesModel.shared.categoriesObj?.data?.count == 1{
//                            let cat = CategoriesModel.shared.categoriesObj?.data?[0]
//                            self.tabBarController?.navigationItem.title = cat?.name?.uppercased() ?? ""
////                            self.openMusicianWhenOneData(categoriesDetails: cat ?? nil)
//                        }else{
//                            self.tabBarController?.navigationItem.title = ""
////                            self.tableView.reloadData()
////                            self.updateTableContentInset()
//                        }
                    } else {
                        self.showAlert(title: Localized("alert"), message: CategoriesModel.shared.categoriesObj?.message ?? Localized("somethingWentWrong"))
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    ActivityIndicatorWithLabel.shared.hideProgressView()
                    self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                ActivityIndicatorWithLabel.shared.hideProgressView()
                self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
            }
        }
    }
    
    //MARK:- Get singer list based on categories
    func apiGetSingerListBasedOnCategories() {
      
        var parameter = [
            "category_id" : "\(CategoriesModel.shared.categoriesObj?.data?.first?.id ?? 0)",
            "device_type":deviceType
        ] as [String : Any]
        
        let selectedCountry = getSelectedCountry()
        if selectedCountry != nil {
            parameter["country_id"] = selectedCountry?.id
        }
        
        APIManager.handler.PostRequest(url: ApiUrl.singer, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {
                        self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                        return
                    }
                    CategoriesModel.shared.singerObjBasedOnCat = try? JSONDecoder().decode(singersObj.self, from: data)
                    
                    if CategoriesModel.shared.singerObjBasedOnCat?.status == true {
//                        if (self.singerObjBasedOnCat?.data?.count ?? 0) <= 0 {
//                            self.lblNoDataFound.text = Localized("noDataFound")
//                            self.lblNoDataFound.isHidden = false
//                            self.tableView.separatorColor = UIColor.clear
//                        } else {
//                            self.lblNoDataFound.isHidden = true
//                        }
//                        self.tableView.reloadData()
//                        self.updateTableContentInset()
                        self.apiGetSettingDetails()
                    } else {
                        self.showAlert(title: Localized("alert"), message: CategoriesModel.shared.singerObjBasedOnCat?.message ?? Localized("somethingWentWrong"))
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
            }
        }
    }
    
    //MARK:- Contact US API Calling
    fileprivate func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        CategoriesModel.shared.settingResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                    }
                    
                    if CategoriesModel.shared.settingResponse?.status == true {
                        if let observer = self.observer {
                            NotificationCenter.default.removeObserver(observer)
                        }
                        if let selectedCountry = getSelectedCountry()  {
                            self.navigateToWelcomeScreen()
                            
                        } else {
                            
                            if self.isSingleCountry == true
                            {
                                self.navigateToWelcomeScreen()
                            }
                            else
                            {
                                let vc = self.storyboard?.instantiateViewController(identifier: "CountrySelectionViewController") as! CountrySelectionViewController
                                vc.isComingFromSetting = false
                                self.fadeTo(vc)
                            }
                            
                        }
                    } else{
                        // Maintenance changes
//                        guard let window = UIApplication.shared.keyWindow else {
//                                 return
//                             }
//                             let frontViewController = MaintenanceViewController.object()
//                     //        let frontViewController = TabBarViewController.object() //TabBarController.object()
//                             let frontNavigationController = UINavigationController(rootViewController: frontViewController)
//                             frontNavigationController.setNavigationBarHidden(false, animated: false)
//                             self.view.window?.rootViewController = frontNavigationController
//
//                             let options: UIView.AnimationOptions = .transitionCrossDissolve
//                             let duration: TimeInterval = 1
//                             UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
//                                 // maybe do something on completion here
//                             })
                        
                    }
                    
                   
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                    self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                self.showAlert(title: Localized("alert"), message: Localized("somethingWentWrong"))
            }
        }
    }
    
    
    fileprivate func apiGetSetting() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        CategoriesModel.shared.settingResponse = try JSONDecoder().decode(SettingResponse.self, from: getDara)
                        
                        if (CategoriesModel.shared.settingResponse?.countries?.count ?? 0) == 1
                        {
                            self.isSingleCountry = true
                            let selectedCountry = CategoriesModel.shared.settingResponse?.countries![0]
                            UserDefaults.standard.encode(for: selectedCountry, using: "selectedCountryObj")
                        }
                        else
                        {
                            self.isSingleCountry = false
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
}
