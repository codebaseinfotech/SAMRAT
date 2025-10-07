//
//  VerifyOTPVC.swift
//  SAMRAT
//
//  Created by Hardik Ramolia on 22/08/21.
//

import UIKit
import SVPinView

class VerifyOTPVC: UIViewController {
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnVerify: UIButton!
    @IBOutlet var btnResend: UIButton!
    @IBOutlet var txtOTP: UITextField!
    @IBOutlet var txt1: UITextField!
    @IBOutlet var txt2: UITextField!
    @IBOutlet var txt3: UITextField!
    @IBOutlet var txt4: UITextField!
    @IBOutlet var txt5: UITextField!
    @IBOutlet var txt6: UITextField!
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var pinContainerView: UIView!
    @IBOutlet weak var viewWA: UIView!
    
    var settingsResponse:SettingResponse? = nil
    var timer = Timer()
    var timerVal = 120

    var code = ""
    var mobile = ""
    var isSocialSignUp = false
    var socialUserName = ""
    var socialEmailAddress = ""
    var socialId = ""
    
    override func viewDidLoad() {
        lblHeader.text = Localized("verification code")
        lblMessage.text = Localized("verification message")
        btnVerify.setTitle(Localized("Verify"), for: .normal)
        btnResend.setTitle(Localized("Resend Code"), for: .normal)
        btnVerify.layer.cornerRadius = btnVerify.frame.height/2
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
//        txt1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        txt2.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        txt3.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        txt4.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        txt5.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
//        txt6.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        txt1.tag = 0
        txt2.tag = 1
        txt3.tag = 2
        txt4.tag = 3
        txt5.tag = 4
        txt6.tag = 5
        
        scheduledTimerWithTimeInterval()
        
        pinView.keyboardType = .numberPad
        pinView.backgroundColor = .clear
        pinView.style = .box
        pinView.textColor = hexStringToUIColor(hex: "#CC8A65")
        pinView.borderLineThickness = 0
        pinView.fieldBackgroundColor = hexStringToUIColor(hex: "#E4DBD5")
        pinView.fieldCornerRadius = 5
        pinView.activeBorderLineThickness = 0
        pinView.activeFieldBackgroundColor = hexStringToUIColor(hex: "#E4DBD5")
        pinView.activeFieldCornerRadius = 5
        pinView.isContentTypeOneTimeCode = true
        
        if Language.shared.isArabic {
            pinView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            pinView.isArabic = true
        }
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
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
    
    func setData(mobile: String, code: String) {
        self.mobile = mobile
        self.code = code
    }
    
    func scheduledTimerWithTimeInterval() {
        timerVal = 120
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }

    @objc func updateCounting() {
        timerVal -= 1
        if timerVal <= 0 {
            if timer.isValid { timer.invalidate() }
            btnResend.setTitle( Localized("Resend Code"), for: .normal)
            
        } else {
            btnResend.setTitle( Localized("Resend Code in") + " \(timerVal)", for: .normal)
        }
    }
    
    @IBAction func btnVerifyPressed(_ sender: UIButton) {
//        var otp = txt1.text ?? ""
//        otp += txt2.text ?? ""
//        otp += txt3.text ?? ""
//        otp += txt4.text ?? ""
//        otp += txt5.text ?? ""
//        otp += txt6.text ?? ""
//
        if pinView.getPin().count < 6 {
            self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
            return
        }
        
        let parameter = [
            "country_code" : "965",//code,
            "mobile_no": mobile,
            "otp": Int(pinView.getPin()) ?? 0,
            "device_type": deviceType
        ] as [String : Any]
        
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.verifyOTP, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                if let getDara = data {
                    self.settingsResponse = try? JSONDecoder().decode(SettingResponse.self, from: getDara)
                    if self.settingsResponse?.status == true {
                        let vc = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
                        vc.isSocialSignUp = self.isSocialSignUp
                        vc.socialUserName = self.socialUserName
                        vc.socialEmailAddress = self.socialEmailAddress
                        vc.socialId = self.socialId
                        vc.mobile = self.mobile
                        self.fadeTo(vc)
                    } else {
                        self.showAlert(title: Localized("alert"), message: self.settingsResponse?.message ?? Localized("somethingWentWrong")) {
                        }
                    }
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
            }
        }
    }
    
