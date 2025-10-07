import Foundation
import UIKit
import SwiftMessages
import ZAlertView
enum UIUserInterfaceIdiom : Int
{
    case unspecified
    case phone
    case pad
}

let app_delegate = UIApplication.shared.delegate as? AppDelegate

let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
let SCREEN_MAX_LENGTH    = max(SCREEN_WIDTH, SCREEN_HEIGHT)
let SCREEN_MIN_LENGTH    = min(SCREEN_WIDTH, SCREEN_HEIGHT)

let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH < 568.0
let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 568.0
let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 667.0
let IS_IPHONE_6_G        = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH >= 667.0
let IS_IPHONE_6_PLUS     = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 736.0
let IS_IPHONE_10         = UIDevice.current.userInterfaceIdiom == .phone && SCREEN_MAX_LENGTH == 812.0
//let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && SCREEN_MAX_LENGTH >= 1024.0
let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && SCREEN_MAX_LENGTH == 1366.0

let FONT_BOLD = "Avenir-Black"
let FONT_LIGHT = "Avenir-Light"
let FONT_MEDIUM = "Avenir-Medium"

let FONT_LUCIDA_BOLD = "LucidaGrande-Bold"
let FONT_LUCIDA = "LucidaGrande"

let FONT_KOHINOOR_BOLD = "KohinoorDevanagari-Bold"
let FONT_KOHINOOR_LIGHT = "KohinoorDevanagari-Light"
let FONT_KOHINOOR_REGULAR = "KohinoorDevanagari-Regular"
let FONT_KOHINOORM_EDIUM = "KohinoorDevanagari-Medium"

let BASE_COLOR = UIColor(red: (193.0/255.0), green: (156.0/255.0), blue: (127.0/255.0), alpha: 1.0)

func getUserDefaultObjectForKey(key: String) -> AnyObject!
{
    var retVal : AnyObject!;
    let prefs = UserDefaults.standard as UserDefaults
    retVal = prefs.object(forKey: key) as AnyObject
    return retVal
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

//extension UIViewController
//{
//    func startAnimating()
//    {
//        let activityData = ActivityData()
//        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
//    }
//
//    func stopAnimating()
//    {
//        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
//    }
//


func add(stringList: [String],
         font: UIFont,
         bullet: String = "\u{2022}",
         indentation: CGFloat = 20,
         lineSpacing: CGFloat = 2,
         paragraphSpacing: CGFloat = 12,
         textColor: UIColor = .black,
         bulletColor: UIColor = hexStringToUIColor(hex: "#CC8A65")) -> NSAttributedString {
    
    let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
    let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25), NSAttributedString.Key.foregroundColor: bulletColor]
    
    let paragraphStyle = NSMutableParagraphStyle()
    let nonOptions = [NSTextTab.OptionKey: Any]()
    paragraphStyle.tabStops = [
        NSTextTab(textAlignment: Language.shared.isArabic ? .right : .left, location: indentation, options: nonOptions)]
    paragraphStyle.defaultTabInterval = indentation
    //paragraphStyle.firstLineHeadIndent = 0
    //paragraphStyle.headIndent = 20
    //paragraphStyle.tailIndent = 1
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.paragraphSpacing = paragraphSpacing
    //    if Language.shared.isArabic {
    //        paragraphStyle.tailIndent = -indentation
    //    } else {
    paragraphStyle.headIndent = indentation
    //    }
    paragraphStyle.baseWritingDirection = Language.shared.isArabic ? .rightToLeft : .leftToRight
    
    let bulletList = NSMutableAttributedString()
    for string in stringList {
        let formattedString = "\(bullet)\t\(string)\n"
        let attributedString = NSMutableAttributedString(string: formattedString)
        
        attributedString.addAttributes(
            [NSAttributedString.Key.paragraphStyle : paragraphStyle],
            range: NSMakeRange(0, attributedString.length))
        
        attributedString.addAttributes(
            textAttributes,
            range: NSMakeRange(0, attributedString.length))
        
        let string:NSString = NSString(string: formattedString)
        let rangeForBullet:NSRange = string.range(of: bullet)
        attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
        bulletList.append(attributedString)
    }
    
    return bulletList
}


