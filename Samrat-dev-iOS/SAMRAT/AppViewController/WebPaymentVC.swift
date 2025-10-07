//
//  WebPaymentVC.swift
//  SAMRAT
//
//  Created by Ankit Gabani on 20/10/22.
//

import UIKit
import WebKit

class WebPaymentVC: UIViewController, WKNavigationDelegate, UIWebViewDelegate, AlertViewDelegate
{
    func okayButtonTapped() {
        appDelegate.isFromBackPaymentScreen = true
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancleButtonTapped() {
        
        
    }
    @IBOutlet weak var imgBack: UIButton!
    

    @IBOutlet weak var llblTitle: UILabel!
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var viewWA: UIView!
    
    var dicCreateBookingObj = createBookingObj()
    
    var dicCreateBookingObjOld = createBookingObjOld()
    
    var dicParentCatObj:CategoriesData? = nil
    var categoriesDetails: CategoriesData? = nil

    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWA.layer.cornerRadius = viewWA.frame.width/2
                viewWA.clipsToBounds = true
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                viewWA.addGestureRecognizer(panGesture)
        
        if Language.shared.isArabic == true
        {
            imgBack.setImage(UIImage(named: "ic_ar_back"), for: .normal)
        }
        else
        {
            imgBack.setImage(UIImage(named: "ic_en_Back"), for: .normal)

        }
        
        self.llblTitle.text = Localized("Samrat")
        
        webView = WKWebView()
        DispatchQueue.main.async {
            self.webView.frame = CGRect.init(x: 0, y: 0, width: self.mainView.frame.size.width, height: self.mainView.frame.size.height)
            
            
            if self.dicCreateBookingObjOld.payment?.payment_link == nil
            {
                self.webView.load(NSURLRequest(url: NSURL(string: self.dicCreateBookingObj.payment?.payment_link ?? "")! as URL) as URLRequest)
            }
            else{
                self.webView.load(NSURLRequest(url: NSURL(string: self.dicCreateBookingObjOld.payment?.payment_link ?? "")! as URL) as URLRequest)
            }
            
            self.webView.allowsBackForwardNavigationGestures = true
            
            self.webView.navigationDelegate = self
            
            
            self.webView.scrollView.bounces = false
            
            self.mainView.addSubview(self.webView)
        }
        
        webView.navigationDelegate = self
 
        // Do any additional setup after loading the view.
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
   
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ActivityIndicatorWithLabel.shared.showProgressView(uiView: self.view)
    }
    
 
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ActivityIndicatorWithLabel.shared.hideProgressView()

        webView.evaluateJavaScript("window.location.href") { (result, error) in

            if error == nil {
                print(result as Any)

                let requestUrl = "\(result ?? "")"
                webView.evaluateJavaScript("document.documentElement.outerHTML") { (result, error) in
                    if error == nil {
                        print(result as Any)

                        let doc = "\(result ?? "")"
                        var strResponse = doc.replacingOccurrences(of: "<html><head></head><body>", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "</body></html>", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "\\", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "\\", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "\"</div>", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "<div style=\"display:block;\">", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "<div style=\"display:none;\">", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "</div>", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "<pre style=\"word-wrap: break-word; white-space: pre-wrap;\">\n  ", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "</pre>", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "<html lang=\"en\"><head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\">\n    <title></title>\n</head>\n\n<body>\n    <div style=\"display: none\">\n", with: "")
                        strResponse = strResponse.replacingOccurrences(of: "\n    \n\n\n\n", with: "")
                        if let responseDict = self.convertToDictionary(text: strResponse)
                        {
                            print(responseDict)
                            
                            let dicResponse = responseDict as! NSDictionary
                            
                            let type = dicResponse.value(forKey: "type") as? Int
                            let booking_transaction_message = dicResponse.value(forKey: "booking_transaction_message") as? String

                            if type == 1 {
                            
                            if self.dicParentCatObj?.id == 21 || self.dicParentCatObj?.id == 23 {
                                let paymentvc = WeddingMusiciaPaymentSucessVC()
                                paymentvc.strMessage = booking_transaction_message ?? ""
                                paymentvc.catId = self.dicParentCatObj?.id ?? 0
                                paymentvc.subCatId = self.categoriesDetails?.id ?? 0
                                paymentvc.strType = type ?? 0
                                paymentvc.retryPayment = {
                                    self.navigationController?.popViewController(animated: true)
                                }
                                self.fadeTo(paymentvc)
                            } else{
                                let paymentvc = PaymentSuccessVC()
                                paymentvc.catId = self.dicParentCatObj?.id ?? 0
                                paymentvc.strMessage = booking_transaction_message ?? ""
                                paymentvc.strType = type ?? 0
                                paymentvc.retryPayment = {
                                    self.navigationController?.popViewController(animated: true)
                                }
                                self.fadeTo(paymentvc)
                            }
                            
                            
                            }else {
                                self.showAlert(title: Localized("alert"), message: booking_transaction_message ?? Localized("somethingWentWrong"))
                                AlertView.instance.showAlert(title: Localized("alert"), message: NSAttributedString(string: booking_transaction_message ?? Localized("somethingWentWrong")), alertType: .oneButton)
                                AlertView.instance.alertViewDelegate = self
                             //   (toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
                            }
                            
                        }

                    }
                }

            }

        }

     }
    
    func convertToDictionary(text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
     }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        let dict = message.body as? Dictionary<String, String>
        print(dict)
    }
    
    
    @IBAction func clickedBack(_ sender: Any) {
        appDelegate.isFromBackPaymentScreen = true
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension URL {
    func queryParams() -> [String:String] {
        let queryItems = URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
        let queryTuples: [(String, String)] = queryItems?.compactMap{
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        } ?? []
        return Dictionary(uniqueKeysWithValues: queryTuples)
    }
}

extension String {
    public var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

    public func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
}
