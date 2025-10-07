import UIKit
import MASegmentedControl
import WMSegmentControl

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var viewSelectCountry: UIControl!
    
    @IBOutlet weak var developerByContainView: UIView!
    @IBOutlet var lblLang: UILabel!
    @IBOutlet var lblNotification: UILabel!
    @IBOutlet var lblMyAccount: UILabel!
    //    @IBOutlet var lblFaq: UILabel!
    @IBOutlet var lblContactUs: UILabel!
    @IBOutlet var lblTermsAndCondition: UILabel!
    @IBOutlet var lblAboutUs: UILabel!
    //    @IBOutlet var lblCancellationPolicy: UILabel!
    //    @IBOutlet var lblPrivacyPolicy: UILabel!
    @IBOutlet var lblLogout: UILabel!
    //    @IBOutlet var lblNotiOn: UILabel!
    //    @IBOutlet var lblNotiOff: UILabel!
    @IBOutlet var myAcountContainView: UIControl!
    //    @IBOutlet var btnLang: UIButton!
    //    @IBOutlet var btnNoti: UIButton!
    @IBOutlet var langSegment: UISegmentedControl!
    
    @IBOutlet var lblDeveloped: UILabel!
    @IBOutlet var btnDeveloped: UIButton!
    @IBOutlet var stckDevelop: UIStackView!
    
    @IBOutlet var notificationSegment: UISegmentedControl!
    
    @IBOutlet var segmentControlNoti : HBSegmentedControl!
    @IBOutlet var segmentControlLang : HBSegmentedControl!
    @IBOutlet weak var imgCountry: UIImageView!
    @IBOutlet weak var lblSelectedCountry: UILabel!
    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var viewWA: UIView!
    
    var isNotification = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
        //        self.btnNoti.isSelected = (isNotification == true) ?false:true
        self.developerByContainView.semanticContentAttribute = .forceLeftToRight
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.navigationItem.title = Localized("settings").uppercased() //"SETTINGS"
        
                self.langSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
                self.notificationSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        //        self.btnLang.isSelected = (Language.shared.isArabic == true) ? true:false
        self.langSegment.selectedSegmentIndex = (Language.shared.isArabic == true) ? 1:2
        self.notificationSegment.setTitle(Localized("on"), forSegmentAt: 0)
        self.notificationSegment.setTitle(Localized("off"), forSegmentAt: 1)
        self.lblDeveloped.text = Localized("Developed By")
        
        let attrs = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .bold),
            NSAttributedString.Key.foregroundColor : hexStringToUIColor(hex: "#CC8A65"),
            NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
        self.btnDeveloped.setAttributedTitle(NSMutableAttributedString(string:"Simplified Informatics", attributes:attrs), for: .normal)
        
        //Custom Segment Class for Notification
        segmentControlNoti.items = [Localized("on"), Localized("off")]
        segmentControlNoti.font = UIFont.systemFont(ofSize: 12)
        segmentControlNoti.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControlNoti.selectedIndex = 0
        segmentControlNoti.padding = 0
        
        segmentControlNoti.addTarget(self, action: #selector(self.segmentValueChangedForNoti(_:)), for: .valueChanged)
        
        
        //Custom Segment Class for Language
        segmentControlLang.items = ["English", "عربي"]
        segmentControlLang.font = UIFont.systemFont(ofSize: 12)
        segmentControlLang.borderColor = UIColor(white: 1.0, alpha: 0.3)
        segmentControlLang.selectedIndex = (Language.shared.isArabic == true) ? 1:0
//        segmentControlLang.selectedIndex = 0
        segmentControlLang.padding = 0
        
        segmentControlLang.addTarget(self, action: #selector(self.segmentValueChangedForLang(_:)), for: .valueChanged)
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        stckDevelop.semanticContentAttribute = .spatial
        self.updateText()
        
        self.apiGetSettingDetails()
        
        self.updateCountry()
    }
    
    func updateCountry() {
        if let selectedCountry = getSelectedCountry() {
           print("selectedCountry : \(selectedCountry)")
            self.lblSelectedCountry.text = Language.shared.isArabic ? selectedCountry.country_ar : selectedCountry.country
            
            
            let url = URL(string: selectedCountry.flag_url ?? "")
            self.imgCountry.kf.setImage(with: url,
                                                 placeholder: nil,
                                                 options: [.transition(.fade(0.3)),
                                                           .cacheOriginalImage,
                                                           .forceTransition]) { (_, _) in
                                                               
                                                           } completionHandler: { (_, _, _, _) in
                                                               if let imgPlace = self.imgCountry.subviews.first(where: { $0.layer.name == "placeholder" }) {
                                                                   imgPlace.isHidden = true
                                                               }
                                                           }
            
            
        }
    }
    @objc func segmentValueChangedForNoti(_ sender: AnyObject?){
        
        if segmentControlNoti.selectedIndex == 0 {
            print(Localized("on"))
            NotificationDefault.shared.isOn = true
        }else{
            print(Localized("off"))
            NotificationDefault.shared.isOn = false
        }
        setNotificaationTag()
    }
    
    @objc func segmentValueChangedForLang(_ sender: AnyObject?){
        JSN.log("sender.selectedSegmentIndex ==>%@", segmentControlLang.selectedIndex)
        if segmentControlLang.selectedIndex == 0 {
            Language.shared.isArabic = false
            UserDefaults.standard.set(false, forKey: "ar")
            
        } else if segmentControlLang.selectedIndex == 1 {
            Language.shared.isArabic = true
            UserDefaults.standard.set(true, forKey: "ar")
        }
        setNotificaationTag()
        apiCallSetLanguage()
    }
    
    @objc func onTapMoreAction() {
        
    }
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func onTapSiLogo(_ sender: UIControl) {
        if let url = URL(string: "https://si-kw.com/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnLangSelection(_ sender: UISegmentedControl) {
        JSN.log("sender.selectedSegmentIndex ==>%@", sender.selectedSegmentIndex)
        if sender.selectedSegmentIndex == 0 {
            Language.shared.isArabic = false
            UserDefaults.standard.set(false, forKey: "ar")
        }else if sender.selectedSegmentIndex == 1 {
            Language.shared.isArabic = true
            UserDefaults.standard.set(true, forKey: "ar")
        }
        apiCallSetLanguage()
    }
    
    @IBAction func btnNotiSelection(_ sender: UIButton) {
        isNotification = !isNotification
        sender.isSelected = (isNotification == true) ?false:true
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
                            self.viewSelectCountry.isHidden = true
                        }
                        else
                        {
                            self.viewSelectCountry.isHidden = false
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
    
//    @IBAction func btnLangSelection(_ sender: UIButton) {
//
//        //        JSN.log("sender.selectedSegmentIndex ==>%@", sender.tag)
//        if sender.isSelected {
//            Language.shared.isArabic = false
//            UserDefaults.standard.set(false, forKey: "ar")
//        }else{
//            Language.shared.isArabic = true
//            UserDefaults.standard.set(true, forKey: "ar")
//        }
//
//        DispatchQueue.async {
//            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//            UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
//            UITableView.appearance().semanticContentAttribute = .forceLeftToRight
//            UIVisualEffectView.appearance().semanticContentAttribute = .forceLeftToRight
//            UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
//
//            if Language.shared.isArabic {
//                UIView.appearance().semanticContentAttribute = .forceRightToLeft
//                UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
//                UITableView.appearance().semanticContentAttribute = .forceRightToLeft
//                UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
//                UIVisualEffectView.appearance().semanticContentAttribute = .forceRightToLeft
//            }
//            DispatchQueue.async {
//                self.navigateToWelcomeScreen()
//            }
//        }
//
//
//    }
    
    func updateText() {
        if SamratGlobal.loggedInUser()?.user == nil {
            self.myAcountContainView.isHidden = true
            self.lblLogout.text = Localized("login")
        }else {
            self.myAcountContainView.isHidden = true
            self.lblLogout.text = Localized("myAccount") //"Logout"
        }
        self.lblLang.text = Localized("language")
        self.lblNotification.text = Localized("notification")
        self.lblMyAccount.text = Localized("myAccount")
        //        self.lblFaq.text = Localized("FAQs")
        self.lblContactUs.text = Localized("contactUs")
        self.lblTermsAndCondition.text = Localized("termsAndConditions")
        self.lblAboutUs.text = Localized("aboutUs")
        //        self.lblCancellationPolicy.text = Localized("cancellationPolicy")
        //        self.lblPrivacyPolicy.text = Localized("privacyPolicy")
    }
    
    //    @IBAction func onTapFaqAction(_ sender: UIControl) {
    //        let faqVc = FAQVC()
    //        self.navigationController?.pushViewController(faqVc, animated: true)
    //    }
    
    @IBAction func onTapMyAccountAction(_ sender: UIControl) {
        let myAccountvc = MyAccountVC()
        fadeTo(myAccountvc)
    }
    
    @IBAction func onTapContactus(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: "ContactUsViewController") as! ContactUsViewController
        fadeTo(vc)
    }
    
    @IBAction func onTapAboutUsAction(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "1"
        fadeTo(vc)
    }
    
    @IBAction func onTapTermsAndConditions(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "2"
        fadeTo(vc)
    }
    @IBAction func onTapCountrySelection(_ sender: UIControl) {
                let vc = self.storyboard?.instantiateViewController(identifier: "CountrySelectionViewController") as! CountrySelectionViewController
                vc.isComingFromSetting = true
                fadeTo(vc)
    }
    
    //    @IBAction func onTapCancelationPolicyAction(_ sender: UIControl) {
    //        let cancallationPolicyVC = CancallationPolicyVC()
    //        self.navigationController?.pushViewController(cancallationPolicyVC, animated: true)
    //    }
    //
    //    @IBAction func onTapPrivacyPolicyAction(_ sender: UIControl) {
    //        let cancallationPolicyVC = CancallationPolicyVC()
    //        cancallationPolicyVC.isPrivacyPolicy = true
    //        self.navigationController?.pushViewController(cancallationPolicyVC, animated: true)
    //    }
    
    @IBAction func onTapLogouAction(_ sender: UIControl) {
        if SamratGlobal.loggedInUser()?.user == nil {
            let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            fadeTo(vc)
        }else {
            let myAccountvc = MyAccountVC()
            fadeTo(myAccountvc)
        }
    }
    
    @IBAction func btnDevelopedPressed(_ sender: UIButton) {
        guard let url = URL(string: "https://si-kw.com/") else { return }
        UIApplication.shared.open(url)
    }
    
    //MARK: Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
        
        if indexPath.row == 0 {
            cell.lblTitle.text = "My Profile"
        } else if indexPath.row == 1 {
            cell.lblTitle.text = "About Us"
        } else if indexPath.row == 2 {
            cell.lblTitle.text = "Terms and Conditions"
        } else if indexPath.row == 3 {
            cell.lblTitle.text = "Contact Us"
        } else if indexPath.row == 4 {
            cell.lblTitle.text = "Rate Us"
        } else if indexPath.row == 5 {
            cell.lblTitle.text = "Share with your lovable"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            fadeTo(vc)
        } else if indexPath.row == 1 {
            let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
            vc.cmsType = "1"
            fadeTo(vc)
        } else if indexPath.row == 2 {
            let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
            vc.cmsType = "2"
            fadeTo(vc)
        } else if indexPath.row == 3 {
            let vc = self.storyboard?.instantiateViewController(identifier: "ContactUsViewController") as! ContactUsViewController
            fadeTo(vc)
        } else if indexPath.row == 4 {
        } else if indexPath.row == 5 {
        }
    }
    
    func apiCallSetLanguage() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.saveLanguage, params:
                                        ["language": Language.shared.isArabic ? "ar": "en",
                                         "device_type": deviceType], isLoader: true, header: nil, setLogout: false, controller: self) { result in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            UserDefaults.standard.setValue(true, forKey: "isAlreadyLaunch")
            UserDefaults.standard.synchronize()
            DispatchQueue.async {
                setSemantricFlow()
                self.navigateToWelcomeScreen()
                
            }
        }
    }
}
