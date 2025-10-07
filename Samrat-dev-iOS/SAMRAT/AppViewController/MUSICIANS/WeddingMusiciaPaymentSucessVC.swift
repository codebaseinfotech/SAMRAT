//
//  WeddingMusiciaPaymentSucessVC.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/03/22.
//

import UIKit

class WeddingMusiciaPaymentSucessVC: UIViewController {
    
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var lblPaymentSuceessMsg: UILabel!
    @IBOutlet var lblPaymentSuccessFul: UILabel!
    @IBOutlet var btnBackToHome: UIButton!
    var retryPayment: (() -> ())?
    
    var strMessage = ""
    var strType = 0
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var viewWA: UIView!
    
    
    var catId = 0
    var subCatId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
        
        if self.catId == 23{
            self.imgBackground.image = UIImage(named: "band_payment_success")
        } else{
            
        }
        
        
        if subCatId == 27 {
            self.imgBackground.image = UIImage(named: "band_tradional_payment_success")
        }
        
        if subCatId == 24 {
            self.imgBackground.image = UIImage(named: "band_arabic_takh_payment_success")
        }
        
        
        // Do any additional setup after loading the view.
        self.title = Localized("paymentSuccess").uppercased() //"PAYMENT SUCCESS"
        self.lblPaymentSuceessMsg.text = strMessage
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
//        fadeFrom()
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnBacktohomeAction(_ sender: Any) {
        if strType == 1 {
            self.navigateToWelcomeScreen()
        } else {
            retryPayment?()
            fadeFrom()
        }
    }
}