func showThemeAlert(msgTitle:String, msg: String, completion: @escaping (Bool) -> Void) {
    
    ZAlertView.positiveColor = UIColor(red:0.09, green:0.47, blue:0.24, alpha:1.0)
    let dialog = ZAlertView(title: msgTitle,
                            message: msg,
                            isOkButtonLeft: false,
                            okButtonText: Localized("Agree"),
                            cancelButtonText: Localized("Cancel"),
                            okButtonHandler: { (alertView) -> () in
                                alertView.dismissAlertView()
                                completion(true)
                            },
                            cancelButtonHandler: { (alertView) -> () in
                                alertView.dismissAlertView()
                                completion(false)
                            }
    )
    dialog.show()
    dialog.allowTouchOutsideToDismiss = true
    UIApplication.shared.keyWindow?.addSubview(dialog.view)
}
public func showToastMessage(strMessage : String)
{
    let view = MessageView.viewFromNib(layout: .messageView)
    view.configureTheme(.warning)
    view.configureDropShadow()
    view.button?.isHidden = true
    view.configureContent(title: "", body: strMessage, iconText: "")
    
    SwiftMessages.show(view: view)
}

public func showMessage(strMessage : String)
{
    let view = MessageView.viewFromNib(layout: .messageView)
    view.configureTheme(.success)
    view.configureDropShadow()
    view.button?.isHidden = true
    view.configureContent(title: "", body: strMessage, iconText: "")
    
    SwiftMessages.show(view: view)
}
 func getSelectedCountry() -> CountriesData? {
    if let selectedCountry = UserDefaults.standard.decode(for: CountriesData.self, using: "selectedCountryObj") {
       return selectedCountry
    }
     return nil
}

