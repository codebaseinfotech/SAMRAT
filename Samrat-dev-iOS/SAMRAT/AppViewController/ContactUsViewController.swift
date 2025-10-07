import UIKit
import UITextView_Placeholder
import MessageUI
import OneSignal

class ContactUsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet var txtMobile: UITextField!{
        didSet{
            txtMobile.layer.borderWidth = 1
            txtMobile.layer.borderColor = UIColor.white.cgColor
            txtMobile.layer.cornerRadius = 10
            txtMobile.attributedPlaceholder = NSAttributedString(string:"Mobile", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
//            txtMobile.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
            txtMobile.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtEmail: UITextField!{
        didSet{
            txtEmail.layer.borderWidth = 1
            txtEmail.layer.borderColor = UIColor.white.cgColor
            txtEmail.layer.cornerRadius = 10
            txtEmail.attributedPlaceholder = NSAttributedString(string:"Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
//            txtEmail.roundCorners(corners: [.bottomRight], radius: 0.0)
            txtEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var txtMessage: UITextView!{
        didSet{
            txtMessage.layer.borderWidth = 1
            txtMessage.layer.borderColor = UIColor.white.cgColor
            txtMessage.layer.cornerRadius = 10
//            txtMessage.roundCorners(corners: [.bottomRight], radius: 10.0)
            txtMessage.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
//            btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
//            btnSubmit.layer.cornerRadius = 25
            btnSubmit.clipsToBounds = true
        }
    }
    
    @IBOutlet var imgContact: UIImageView!{
        didSet{
            imgContact.layer.cornerRadius = 10.0
            imgContact.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnYoutube: UIButton!
    @IBOutlet var btnInsta: UIButton!
    @IBOutlet var btnFb: UIButton!
    @IBOutlet var btnTwitter: UIButton!
    @IBOutlet var btnCall: UIButton!
    @IBOutlet var btnMail: UIButton!
    @IBOutlet var btnWA: UIButton!
    @IBOutlet var btnSnap: UIButton!
    var settingsResponse:SettingResponse? = nil
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        
        self.title = Localized("contactUs").uppercased() //"Contact Us"
        self.txtEmail.placeholder = Localized("email")
        self.txtMobile.placeholder = Localized("mobile")
        self.txtMessage.placeholder = nil
        self.txtMessage.text = Localized("message")
        self.txtMessage.delegate = self
        
        if Language.shared.isArabic {
            self.txtEmail.textAlignment = .right
            self.txtMobile.textAlignment = .right
            self.txtMessage.textAlignment = .right
        }
        
        self.btnYoutube.isHidden = true
        self.btnFb.isHidden = true
        self.btnTwitter.isHidden = true
        btnSubmit.layer.cornerRadius = btnSubmit.frame.height / 2
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        self.apiGetSettingDetails()
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
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        if self.txtEmail.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: Localized("alert"), message: Localized("pEnterEmailAddress"))
            return
        }
        
        if self.isValidEmail(testStr: self.txtEmail.text ?? "") == false {
            self.showAlert(title: Localized("alert"), message: Localized("pEnterValidEmailAddress"))
            return
        }
        
        if self.txtMobile.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: Localized("alert"), message: Localized("pEnterMobilenumber"))
            return
        }
        
        if (self.txtMobile.text?.count ?? 0) < 8 {
            self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
            return
        }
        
        self.apiContactUs()
        
    }
    
    @IBAction func onTapYoutubeLink(_ sender: UIButton) {
        if let getYoutubeUrl = self.settingsResponse?.settings?.youtube {
            self.openUrl(getYoutubeUrl)
        }
    }
    
    @IBAction func onTapInstaAction(_ sender: UIButton) {
        if let getInstaUrl = self.settingsResponse?.settings?.instagram {
            self.openUrl(getInstaUrl)
        }
    }
    
    @IBAction func onTapFacebookAction(_ sender: UIButton) {
        if let getFacebookUrl = self.settingsResponse?.settings?.facebook {
            self.openUrl(getFacebookUrl)
        }
    }
    
    @IBAction func onTapTwitterAction(_ sender: UIButton) {
        if let getTwitterUrl = self.settingsResponse?.settings?.twitter {
            self.openUrl(getTwitterUrl)
        }
    }
    
    @IBAction func onTapCallAction(_ sender: UIButton) {
        if let url = URL(string: "tel://\(self.settingsResponse?.settings?.contact_number ?? "")"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onTapEmailAction(_ sender: UIButton) {
        self.sendEmail()
    }
    
    @IBAction func onTapWAAction(_ sender: UIButton) {
        if let getWAUrl = self.settingsResponse?.settings?.whatsapp_number,
           let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone="+getWAUrl+"&text=") {
            
               if UIApplication.shared.canOpenURL(whatsappURL) {
                   UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
               }
        }
    }
    
    @IBAction func onTapSnapAction(_ sender: UIButton) {
        if let getSnapUrl = self.settingsResponse?.settings?.snapchat {
            self.openUrl(getSnapUrl)
        }
    }
    
    func sendEmail() {
        if let url = URL(string: "mailto:\(self.settingsResponse?.settings?.email ?? "")") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func openUrl(_ urlString:String) {
        let url: URL?
        if urlString.hasPrefix("https://") {
            url = URL(string: urlString)
        } else {
            url = URL(string: "https://" + urlString)
        }
        if let getUrl = url {
            UIApplication.shared.open(getUrl)
        }
    }
    
    //MARK:- Contact US API Calling
    func apiGetSettingDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.settings, isLoader: false, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        self.settingsResponse = try? JSONDecoder().decode(SettingResponse.self, from: getDara)
                        if self.settingsResponse?.status == true {
                            let settings = self.settingsResponse?.settings
                            self.btnCall.isHidden = (settings?.contact_number ?? "") == ""
//                            self.btnYoutube.isHidden = (settings?.youtube ?? "") == ""
//                            self.btnFb.isHidden = (settings?.facebook ?? "") == ""
//                            self.btnTwitter.isHidden = (settings?.twitter ?? "") == ""
                            self.btnInsta.isHidden = (settings?.instagram ?? "") == ""
                            self.btnMail.isHidden = (settings?.email ?? "") == ""
                            self.btnWA.isHidden = (settings?.whatsapp_number ?? "") == ""
                            self.btnSnap.isHidden = (settings?.snapchat ?? "") == ""
                        } else {
                            self.showAlert(title: Localized("alert"), message: self.settingsResponse?.message ?? Localized("somethingWentWrong")) {

                            }
                            
                            // Maintenance changes
//                            guard let window = UIApplication.shared.keyWindow else {
//                                     return
//                                 }
//                                 let frontViewController = MaintenanceViewController.object()
//                         //        let frontViewController = TabBarViewController.object() //TabBarController.object()
//                                 let frontNavigationController = UINavigationController(rootViewController: frontViewController)
//                                 frontNavigationController.setNavigationBarHidden(false, animated: false)
//                                 self.view.window?.rootViewController = frontNavigationController
//
//                                 let options: UIView.AnimationOptions = .transitionCrossDissolve
//                                 let duration: TimeInterval = 1
//                                 UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
//                                     // maybe do something on completion here
//                                 })
                            
                        
                            
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
                break
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
    
    //MARK:- Contact US API Calling
    func apiContactUs() {
        let parameter = [
            "name" : SamratGlobal.loggedInUser()?.user?.username ?? "",
            "phone" : self.txtMobile.text ?? "",
            "email":self.txtEmail.text ?? "",
            "message":self.txtMessage.text ?? "",
            "device_type": deviceType,
            "app_version": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "",
            "player_id": OneSignal.getUserDevice()?.getUserId() ?? "",
            "user_id": SamratGlobal.loggedInUser()?.user?.id ?? "",
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.contact_us, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        let contactUsResponse = try? JSONDecoder().decode(CommanResponse.self, from: getDara)
                        if contactUsResponse?.status == true {
                            self.showAlert(title: Localized("alert"), message: contactUsResponse?.message ?? Localized("somethingWentWrong")) {
                                self.view.endEditing(true)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else {
                            self.showAlert(title: Localized("alert"), message: contactUsResponse?.message ?? Localized("somethingWentWrong")) {
                                
                            }
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
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
}

extension ContactUsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == Localized("message")) {
            textView.text = ""
            //textView.textColor = .white
        }
        textView.becomeFirstResponder() //Optional
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            textView.text = Localized("message")
            //textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
}
