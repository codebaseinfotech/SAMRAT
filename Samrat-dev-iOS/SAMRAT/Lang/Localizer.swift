//
//  Localizer.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 11/05/21.
//

import Foundation
import UIKit

class Localizer: NSObject {
    class func DoTheSwizzling() {
        // 1
        MethodSwizzleGivenClassName(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(key:value:table:)))
        
    }
}

extension Bundle {
    @objc func specialLocalizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
        let currentLanguage = Language.shared.currentAppLang
        var bundle = Bundle();
        if let _path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            bundle = Bundle(path: _path)!
        } else {
            let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            bundle = Bundle(path: _path)!
        }
        return bundle.specialLocalizedStringForKey(key: key, value: value, table: tableName)
    }
}

func Localized(_ string:String) -> String {
    let currentLanguage = Language.shared.currentAppLang
    var bundle = Bundle();
    if let _path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
        bundle = Bundle(path: _path)!
    } else {
        let _path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
        bundle = Bundle(path: _path)!
    }
    return bundle.localizedString(forKey: string, value: nil, table: nil)
}
/// Exchange the implementation of two methods for the same Class
func MethodSwizzleGivenClassName(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    let origMethod: Method = class_getInstanceMethod(cls, originalSelector)!;
    let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector)!;
    if (class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, overrideMethod);
    }
}



extension DispatchQueue {
    static func asyncAfter(deadline: Double,_ execute: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + deadline, execute: execute)
    }
    
    static func async(_ execute: @escaping () -> Void) {
        DispatchQueue.main.async(execute: execute)
    }
    static func asyncBackground(_ execute: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async(execute: execute)
    }
}


extension UIApplication {
    var cstm_userInterfaceLayoutDirection : UIUserInterfaceLayoutDirection {
        get {
            var direction = UIUserInterfaceLayoutDirection.leftToRight
            if Language.shared.isArabic == true {
                direction = .rightToLeft
            }
            return direction
        }
    }
    
    var userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        get {
            var direction = UIUserInterfaceLayoutDirection.leftToRight
            if Language.shared.isArabic == true {
                direction = .rightToLeft
            }
            return direction
        }
    }
}

