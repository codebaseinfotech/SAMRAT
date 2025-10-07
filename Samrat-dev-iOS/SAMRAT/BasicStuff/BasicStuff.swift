//
//  BasicStuff.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 27/04/21.
//

import Foundation
import UIKit
import SVProgressHUD
import SystemConfiguration
import KRActivityIndicatorView
import KRProgressHUD
import OneSignal
import Kingfisher
import OneSignal

struct JSN {
    static var isNetworkConnected:Bool = false
    static func log(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("LOG :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
    static func error(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("ERROR :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
}
class SelectedCurrency : NSObject {
    static let shared:SelectedCurrency = SelectedCurrency()
    var currentAppCurrency:String {
        var selectedCurrency = "KD"
        if let selectedCountry = getSelectedCountry()  {
            selectedCurrency =  (Language.shared.isArabic ? selectedCountry.currency?.currency_symbol_ar : selectedCountry.currency?.currency_symbol_en) ?? ""
        }
        return selectedCurrency
    }
    var currentAppCurrencyCode:String {
        var selectedCurrency = "KWD"
        if let selectedCountry = getSelectedCountry()  {
            selectedCurrency =  (Language.shared.isArabic ? selectedCountry.currency?.currency_code : selectedCountry.currency?.currency_code) ?? ""
        }
        return selectedCurrency
    }
    override init() {
        super.init()
    }
}

class Language : NSObject {
    static let shared:Language = Language()
    let APPLE_LANGUAGE_KEY = "AppleLanguages"
    
    var currentAppLang:String {
        return self.isArabic ? "ar" : "en"
    }
    var isArabic:Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isLangugeSet")
        }
        get {
            return UserDefaults.standard.bool(forKey: "isLangugeSet")
        }
    }
    
    
    override init() {
        super.init()
    }
}

class NotificationDefault : NSObject {
    static let shared: NotificationDefault = NotificationDefault()
    let APPLE_Notification_KEY = "AppleNotifications"

    var isOn: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: APPLE_Notification_KEY)
        }
        get {
            return UserDefaults.standard.bool(forKey: APPLE_Notification_KEY)
        }
    }
    override init() {
        super.init()
    }
}

class CalanderSelectionModel: NSObject {
    static var shared = CalanderSelectionModel()
    var isArabic : Bool?
}


//extension String {
//    var htmlToAttributedString: NSAttributedString? {
//        guard let data = data(using: .utf8) else { return nil }
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//        } catch {
//            return nil
//        }
//    }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
//
//
//
//}

extension String {
    func htmlAttributedString(size: CGFloat, color: UIColor) -> NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
              body {
                color: \(color.hexString!);
                font-family: -apple-system;
                font-size: \(size)px;
              }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .utf8) else {
            return nil
        }

        guard let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)],
            documentAttributes: nil
            ) else {
            return nil
        }
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: size), range: NSMakeRange(0, attributedString.length))
        if Language.shared.isArabic {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .right
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        }
        return attributedString
    }
}

extension UIColor {
    var hexString:String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return  String(format: "#%02x%02x%02x", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }
}





extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    convenience init?(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
        let red, green, blue, alpha: CGFloat
        switch chars.count {
        case 3:
            chars = chars.flatMap { [$0, $0] }
            fallthrough
        case 6:
            chars = ["F","F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            return nil
        }
        self.init(red: red, green: green, blue:  blue, alpha: alpha)
    }
    
}

struct Colors {
    static let snomo = UIColor.rgb(red: 204, green: 138, blue: 101)
    static let snomoTransparant = UIColor.rgb(red: 204, green: 138, blue: 101)
}

extension UIStoryboard {
    enum Name: String {
        case main = "Main"
    }
}


private let cache = NSCache<NSNumber, UIImage>()
private let utilityQueue = DispatchQueue.global(qos: .utility)

