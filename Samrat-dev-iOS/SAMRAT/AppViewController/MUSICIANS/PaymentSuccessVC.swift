//
//  PaymentSuccessVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 30/04/21.
//

import UIKit

class PaymentSuccessVC: UIViewController {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblPaymentSuceessMsg: UILabel!
    @IBOutlet var lblPaymentSuccessFul: UILabel!
    @IBOutlet var btnBackToHome: UIButton!
    @IBOutlet weak var btnBottomConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var viewWA: UIView!
    
    var catId = 0
    
    var strMessage = ""
    var strType = 0
    
    @IBOutlet weak var rightTopConstrain: NSLayoutConstraint!
    var getResponseMsg:createBookingObj? = nil
    var getResponseMsgOld:createBookingObjOld? = nil
    var retryPayment: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)

        
        self.title = Localized("paymentSuccess").uppercased() //"PAYMENT SUCCESSFUL"
        self.lblPaymentSuceessMsg.text = self.strMessage
        self.lblPaymentSuccessFul.text = Localized("paymentSuccessful")
        self.btnBackToHome.setTitle(Localized("backToHome"), for: .normal)
        
        var imageLeft = UIImage(named: "")
        imageLeft = imageLeft?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: imageLeft, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.menuClick(_:)))
        
        if strType == 1 {
            
        } else {
            self.lblPaymentSuceessMsg.isHidden = true
            imgView.image = UIImage(named: "cross-sign")
            lblPaymentSuccessFul.text = Localized("paymentFailed")
            self.title = ""
            btnBackToHome.setTitle(Localized("tryagain"), for: .normal)
        }
    }
    
    @objc func menuClick(_ sender:UIButton) {
        self.view.endEditing(true)
//        fadeFrom()
    }
    
    @IBAction func btnBacktohomeAction(_ sender: Any) {
        if strType == 1 {
            self.navigateToWelcomeScreen()
        } else {
            retryPayment?()
            fadeFrom()
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
}