    @IBAction func btnResendPressed(_ sender: UIButton) {
        if timerVal > 0 {
            return
        }
        
        let parameter = [
            "country_code" : "965",//code,
            "mobile_no": mobile,
            "device_type": deviceType
        ]
        
        scheduledTimerWithTimeInterval()
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.sendOTP, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                if let getDara = data {
                    self.settingsResponse = try? JSONDecoder().decode(SettingResponse.self, from: getDara)
                    if self.settingsResponse?.status == true {
                        print(String(data: getDara, encoding: .utf8))
                    } else {
                        self.showAlert(title: Localized("alert"), message: self.settingsResponse?.message ?? Localized("somethingWentWrong")) {
                        }
                    }
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
            }
        }
    }
    
    @IBAction func txtPressed(_ sender: UITextField) {
        txtOTP.becomeFirstResponder()
    }
}

extension VerifyOTPVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField){

        let text = textField.text

        if (text?.utf16.count ?? 0) >= 1 {
            switch textField{
            case txt1:
                txt2.becomeFirstResponder()
            case txt2:
                txt3.becomeFirstResponder()
            case txt3:
                txt4.becomeFirstResponder()
            case txt4:
                txt5.becomeFirstResponder()
            case txt5:
                txt6.becomeFirstResponder()
            case txt6:
                txt6.resignFirstResponder()
            default:
                break
            }
        }else{

        }
    }
//
//
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //This lines allows the user to delete the number in the textfield.
        if string.isEmpty{
            return true
        }
        //----------------------------------------------------------------

        //This lines prevents the users from entering any type of text.
        if Int(string) == nil {
            return false
        }
        //----------------------------------------------------------------

        
        //This is where the magic happens. The OS will try to insert manually the code number by number, this lines will insert all the numbers one by one in each TextField as it goes In. (The first one will go in normally and the next to follow will be inserted manually)
        if string.count == 1 {
            if (textField.text?.count ?? 0) == 1 && textField.tag == 0{
                if (txt2.text?.count ?? 0) == 1{
                    if (txt3.text?.count ?? 0) == 1{
                        if (txt4.text?.count ?? 0) == 1{
                            if (txt5.text?.count ?? 0) == 1{
                                txt6.text = string
//                                DispatchQueue.main.async {
//                                    self.dismissKeyboard()
//                                    self.validCode()
//                                }
                                return false
                            }else{
                                txt5.text = string
                                return false
                            }
                        }else{
                            txt4.text = string
                            return false
                        }
                    }else{
                        txt3.text = string
                        return false
                    }
                }else{
                    txt2.text = string
                    return false
                }
            }
        }

        
        //This lines of code will ensure you can only insert one number in each UITextField and change the user to next UITextField when function ends.
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count


        if count == 1{
            if textField.tag == 0{
                DispatchQueue.main.async {
                    self.txt2.becomeFirstResponder()
                }

            }else if textField.tag == 1{
                DispatchQueue.main.async {
                    self.txt3.becomeFirstResponder()
                }

            }else if textField.tag == 2{
                DispatchQueue.main.async {
                    self.txt4.becomeFirstResponder()
                }

            }
            else if textField.tag == 3{
                DispatchQueue.main.async {
                    self.txt5.becomeFirstResponder()
                }

            }else if textField.tag == 4{
                DispatchQueue.main.async {
                    self.txt6.becomeFirstResponder()
                }

            }else {
//                DispatchQueue.main.async {
//                    self.dismissKeyboard()
//                    self.validCode()
//                }
            }
        }

        return count <= 1
    }

        
//        if textField != tx {
//            return true
//        }
//        let maxLength = 1
//        let currentString: NSString = (textField.text ?? "") as NSString
//        let newString: NSString =
//            currentString.replacingCharacters(in: range, with: string) as NSString
//        return newString.length <= maxLength
//    }
}
