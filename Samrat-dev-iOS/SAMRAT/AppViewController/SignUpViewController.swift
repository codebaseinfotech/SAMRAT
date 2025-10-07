import UIKit
import libPhoneNumber_iOS

class SignUpViewController: UIViewController
{
    
    @IBOutlet var txtName: UITextField!{
        didSet{
            txtName.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            txtName.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtMobile: UITextField!{
        didSet{
            txtMobile.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0.0)
            txtMobile.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtEmail: UITextField!{
        didSet{
            txtEmail.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0.0)
            txtEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtPassword: UITextField!{
        didSet{
            txtPassword.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0.0)
            txtPassword.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtConfirmPassword: UITextField!{
        didSet{
            txtConfirmPassword.roundCorners(corners: [.bottomRight], radius: 10.0)
            txtConfirmPassword.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
            //btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10.0)
            btnSubmit.clipsToBounds = true
        }
    }
    
    
    @IBOutlet var btnAggreTermsCondition: UIButton!
    @IBOutlet var btnAggreTermsConditionText: UIButton!
    @IBOutlet weak var viewWA: UIView!
    
    
    
    var isSocialSignUp = false
    var socialUserName = ""
    var socialEmailAddress = ""
    var socialId = ""
    var mobile = ""
    var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)

        
        self.title = Localized("signUp").uppercased() //"SIGN UP"
        self.btnAggreTermsConditionText.setTitle(Localized("agreeTermsCondition"), for: .normal)
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        // Do any additional setup after loading the view.
        if self.isSocialSignUp == true {
            self.txtEmail.text = self.socialEmailAddress
            self.txtEmail.isUserInteractionEnabled = false
            self.txtName.text = self.socialUserName
            self.txtPassword.isHidden = self.isSocialSignUp
            self.txtConfirmPassword.isHidden = self.isSocialSignUp
        }
        
        btnSubmit.layer.cornerRadius = btnSubmit.frame.height / 2
        
        self.updateArabicTxt()
        
    }
    
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
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
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    
    func updateArabicTxt() {
        self.txtName.placeholder = Localized("name") + "*"
        self.txtMobile.placeholder = Localized("mobile") + "*"
        self.txtEmail.placeholder = Localized("email")
        self.txtPassword.placeholder = Localized("password") + "*"
        self.txtConfirmPassword.placeholder = Localized("confirmPassword") + "*"
        self.btnSubmit.setTitle(Localized("registration").uppercased(), for: .normal)
        
        if Language.shared.isArabic == true {
            self.txtName.textAlignment = .right
            self.txtMobile.textAlignment = .right
            self.txtEmail.textAlignment = .right
            self.txtPassword.textAlignment = .right
            self.txtConfirmPassword.textAlignment = .right
        }
        self.txtMobile.text = mobile
        
        let selectedCountry = getSelectedCountry()
//        if selectedCountry?.country_en == "Saudi arabia"{
//            self.txtMobile.isEnabled = true
//        } else{
//            self.txtMobile.isEnabled = false
//        }
        
        self.txtMobile.isEnabled = true
    }
    
    @IBAction func onTapTermsAndConditionAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func onTapTermsAndConditionTextAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(identifier: "CMSViewController") as! CMSViewController
        vc.cmsType = "2"
        fadeTo(vc)
    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
//        if self.txtEmail.text?.trimmingCharacters(in: .whitespaces) == "" {
//            self.showAlert(title: Localized("alert"), message: Localized("pEnterEmailAddress"))
//            return
//        }
        if self.isValidEmail(testStr: self.txtEmail.text ?? "") == false {
            if self.txtEmail.text?.count ?? 0 > 0 {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidEmailAddress"))
                return
            }
            
        }
        if self.txtName.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: Localized("alert"), message: Localized("pEntername"))
            return
        }
        
        if self.txtMobile.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: Localized("alert"), message: Localized("pEnterMobilenumber"))
            return
        }
        
        let selectedCountry = getSelectedCountry()
        if selectedCountry?.country_en == "Saudi arabia"{
            if (self.txtMobile.text?.count ?? 0) != 9 && (self.txtMobile.text?.count ?? 0) != 10 {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
                return
            }
        } else{
            if (self.txtMobile.text?.count ?? 0) != 8 {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
                return
            }
        }
        
