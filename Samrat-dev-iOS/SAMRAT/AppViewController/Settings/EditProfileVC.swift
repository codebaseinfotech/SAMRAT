//
//  EditProfileVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 04/05/21.
//

import UIKit
import libPhoneNumber_iOS

class EditProfileVC: UIViewController {

    @IBOutlet var txtfName: UITextField!
    @IBOutlet var txtfPhoneNumber: UITextField!
    @IBOutlet var txtfEmailAddress: UITextField!
    @IBOutlet var txtfAddress: UITextField!
    @IBOutlet var btnUpdate: UIButton!
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
        self.title = Localized("MY PROFILE")
        btnUpdate.setTitle(Localized("Update Profile"), for: .normal)
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        self.txtfName.text = SamratGlobal.loggedInUser()?.user?.name ?? ""
        self.txtfPhoneNumber.text = SamratGlobal.loggedInUser()?.user?.mobile_no ?? ""
        self.txtfEmailAddress.text = SamratGlobal.loggedInUser()?.user?.email ?? ""
        //self.txtfAddress.text = SamratGlobal.loggedInUser()?.user?.address ?? ""
        
        if Language.shared.isArabic {
            txtfName.textAlignment = .right
            txtfPhoneNumber.textAlignment = .right
            txtfEmailAddress.textAlignment = .right
            txtfAddress.textAlignment = .right
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
    
    @IBAction func btnUpdateProfileAction(_ sender: UIButton) {
        if self.txtfName.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: Localized("alert"), message: "Please enter name!")
            return
        }
        
        if self.txtfEmailAddress.text?.trimmingCharacters(in: .whitespaces) == "" {
            self.showAlert(title: Localized("alert"), message: "Please enter email address")
            return
        }
        
      

        let selectedCountry = getSelectedCountry()
        if selectedCountry?.country_en == "Saudi arabia"{
            if (self.txtfPhoneNumber.text?.count ?? 0) != 9 && (self.txtfPhoneNumber.text?.count ?? 0) != 10 {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
                return
            }
        } else{
            if (self.txtfPhoneNumber.text?.trimmingCharacters(in: .whitespaces).count ?? 0) >= 10 {
                self.showAlert(title: Localized("alert"), message: Localized("pEnterValidMobileNumber"))
                return
            }
        }
     
//        let number =  "\(SamratGlobal.loggedInUser()?.user?.country_code ?? "965")\(self.txtfPhoneNumber.text ?? "")"
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
        
        
//        if self.txtfAddress.text?.trimmingCharacters(in: .whitespaces) == "" {
//            self.showAlert(title: Localized("alert"), message: "Please enter address")
//            return
//        }
        self.apiUpdateProfile()
    }
    
    //MARK:- Contact US API Calling
    func apiUpdateProfile() {
        let parameter = [
            "username" : self.txtfName.text ?? "",
            "email": self.txtfEmailAddress.text ?? "",
            "mobile_no": self.txtfPhoneNumber.text ?? "",
            "device_type": deviceType
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.update, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    if let getDara = data {
                        let contactUsResponse = try JSONDecoder().decode(CommanResponse.self, from: getDara)
                        if contactUsResponse.status == true {
                            //self.updateUserDetails()
                            var usr = SamratGlobal.loggedInUser()
                            usr?.user?.username = self.txtfName.text ?? ""
                            usr?.user?.name = self.txtfName.text ?? ""
                            usr?.user?.email = self.txtfEmailAddress.text ?? ""
                            usr?.user?.mobile_no = self.txtfPhoneNumber.text ?? ""
                            UserDefaults.standard.encode(for: usr!, using: UserKey.loginUserData.rawValue)
                            self.showAlert(title: Localized("alert"), message: contactUsResponse.message ?? Localized("somethingWentWrong")) {
                                self.view.endEditing(true)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else {
                            self.showAlert(title: Localized("alert"), message: contactUsResponse.message ?? Localized("somethingWentWrong")) {
                                
                            }
                            //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                        }
                    }
                } catch (let error) {
                    JSN.log("login uer ====>%@", error)
                }
            case .failure(let error):
                JSN.log("failur error login api ===>%@", error)
            }
        }
    }
}
