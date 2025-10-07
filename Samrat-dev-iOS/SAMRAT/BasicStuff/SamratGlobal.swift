//
//  SamratGlobal.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import UIKit
import CoreData

var oneSignalId = "e3512531-85c6-4059-8b01-46331eb8fedd"//"f3649d6c-c9f6-45fc-a90c-c8ab8cf7dd96"

struct SamratGlobal {
    static func loggedInUser() -> LoginResponse? {
        
        guard let userData = UserDefaults.standard.decode(for: LoginResponse.self, using: UserKey.loginUserData.rawValue) else {
            return nil
        }
        
        return userData
    }
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate //Singlton instance
var context: NSManagedObjectContext!

class loginOption {
    static let shared = loginOption()
    var isAppleSignUp = false
    var isGoogleSignUp = false
    var isfacebookSignUp = false
    var isGuestUser = false
    var isNormal = false
    
    func normalLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isNormal = isLogin
    }
    
    func appleLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isAppleSignUp = isLogin
    }
    
    func googleLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isGoogleSignUp = isLogin
    }
    
    func facebookLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isfacebookSignUp = isLogin
    }
    
    func guestUserLogin(_ isLogin:Bool) {
        self.allLoginDisable()
        loginOption.shared.isGuestUser = isLogin
    }
    
    func allLoginDisable() {
        loginOption.shared.isNormal = false
        loginOption.shared.isAppleSignUp = false
        loginOption.shared.isGoogleSignUp = false
        loginOption.shared.isfacebookSignUp = false
        loginOption.shared.isGuestUser = false
    }
}

extension UserDefaults {
    func decode<T: Codable>(for type: T.Type, using key: String) -> T? {
        let defaults = UserDefaults.standard
        guard let str = defaults.object(forKey: key) as? String else {
            return nil
        }
        let decodedObject = try? JSONDecoder().decode(type, from: str.data(using: .utf8) ?? Data())
        return decodedObject
    }
    
    func encode<T: Codable>(for type: T, using key: String) {
        let defaults = UserDefaults.standard
        let encodedData = try? JSONEncoder().encode(type)
        defaults.set(String(data: encodedData ?? Data(), encoding: .utf8), forKey: key)
        defaults.synchronize()
    }
}

//func saveData(res: LoginResponse) {
//    if context == nil {
//        context = appDelegate.persistentContainer.viewContext
//    }
//    let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
//    let newUser = NSManagedObject(entity: entity!, insertInto: context)
//
//
//    let encodedData = try? JSONEncoder().encode(res)
//    newUser.setValue(String(data: encodedData ?? Data(), encoding: .utf8), forKey: UserKey.loginUserData.rawValue)
//
//    print("Storing Data..")
//    do {
//        try context.save()
//    } catch {
//        print("Storing data Failed")
//    }
//}
//
//func fetchData() -> LoginResponse? {
//    if context == nil {
//        context = appDelegate.persistentContainer.viewContext
//    }
//
//    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//    request.returnsObjectsAsFaults = false
//    do {
//        let result = try context.fetch(request)
//        if let daaataa = result.first as? NSManagedObject,
//           let userName = daaataa.value(forKey: UserKey.loginUserData.rawValue) as? String {
//            let decodedObject = try? JSONDecoder().decode(LoginResponse.self, from: userName.data(using: .utf8) ?? Data())
//            return decodedObject
//        }
//        return nil
//    } catch {
//        print("Fetching data Failed")
//        return nil
//    }
//}
//
//func deleteUser() {
//    if context == nil {
//        context = appDelegate.persistentContainer.viewContext
//    }
//    let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "User"))
//    do {
//        try context.execute(DelAllReqVar)
//    }
//    catch {
//        print(error)
//    }
//}