extension UIImageView {
    func downloadImage(str: String?, placeholder: UIImage? = Images.appLogo) {
//        if let cachedImage = cache.object(forKey: str) {
//            image = cachedImage
//        } else {
//        utilityQueue.async {
//            guard let url = URL(string: str ?? ""),
//                  let data = try? Data(contentsOf: url) else { return }
//            DispatchQueue.main.async {
//                guard let img = UIImage(data: data) else { return }
//                self.image = img
////                cache.setObject(<#T##obj: UIImage##UIImage#>, forKey: <#T##NSNumber#>)
//            }
//        }
            
        let url = URL(string: str ?? "")
        let scale = UIScreen.main.scale
        let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 100.0 * scale, height: 100.0 * scale))

        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: [.transition(.fade(1)),
                                   .cacheOriginalImage,
                                   .forceTransition,
                                   .processor(resizingProcessor)]) { (_, _) in

        } completionHandler: { (_, _, _, _) in
            if let imgPlace = self.superview?.superview?.subviews.first(where: {$0.layer.name == "placeholder"}) {
                imgPlace.isHidden = true
            }
        }
    }
}

func isIphoneX() -> Bool {
    if( UIDevice.current.userInterfaceIdiom == .phone) {
        if(UIScreen.main.bounds.size.height >= 812) {
            return true
        }
    }
    return false
}


extension UIViewController {
    static func object(_ storyboardName: UIStoryboard.Name = UIStoryboard.Name.main) -> Self {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: Self.self)) as! Self
    }
    static func object(_ string:String,_ storyboardName: UIStoryboard.Name = UIStoryboard.Name.main) -> Self {
        let storyboard = UIStoryboard(name: storyboardName.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: string) as! Self
    }
    
    static func nib() -> Self {
        return UIViewController(nibName: String(describing: Self.self), bundle: Bundle.main) as! Self
    }
    
    func showAlert(title : String, message : String,_ completionhandler:(() -> ())? = nil) {
        AlertView.instance.alertViewDelegate = nil
        AlertView.instance.showAlert(title: title, message: NSAttributedString(string: message), alertType: .oneButton, firstButton: Localized("ok"), okHandler: {
            completionhandler?()
        })
    }
    
    func fadeTo(_ viewController: UIViewController) {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        viewController.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(viewController, animated: false)
        
    }
    
    func fadeFrom() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    func fadeToRoot() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func fadeToLogin() {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.navigationController?.view.layer.add(transition, forKey: nil)
        guard let vc = self.navigationController?.viewControllers.first(where: { $0 is LoginViewController }) else { return }
        self.navigationController?.popToViewController(vc, animated: false)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

public func hexStringToUIColor(hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func setSemantricFlow() {
    if Language.shared.isArabic {
        UIView.appearance().semanticContentAttribute = .forceRightToLeft
        UICollectionView.appearance().semanticContentAttribute = .forceRightToLeft
        UITableView.appearance().semanticContentAttribute = .forceRightToLeft
        UITabBar.appearance().semanticContentAttribute = .forceRightToLeft
        UIVisualEffectView.appearance().semanticContentAttribute = .forceRightToLeft
    } else {
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        UICollectionView.appearance().semanticContentAttribute = .forceLeftToRight
        UITableView.appearance().semanticContentAttribute = .forceLeftToRight
        UIVisualEffectView.appearance().semanticContentAttribute = .forceLeftToRight
        UITabBar.appearance().semanticContentAttribute = .forceLeftToRight
    }
}

//MARK:- Validation message
extension UIViewController {
    //MARK: EMAIL VALIDATION
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension UIViewController {
    func navigateToHome() {
        
        let frontViewController = LoginViewController.object() //TabBarController.object()
        let frontNavigationController = UINavigationController(rootViewController: frontViewController)
        frontNavigationController.setNavigationBarHidden(true, animated: false)
        self.view.window?.rootViewController = frontNavigationController
    }
    var notchHeight:CGFloat {
        let window = UIApplication.shared.windows[0]
        return window.safeAreaInsets.top
//        let bottomPadding = window.safeAreaInsets.bottom
    }
    func navigateToWelcomeScreen() {
        
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
//        let frontViewController = MaintenanceViewController.object()
        let frontViewController = TabBarViewController.object() //TabBarController.object()
        let frontNavigationController = UINavigationController(rootViewController: frontViewController)
        frontNavigationController.setNavigationBarHidden(false, animated: false)
        self.view.window?.rootViewController = frontNavigationController
        
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 1
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion: { completed in
            // maybe do something on completion here
        })
    }
}

//MARK:- Change Date Formate
extension UIViewController {
    func convertDateFormater(_ date: String, oriDateFormate:String = "yyyy-MM-dd HH:mm:ss z",requiredDateFormate:String = "") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oriDateFormate
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = requiredDateFormate
        return  dateFormatter.string(from: date!)
    }
    
    func showNoInternetAlert(str: String) {
        if str == "No Internet" {
            self.showAlert(title: Localized("alert"), message: Localized("No Internet")) {
            }
        }
    }
}

extension UITableViewCell {
    func convertDateFormater(_ date: String, oriDateFormate:String = "yyyy-MM-dd HH:mm:ss z",requiredDateFormate:String = "") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = oriDateFormate
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = requiredDateFormate
        return  dateFormatter.string(from: date!)
    }
}

