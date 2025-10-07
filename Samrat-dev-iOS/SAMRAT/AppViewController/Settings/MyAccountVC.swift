//
//  MyAccountVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import UIKit

class MyAccountVC: UIViewController {
    
    @IBOutlet var img1: UIImageView!
    @IBOutlet var img2: UIImageView!
    @IBOutlet var img3: UIImageView!
    @IBOutlet var img4: UIImageView!
    
    @IBOutlet weak var lblDeleteAccount: UILabel!
    @IBOutlet var lblEditprofile: UILabel!
    @IBOutlet var lblManageBooking: UILabel!
    @IBOutlet var lblChangerPwd: UILabel!
    @IBOutlet var lblLogout: UILabel!
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)
        
        self.title = Localized("myAccount").uppercased() //"MY ACCOUNT"
        self.lblEditprofile.text = Localized("editProfile")
        self.lblManageBooking.text = Localized("manageBookings")
        self.lblChangerPwd.text = Localized("changePassword")
        self.lblLogout.text = Localized("logout")
        self.lblDeleteAccount.text = Localized("deleteAccount")
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        if Language.shared.isArabic {
            self.img1.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.img2.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.img3.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            self.img4.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
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
    
    @IBAction func clickedWA(_ sender: Any) {
        print("Button Tapped")
        
        if let whatsappURL = URL(string: "https://api.whatsapp.com/send?phone=\(CategoriesModel.shared.settingResponse?.settings?.whatsapp_number ?? "")&text=") {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
    }
    
    @IBAction func onTapEditProfileAction(_ sender: UIControl) {
        let editProfileVC = EditProfileVC()
        fadeTo(editProfileVC)
    }
    
    @IBAction func onTapDeleteAccount(_ sender: UIControl) {
        AlertView.instance.showAlert(title: Localized("alert"),
                                     message: NSAttributedString(string: Localized("accountDeleteAlert")),
                                     alertType: .twoButton, firstButton: Localized("yes"), secondButton: Localized("no"),isChangePlace: true, cancelHandler: {
            self.userDeleteAccountAPI()
            //                                        setUserLogout()
            //                                        deleteUser()
//            self.navigateToWelcomeScreen()//.encode(for: nil, using: UserKey<LoginResponse>.loginUserData)
        })
    }
    
    @IBAction func onTapLogouteAction(_ sender: UIControl) {
        AlertView.instance.alertViewDelegate = nil
        AlertView.instance.showAlert(title: Localized("alert"),
                                     message: NSAttributedString(string: Localized("wouldYouLikeLogOut")),
                                     alertType: .twoButton, firstButton: Localized("yes"), secondButton: Localized("no"),isChangePlace: true, cancelHandler: {
            self.userLogoutAccountAPI()
           
        })
    }
    
    @IBAction func onTapChangePwdAction(_ sender: UIControl) {
        let changePwdVc =  ChangePasswordVC()
        fadeTo(changePwdVc)
    }
    
    @IBAction func onTapManageBookingAction(_ sender: UIControl) {
        let myBookingVC = MyBookingVC()
        fadeTo(myBookingVC)
    }
    
    
    //MARK:- API delete user account
    func userDeleteAccountAPI() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.delete_Account, params: ["id": SamratGlobal.loggedInUser()?.user?.id ?? 0,
                                                                          "device_type": deviceType], isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    JSN.log("Data printed ===>%@", String(data: data, encoding: .utf8))
                    let commonReasponse = try? JSONDecoder().decode(CommanResponse.self, from: data)
                    
                    if commonReasponse?.status == true {
                        setUserLogout()
                        self.navigateToWelcomeScreen()
                    } else {
                        setUserLogout()
                        //                                        deleteUser()
                        self.navigateToWelcomeScreen()//.encode(for: nil, using: UserKey<LoginResponse>.loginUserData)
                        //                            self.lblNoDataFound.isHidden = true
                        //                            self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? "")
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
    
    
    func userLogoutAccountAPI() {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.logout_App, params: ["device_type": deviceType,"device_token":devicePushToken], isLoader: true, header: nil, controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    JSN.log("Data printed ===>%@", String(data: data, encoding: .utf8))
                    let commonReasponse = try? JSONDecoder().decode(CommanResponse.self, from: data)
                    
                    if commonReasponse?.status == true {
                        
                        setUserLogout()
                        //                                        deleteUser()
                        self.navigateToWelcomeScreen()//.encode(for: nil, using: UserKey<LoginResponse>.loginUserData)
                    } else {
                        setUserLogout()
                        //                                        deleteUser()
                        self.navigateToWelcomeScreen()//.encode(for: nil, using: UserKey<LoginResponse>.loginUserData)
                        //                            self.lblNoDataFound.isHidden = true
                        //                            self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? "")
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
