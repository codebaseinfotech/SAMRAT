//
//  AppLanguageManager.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation




//MARK: app lqng

enum AppLanguage: String {
    case eng = "en"
    case arebic = "ar"
}


//MARK:- userdefaultskey

enum UserKey: String {
    case loginUserData
}




//MARK: defaults keys

enum DefaultsKeys<T>: String{
        
    case appLanguage = "SamratAppCurrentLanguageKey"
    case loggedInUser
    case userWithAddresses
    
}

//MARK: App language manager

struct SamratLanguageManager {
    
    //MARK:- check language
    
    static var isArabic: Bool {
        if let lang = SamratUserDefaults.getvalue(key: DefaultsKeys<String>.appLanguage), let type = AppLanguage.init(rawValue: lang) {
            return type == .arebic
        } else {
            return false
        }
    }
    
}



struct SamratUserDefaults {
    
    
    static func setvalue<K>(key: DefaultsKeys<K>, value: Any?){
        let userDefaults = UserDefaults.standard
        userDefaults.set(value as? K, forKey: key.rawValue)
        userDefaults.synchronize()
    }
    
    static func getvalue<T>(key: DefaultsKeys<T>) -> T?{
        let userDefaults = UserDefaults.standard
        userDefaults.synchronize()
        return userDefaults.value(forKey: key.rawValue) as? T
    }
}