//MARK:- Add Shadow
extension UIView {
    func shadow(shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float, shadowRadius: CGFloat) {
        layer.shadowOffset = shadowOffset
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func buttonShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    
    func tabShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
    
    func addShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 4
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func addLightShadow() {
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    func removeShadow() {
        
    }
    
    func addShadow2() {
        layer.shadowOffset = CGSize(width: 2, height: 4)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 8
        layer.masksToBounds = false
        clipsToBounds = false
    }
}


//MARK: START LOADER
func startLoader() {
    
    KRProgressHUD.show()
//    SVProgressHUD.show()
//    SVProgressHUD.setForegroundColor(.clear)//(AppColor.theme)
//    SVProgressHUD.setRingThickness(3)
//    SVProgressHUD.setBackgroundColor(.clear)//(UIColor.white)
//    SVProgressHUD.setDefaultMaskType(.clear)//(.black)
}
func startLoaderWithColor() {
    //    UIApplication.shared.beginIgnoringInteractionEvents()
//    SVProgressHUD.show()
//    SVProgressHUD.setForegroundColor(Colors.snomo)
//    SVProgressHUD.setRingThickness(3)
//    SVProgressHUD.setBackgroundColor(UIColor.white)
//    SVProgressHUD.setDefaultMaskType(.black)
    
//    KRProgressHUD.set(activityIndicatorViewColors: [Colors.snomo])
//    KRProgressHUD.show()

//    let image = UIImage(named: "loading-icon_2.gif")!
//
//    KRProgressHUD.showImage(image, size: CGSize(width: 175, height: 175),message: nil)
}
//MARK: STOP LOADER
func stopLoader() {
    //    UIApplication.shared.endIgnoringInteractionEvents()
//    SVProgressHUD.dismiss()
    KRProgressHUD.dismiss()
}

func setUserLogout() {
    
    OneSignal.removeExternalUserId()
    
    let userdef = UserDefaults.standard
    userdef.removeObject(forKey: UserKey.loginUserData.rawValue)
    userdef.synchronize()
}

func setNotificaationTag() {
    guard let userId = SamratGlobal.loggedInUser()?.user?.id else {
        return
    }
    
    var json: [String: Any] = [:]
    json["userId"] = userId
    json["isNoti"] = NotificationDefault.shared.isOn ? 1 : 0
    json["language"] = Language.shared.isArabic ? "Ar" : "En"
    print("setNotificaationTag \(json)")
    OneSignal.sendTags(json)
    OneSignal.setExternalUserId("\(userId)")
}

public class Internet {
    
    class func isConnected() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}


//MARK:- Tableview Extensions
final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

extension UITableView {
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 40))
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        //messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