//
//    func showAlert(title: String,message: String,callback:@escaping (_ isYes:Bool)->Void){
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: NSLocalizedString("LN_NO", comment: ""), style: .cancel) { action in }
//        alertController.addAction(cancelAction)
//        let destroyAction = UIAlertAction(title: NSLocalizedString("LN_YES", comment: ""), style: .destructive) { action in
//            callback(true)
//        }
//        alertController.addAction(destroyAction)
//        self.present(alertController, animated: true) {}
//    }
//
//    //Adding a child view controller
//    func displayContentController(content: UIViewController) {
//        addChildViewController(content)
//
//        self.view.addSubview(content.view)
//        content.didMove(toParentViewController: self)
//    }
//
//    //Removing a child view controller
//    func hideContentController(content: UIViewController) {
//        content.willMove(toParentViewController: nil)
//        content.view.removeFromSuperview()
//        content.removeFromParentViewController()
//    }
//
//    func timeAgoSinceDate(_ date:Date, numericDates:Bool = false) -> String {
//        let calendar = NSCalendar.current
//        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
//        let now = Date()
//        let earliest = now < date ? now : date
//        let latest = (earliest == now) ? date : now
//        let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
//
//        if (components.year! >= 2) {
//            return "\(components.year!) för flera år sedan"
//        } else if (components.year! >= 1){
//            if (numericDates){
//                return "1 för flera år sedan"
//            } else {
//                return "Förra året"
//            }
//        } else if (components.month! >= 2) {
//            return "\(components.month!) månader sedan"
//        } else if (components.month! >= 1){
//            if (numericDates){
//                return "1 månader sedan"
//            } else {
//                return "Förra månaden"
//            }
//        } else if (components.weekOfYear! >= 2) {
//            return "\(components.weekOfYear!) veckor sedan"
//        } else if (components.weekOfYear! >= 1){
//            if (numericDates){
//                return "1 veckor sedan"
//            } else {
//                return "Förra veckan"
//            }
//        } else if (components.day! >= 2) {
//            return "\(components.day!) dagar sedan"
//        } else if (components.day! >= 1){
//            if (numericDates){
//                return "1 dagar sedan"
//            } else {
//                return "I går"
//            }
//        } else if (components.hour! >= 2) {
//            return "\(components.hour!) timmar sedan"
//        } else if (components.hour! >= 1){
//            if (numericDates){
//                return "1 timme sedan"
//            } else {
//                return "En timme sedan"
//            }
//        } else if (components.minute! >= 2) {
//            return "\(components.minute!) minuter sedan"
//        } else if (components.minute! >= 1){
//            if (numericDates){
//                return "1 minut sedan"
//            } else {
//                return "För en minut sedan"
//            }
//        } else {
//            return "Precis nu"
//        }
//    }
//
//    func getCountryCallingCode(countryRegionCode:String)->String{
//
//        let prefixCodes = ["AF": "93", "AE": "971", "AL": "355", "AN": "599", "AS":"1", "AD": "376", "AO": "244", "AI": "1", "AG":"1", "AR": "54","AM": "374", "AW": "297", "AU":"61", "AT": "43","AZ": "994", "BS": "1", "BH":"973", "BF": "226","BI": "257", "BD": "880", "BB": "1", "BY": "375", "BE":"32","BZ": "501", "BJ": "229", "BM": "1", "BT":"975", "BA": "387", "BW": "267", "BR": "55", "BG": "359", "BO": "591", "BL": "590", "BN": "673", "CC": "61", "CD":"243","CI": "225", "KH":"855", "CM": "237", "CA": "1", "CV": "238", "KY":"345", "CF":"236", "CH": "41", "CL": "56", "CN":"86","CX": "61", "CO": "57", "KM": "269", "CG":"242", "CK": "682", "CR": "506", "CU":"53", "CY":"537","CZ": "420", "DE": "49", "DK": "45", "DJ":"253", "DM": "1", "DO": "1", "DZ": "213", "EC": "593", "EG":"20", "ER": "291", "EE":"372","ES": "34", "ET": "251", "FM": "691", "FK": "500", "FO": "298", "FJ": "679", "FI":"358", "FR": "33", "GB":"44", "GF": "594", "GA":"241", "GS": "500", "GM":"220", "GE":"995","GH":"233", "GI": "350", "GQ": "240", "GR": "30", "GG": "44", "GL": "299", "GD":"1", "GP": "590", "GU": "1", "GT": "502", "GN":"224","GW": "245", "GY": "595", "HT": "509", "HR": "385", "HN":"504", "HU": "36", "HK": "852", "IR": "98", "IM": "44", "IL": "972", "IO":"246", "IS": "354", "IN": "91", "ID":"62", "IQ":"964", "IE": "353","IT":"39", "JM":"1", "JP": "81", "JO": "962", "JE":"44", "KP": "850", "KR": "82","KZ":"77", "KE": "254", "KI": "686", "KW": "965", "KG":"996","KN":"1", "LC": "1", "LV": "371", "LB": "961", "LK":"94", "LS": "266", "LR":"231", "LI": "423", "LT": "370", "LU": "352", "LA": "856", "LY":"218", "MO": "853", "MK": "389", "MG":"261", "MW": "265", "MY": "60","MV": "960", "ML":"223", "MT": "356", "MH": "692", "MQ": "596", "MR":"222", "MU": "230", "MX": "52","MC": "377", "MN": "976", "ME": "382", "MP": "1", "MS": "1", "MA":"212", "MM": "95", "MF": "590", "MD":"373", "MZ": "258", "NA":"264", "NR":"674", "NP":"977", "NL": "31","NC": "687", "NZ":"64", "NI": "505", "NE": "227", "NG": "234", "NU":"683", "NF": "672", "NO": "47","OM": "968", "PK": "92", "PM": "508", "PW": "680", "PF": "689", "PA": "507", "PG":"675", "PY": "595", "PE": "51", "PH": "63", "PL":"48", "PN": "872","PT": "351", "PR": "1","PS": "970", "QA": "974", "RO":"40", "RE":"262", "RS": "381", "RU": "7", "RW": "250", "SM": "378", "SA":"966", "SN": "221", "SC": "248", "SL":"232","SG": "65", "SK": "421", "SI": "386", "SB":"677", "SH": "290", "SD": "249", "SR": "597","SZ": "268", "SE":"46", "SV": "503", "ST": "239","SO": "252", "SJ": "47", "SY":"963", "TW": "886", "TZ": "255", "TL": "670", "TD": "235", "TJ": "992", "TH": "66", "TG":"228", "TK": "690", "TO": "676", "TT": "1", "TN":"216","TR": "90", "TM": "993", "TC": "1", "TV":"688", "UG": "256", "UA": "380", "US": "1", "UY": "598","UZ": "998", "VA":"379", "VE":"58", "VN": "84", "VG": "1", "VI": "1","VC":"1", "VU":"678", "WS": "685", "WF": "681", "YE": "967", "YT": "262","ZA": "27" , "ZM": "260", "ZW":"263"]
//        let countryDialingCode = prefixCodes[countryRegionCode]
//        return countryDialingCode!
//    }
//
//    func convertImageToBase64(image: UIImage) -> String {
//        let imageData = UIImagePNGRepresentation(image)!
//        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
//    }
//
//    func convertBase64ToImage(imageString: String) -> UIImage {
//        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
//        return UIImage(data: imageData)!
//    }
//
//    func showAlertPopUp(_ stringMessage: String)
//    {
//        let alertController = UIAlertController(title: NSLocalizedString("LN_OHIOEVV", comment: ""), message: stringMessage, preferredStyle: .alert)
//        let destroyAction = UIAlertAction(title: NSLocalizedString("LN_OK", comment: ""), style: .default) { action in
//        }
//        alertController.addAction(destroyAction)
//        self.present(alertController, animated: true) {}
//    }
//}
//
extension UIView {
    
