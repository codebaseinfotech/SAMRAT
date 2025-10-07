//
//  ChangePasswordVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet var txtfOldPwd: UITextField!
    @IBOutlet var txtfNewPwd: UITextField!
    @IBOutlet var txtfConfirmPwd: UITextField!
    @IBOutlet var btnConfirm: UIButton!
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view.
        self.title = Localized("changePassword").uppercased()//"CHANGE PASSWORD"
        self.txtfOldPwd.placeholder = Localized("oldPwd")
        self.txtfNewPwd.placeholder = Localized("newPwd")
        self.txtfConfirmPwd.placeholder = Localized("confirmPassword")
        
        btnConfirm.setTitle(Localized("submit"), for: .normal)
        
        if Language.shared.isArabic == true {
            self.txtfOldPwd.textAlignment = .right
            self.txtfNewPwd.textAlignment = .right
            self.txtfConfirmPwd.textAlignment = .right
        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
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
    @objc func menuClick(_ sender:UIButton)
    {
        self.view.endEditing(true)
        fadeFrom()
    }
    
    
    
    @IBAction func onTapSubmitAction(_ sender: UIButton) {
        //        self.navigateToHome()
        //        self.navigateToWelcomeScreen()
        self.apiChangePwd()
    }
    
    
    
    
    //MARK:- API Change Pwd
    func apiChangePwd() {
        if self.txtfOldPwd.text == "" {
            self.showAlert(title: Localized("alert"), message: Localized("Please enter old password"))
            return
        }
        
        
        if self.txtfNewPwd.text == "" {
            self.showAlert(title: Localized("alert"), message: Localized("Please enter new password"))
            return
        }
        
        if self.txtfConfirmPwd.text == "" {
            self.showAlert(title: Localized("alert"), message: Localized("Please enter confirm password"))
            return
        }
        
        
        if self.txtfNewPwd.text != self.txtfConfirmPwd.text {
            self.showAlert(title: Localized("alert"), message: Localized("Your password and confirm password do not match"))
        }
        
        
        let parameter = [
            "old_password" : self.txtfOldPwd.text ?? "",
            "password" : self.txtfNewPwd.text ?? "",
            "password_confirmation": self.txtfConfirmPwd.text ?? "",
            "device_type": deviceType
        ] as [String : Any]
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.change_password, params: parameter, isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    
                    let getResponse = try? JSONDecoder().decode(CommanResponse.self, from: data)
                    
                    if getResponse?.status == true {
                        self.navigateToWelcomeScreen()
                    }else {
                        self.showAlert(title: Localized("alert"), message: getResponse?.message ?? Localized("somethingWentWrong"))
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
