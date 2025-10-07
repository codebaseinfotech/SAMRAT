import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var txtEmail: UITextField!{
        didSet{
            txtEmail.layer.cornerRadius = 10.0
            txtEmail.clipsToBounds = true
        }
    }
    
    @IBOutlet var btnSubmit: UIButton!{
        didSet{
            //btnSubmit.roundCorners(corners: [.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 10.0)
            btnSubmit.clipsToBounds = true
        }
    }
    
    @IBOutlet var lblHeader: UILabel!
    @IBOutlet weak var viewWA: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
        viewWA.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        viewWA.addGestureRecognizer(panGesture)

        self.title = Localized("forgotPassword") //"FORGOT PASSWORD"
        self.txtEmail.placeholder = Localized("Mobile Email")
        lblHeader.text = Localized("Enter email mobile")
        self.btnSubmit.setTitle(Localized("submit"), for: .normal)
        self.btnSubmit.setTitle(Localized("submit"), for: .selected)
        btnSubmit.layer.cornerRadius = btnSubmit.frame.height / 2
        
        if Language.shared.isArabic == true {
            self.txtEmail.textAlignment = .right
        }
        
        var imageLeft = Language.shared.isArabic ? (UIImage(named: "rightArrow")):(UIImage(named: "back"))
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        // Do any additional setup after loading the view.
    }

    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
        fadeFrom()
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
    
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        self.view.endEditing(true)
//        if self.isValidEmail(testStr: self.txtEmail.text ?? "") == true {
            self.apiForgotPwd()
//        }else {
//            self.showAlert(title: Localized("alert"), message: Localized("pEnterValidEmailAddress"))
//        }
    }
    //MARK:- API Calling
    //MARK:- API Get Musician List
    func apiForgotPwd() {
        
        let selectedCountry = getSelectedCountry()
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
        APIManager.handler.PostRequest(url: ApiUrl.forgotPwd, params: [
                                        "email":self.txtEmail.text ?? "",
                                        "device_type": deviceType,
                                        "country_id":  selectedCountry?.id ?? 0],
                                       isLoader: true,
                                       header: nil,
                                       controller: self) { (result) in
            ActivityIndicatorWithLabel.shared.hideProgressView()
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    let getResponse = try? JSONDecoder().decode(CommanResponse.self, from: data)
                    if getResponse?.status == true {
                        self.showAlert(title: Localized("alert"), message: getResponse?.message ?? "") {
                            self.fadeToRoot()
                        }
                    } else {
                        self.showAlert(title: Localized("alert"), message: getResponse?.message ?? Localized("somethingWentWrong"))
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
}