    func applayShadow()
    {
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 2.5, height: 5.0)
        self.layer.shadowRadius = 5.0
        self.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    
    func applyGradient(colours: [UIColor], senderOpacity: Float = 1.0) -> Void {
        self.applyGradient(colours: colours, locations: nil,senderOpacity: senderOpacity)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?,senderOpacity: Float = 1) -> Void {
        
        if let subLayers = self.layer.sublayers
        {
            for layer in subLayers
            {
                if let ownLayer = layer as? CAGradientLayer
                {
                    ownLayer.removeFromSuperlayer()
                }
            }
        }
        
        let gradient: CAGradientLayer = CAGradientLayer()
        //        gradient.intTag = 101
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.opacity = senderOpacity
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func setRound(borderColor: UIColor, borderWidth: CGFloat)
    {
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layoutIfNeeded()
    }
}
//
//extension UITextField
//{
//    var isBlank: Bool
//    {
//        get
//        {
//            var boolIsempty = true
//            if let valueForText = self.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
//            {
//                boolIsempty = valueForText
//            }
//            return boolIsempty
//        }
//    }
//
//    func useUnderline()
//    {
//        let border = CALayer()
//        let borderWidth = CGFloat(1.0)
//        border.borderColor = UIColor.white.cgColor
//        border.frame = CGRect(x:0,y:self.frame.size.height - borderWidth,width:self.frame.size.width,height:self.frame.size.height)
//        border.borderWidth = borderWidth
//        self.layer.addSublayer(border)
//        self.layer.masksToBounds = true
//    }
//}
//
//extension UILabel
//{
//    func setSubTextColor(pSubString : String, pColor : UIColor)
//    {
//        let attributedString: NSMutableAttributedString = self.attributedText != nil ? NSMutableAttributedString(attributedString: self.attributedText!) : NSMutableAttributedString(string: self.text!)
//
//        let range = attributedString.mutableString.range(of: pSubString, options:NSString.CompareOptions.caseInsensitive)
//        if range.location != NSNotFound
//        {
//            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: pColor, range: range)
//        }
//        self.attributedText = attributedString
//    }
//    func setSubTextBold(pSubString : String, font: UIFont, pColor: UIColor){
//
//        let attributedString: NSMutableAttributedString = self.attributedText != nil ? NSMutableAttributedString(attributedString: self.attributedText!) : NSMutableAttributedString(string: self.text!);
//
//
//        let range = attributedString.mutableString.range(of: pSubString, options:NSString.CompareOptions.caseInsensitive)
//        if range.location != NSNotFound {
//            // NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
//
//            attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range);
//            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: pColor, range: range);
//        }
//        self.attributedText = attributedString
//
//    }
//}
//
//extension String
//{
//    //Validate Email
//    var isEmail: Bool
//    {
//        do {
//            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
//            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
//        } catch {
//            return false
//        }
//    }
//
//    var isValidPassword: Bool
//    {
//        do
//        {
//            let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
//            return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
//        }
//    }
//
//    func fromBase64() -> String? {
//        guard let data = Data(base64Encoded: self) else {
//            return nil
//        }
//
//        return String(data: data, encoding: .utf8)
//    }
//
//    func toBase64() -> String {
//        return Data(self.utf8).base64EncodedString()
//    }
//}
//
//private let ChannelDivider: CGFloat = 255
//
//public class RGBA: NSObject {
//    var red: CGFloat
//    var green: CGFloat
//    var blue: CGFloat
//    var alpha: CGFloat
//
//    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        self.red = red
//        self.green = green
//        self.blue = blue
//        self.alpha = alpha
//    }
//
//    init(intRed: Int, green: Int, blue: Int, alpha: Int) {
//        self.red = CGFloat(intRed)/ChannelDivider
//        self.green = CGFloat(green)/ChannelDivider
//        self.blue = CGFloat(blue)/ChannelDivider
//        self.alpha = CGFloat(alpha)/ChannelDivider
//    }
//}
//
//public class Grayscale: NSObject {
//    var white: CGFloat
//    var alpha: CGFloat
//
//    init(white: CGFloat, alpha: CGFloat) {
//        self.white = white
//        self.alpha = alpha
//    }
//}
//
//public class GradientPoint<C>: NSObject {
//    var location: CGFloat
//    var color: C
//
//    init(location: CGFloat, color: C) {
//        self.location = location
//        self.color = color
//    }
//}
//
//extension UIImage {
//
//    func compressImage (_ image: UIImage) -> UIImage
//    {
//        let actualHeight:CGFloat = image.size.height
//        let actualWidth:CGFloat = image.size.width
//        let imgRatio:CGFloat = actualWidth/actualHeight
//        let maxWidth:CGFloat = 1024.0
//        let resizedHeight:CGFloat = maxWidth/imgRatio
//        let compressionQuality:CGFloat = 0.5
//
//        let rect:CGRect = CGRect(x: 0, y: 0, width: maxWidth, height: resizedHeight)
//        UIGraphicsBeginImageContext(rect.size)
//        image.draw(in: rect)
//        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        let imageData:Data = UIImageJPEGRepresentation(img, compressionQuality)!
//        UIGraphicsEndImageContext()
//
//        return UIImage(data: imageData)!
//    }
//
//    public class func image(withGradientPoints gradientPoints: [GradientPoint<[CGFloat]>], colorSpace: CGColorSpace, size: CGSize) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, 0);
//        guard
//            let context = UIGraphicsGetCurrentContext(),
//            let gradient = CGGradient(colorSpace: colorSpace,
//                                      colorComponents: gradientPoints.flatMap { $0.color },
//                                      locations: gradientPoints.map { $0.location }, count: gradientPoints.count) else {
//                                        return nil
//        }
//
//        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: size.height), options: CGGradientDrawingOptions())
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return image
//    }
//
//    public class func image(withRGBAGradientPoints gradientPoints: [GradientPoint<RGBA>], size: CGSize) -> UIImage? {
//        return image(withGradientPoints: gradientPoints.map {
//            GradientPoint(location: $0.location, color: [$0.color.red, $0.color.green, $0.color.blue, $0.color.alpha])
//        }, colorSpace: CGColorSpaceCreateDeviceRGB(), size: size)
//    }
//
//    public class func image(withRGBAGradientColors gradientColors: [CGFloat: RGBA], size: CGSize) -> UIImage? {
//        return image(withRGBAGradientPoints: gradientColors.map {  GradientPoint(location: $0, color: $1)}, size: size)
//    }
//
//    public class func image(withGrayscaleGradientPoints gradientPoints: [GradientPoint<Grayscale>], size: CGSize) -> UIImage? {
//        return image(withGradientPoints: gradientPoints.map {
//            GradientPoint(location: $0.location, color: [$0.color.white, $0.color.alpha]) },
//                     colorSpace: CGColorSpaceCreateDeviceGray(), size: size)
//    }
//
//    public class func image(withGrayscaleGradientColors gradientColors: [CGFloat: Grayscale], size: CGSize) -> UIImage? {
//        return image(withGrayscaleGradientPoints: gradientColors.map { GradientPoint(location: $0, color: $1) }, size: size)
//    }
//
//    func maskWithColor(color: UIColor) -> UIImage? {
//        let maskImage = cgImage!
//
//        let width = size.width
//        let height = size.height
//        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
//
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
//
//        context.clip(to: bounds, mask: maskImage)
//        context.setFillColor(color.cgColor)
//        context.fill(bounds)
//
//        if let cgImage = context.makeImage() {
//            let coloredImage = UIImage(cgImage: cgImage)
//            return coloredImage
//        } else {
//            return nil
//        }
//    }
//}
//
//extension Bundle {
//    private static var bundle: Bundle!
//
//    public static func localizedBundle() -> Bundle! {
//        if bundle == nil {
//            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
//            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
//            bundle = Bundle(path: path!)
//        }
//
//        return bundle;
//    }
//
//    public static func setLanguage(lang: String) {
//        UserDefaults.standard.set(lang, forKey: "app_lang")
//        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
//        bundle = Bundle(path: path!)
//    }
//}
