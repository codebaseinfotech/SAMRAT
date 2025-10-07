//
//  SendOTPVC.swift
//  SAMRAT
//
//  Created by Hardik Ramolia on 22/08/21.
//

import UIKit

class SendOTPVC: UIViewController {
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnVerify: UIButton!
    @IBOutlet var txtCode: UITextField!
    @IBOutlet var txtMobile: UITextField!
    var isSocialSignUp = false
    var socialUserName = ""
    var socialEmailAddress = ""
    var socialId = ""
    var settingsResponse:SettingResponse? = nil
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        
        lblHeader.text = Localized("verification mobile")
        lblMessage.text = Localized("verification mobile message")
        lblMessage.isHidden = true
        btnVerify.setTitle(Localized("Send OTP"), for: .normal)
        txtCode.placeholder = Localized("Code")
        txtMobile.placeholder = Localized("mobile placeholder")
        btnVerify.layer.cornerRadius = btnVerify.frame.height/2
        
        //self.txtMobile.textAlignment = Language.shared.isArabic ? .right : .left
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        txtMobile.delegate = self
        if Language.shared.isArabic {
            txtMobile.textAlignment = .right
        }
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
    
    @IBAction func btnVerifyPressed(_ sender: UIButton) {
//        if (self.txtCode.text?.count ?? 0) < 2 {
//            self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
//            return
//        }
        
        let selectedCountry = getSelectedCountry()
        
        if selectedCountry?.country_en == "Saudi arabia"
        {
            if (self.txtMobile.text?.count ?? 0) != 9 && (self.txtMobile.text?.count ?? 0) != 10
            {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
                return
            }
       
            
        }
        else
        {
            if (self.txtMobile.text?.count ?? 0) != 8 {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
                return
            }
        }
   
        var parameter = ["":""]
        
        if selectedCountry?.country_en == "Saudi arabia"
        {
            parameter = [
                "country_code" : "966",//self.txtCode.text ?? "",
                "mobile_no":self.txtMobile.text ?? "",
                "device_type": deviceType
            ]
        }
        else
        {
            parameter = [
                "country_code" : "965",//self.txtCode.text ?? "",
                "mobile_no":self.txtMobile.text ?? "",
                "device_type": deviceType
            ]
        }
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.sendOTP, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                if let getDara = data {
                    self.settingsResponse = try? JSONDecoder().decode(SettingResponse.self, from: getDara)
                    if self.settingsResponse?.status == true {
                        print(String(data: getDara, encoding: .utf8))
                        let vc = self.storyboard?.instantiateViewController(identifier: "VerifyOTPVC") as! VerifyOTPVC
                        vc.setData(mobile: self.txtMobile.text ?? "", code: self.txtCode.text ?? "")
                        self.fadeTo(vc)
                    } else {
                        self.showAlert(title: Localized("alert"), message: self.settingsResponse?.message ?? Localized("somethingWentWrong")) {
                            self.fadeToLogin()
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(title: Localized("alert"), message: error) {
                }
            }
        }
    }
}

extension SendOTPVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtMobile.textAlignment = .left
        txtMobile.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if Language.shared.isArabic && (textField.text == "") {
            txtMobile.textAlignment = .right
        }
        txtMobile.placeholder = Localized("mobile placeholder")
    }
}
