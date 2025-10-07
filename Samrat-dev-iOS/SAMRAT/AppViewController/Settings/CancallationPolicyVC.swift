//
//  CancallationPolicyVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import UIKit

class CancallationPolicyVC: UIViewController {
    
    @IBOutlet var txtView: UITextView!
    @IBOutlet weak var viewWA: UIView!
    
    var isPrivacyPolicy = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
        
        // Do any additional setup after loading the view.
        if self.isPrivacyPolicy == true {
            self.title = Localized("privacyPolicy").uppercased() //"Privacy Policy"
            self.apiGetCSMResponse(url: ApiUrl.privacy_policy)
        }else {
            self.title = Localized("cancellationPolicy").uppercased() //"Cancellation Policy"
            self.apiGetCSMResponse(url: ApiUrl.cancellation_policy)
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

    
    
    //MARK:- API CAlling
    func apiGetCSMResponse(url:String) {
        APIManager.handler.GetRequest(url: url, isLoader: true, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    let socialMeadiResponse = try JSONDecoder().decode(CSMResponseObj.self, from: data)
                    
                    if socialMeadiResponse.status == true {
                        self.txtView.attributedText = (socialMeadiResponse.data?.description ?? "").htmlAttributedString(size: 18.0, color: #colorLiteral(red: 0.9277921319, green: 0.927813828, blue: 0.9278021455, alpha: 1))
//socialMeadiResponse.data?.description ?? ""
                    }else {
                        self.showAlert(title: Localized("alert"), message: socialMeadiResponse.message ?? Localized("somethingWentWrong"))
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