//        let selectedCountry = getSelectedCountry()
//
//        let number =  "\(selectedCountry?.code_format ?? "")\(self.txtMobile.text ?? "")"
//
//        guard let phoneUtil = NBPhoneNumberUtil.sharedInstance() else {
//                return
//            }
//
//        do {
//                let phoneNumber: NBPhoneNumber = try phoneUtil.parse(number, defaultRegion: "")
//                let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
//
//            if phoneUtil.isValidNumber(phoneNumber) {
//                print("Valid")
//
//
//            } else{
//                print("Invalid")
//                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
//                return
//            }
//                NSLog("[%@]", formattedString)
//            }
//            catch let error as NSError {
//                print(error.localizedDescription)
//                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
//                return
//            }
        
        if self.isSocialSignUp == false {
            if self.txtPassword.text?.trimmingCharacters(in: .whitespaces) == "" {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterPassword"))
                return
            }
            if (self.txtPassword.text?.count ?? 0) < 6 {
                self.showAlert(title: Localized("alert"), message: Localized("pwdLengthAlert"))
                return
            }
            if (self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces) == "") {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterCp"))
                return
            }
            if self.txtPassword.text?.trimmingCharacters(in: .whitespaces) != self.txtConfirmPassword.text?.trimmingCharacters(in: .whitespaces) {
                self.showAlert(title: Localized("alert"), message: Localized("passwrodNotMatch"))
                return
            }
            if self.btnAggreTermsCondition.isSelected == false {
                self.showAlert(title: Localized("alert"), message: Localized("youmustAgreeTermsCondition"))
                return
            }
        }
        
        if self.isSocialSignUp == true {
            self.apiSocialLogin(self.txtEmail.text ?? "", self.socialId, self.txtName.text ?? "")
        }else {
            self.signUpAPI()
        }
    }
    
    
    //MARK:- API Signup API
    func signUpAPI() {
        
        let selectedCountry = getSelectedCountry()
        
        var parameter = [
            "name" : self.txtName.text ?? "",
            "email" : self.txtEmail.text ?? "",
            "mobile_no":self.txtMobile.text ?? "",
            "password":self.txtPassword.text ?? "",
            "password_confirmation":self.txtConfirmPassword.text ?? "",
            "term_condition": true,
            "device_type":deviceType,
            "device_id":deviceId,
            "device_token": devicePushToken,
            "country_code": selectedCountry?.code ?? ""
            //"country_code": selectedCountry?.country_en == "Saudi arabia" ? selectedCountry?.code ?? "" : ""
        ] as [String : Any]
        
        
        
        if selectedCountry != nil {
            parameter["country_id"] = selectedCountry?.id
        }
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.registration, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    UserModel.shared.objUser = try? JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if UserModel.shared.objUser?.status == true {
                        loginOption.shared.normalLogin(true)
                        if let userData = UserModel.shared.objUser {
                            UserDefaults.standard.encode(for: userData, using: UserKey.loginUserData.rawValue)
                            if UserModel.shared.objUser?.status == true {
                                self.navigateToWelcomeScreen()
                            }
                        }
                    }else {
                        self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? Localized("somethingWentWrong"))
                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                    }
                    
                    
                }
                catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    //MARK:- SOCIAL SINGUP API CAlling
    func apiSocialLogin(_ userEmail:String,_ socialId:String,_ userName:String) {
        let selectedCountry = getSelectedCountry()
        let parameter = [
            "name":self.txtName.text ?? "",
            "email" : userEmail,
            "mobile_no" : self.txtMobile.text ?? "",
            "term_condition" : true,
            "social_id" : socialId,
            "address" : "",
            "comment" : "",
            "device_id" : deviceId,
            "device" : deviceType,
            "device_type": deviceType,
            "device_token": devicePushToken,
            "country_code": selectedCountry?.code ?? ""
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.socialLoginRegister, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                     let socialLoginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if socialLoginResponse.status == true {
                        loginOption.shared.googleLogin(true)
                        UserDefaults.standard.encode(for: socialLoginResponse, using: UserKey.loginUserData.rawValue)
                        if socialLoginResponse.status == true {
                            self.navigateToWelcomeScreen()
                        }
                    } else {
                        self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? Localized("somethingWentWrong"))
                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                    }
                }
                catch (let error) {
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
