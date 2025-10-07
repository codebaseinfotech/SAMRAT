//
//  GlobalAPICalling.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 04/05/21.
//

import Foundation
import UIKit
import Alamofire

extension UIViewController {
    
    //MARK:- API FAQ Details getting
    func updateUserDetails() {
        APIManager.handler.GetRequest(url: ApiUrl.profile, isLoader: false, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                do {
                    guard let data = data else {return}
                    UserModel.shared.objUser = nil
                    UserModel.shared.objUser = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if UserModel.shared.objUser?.status == true {
                        loginOption.shared.normalLogin(true)
                        if let userData = UserModel.shared.objUser {
                            UserDefaults.standard.encode(for: userData, using: UserKey.loginUserData.rawValue)
                        }
                    }else {
//                        self.showAlert(title: Localized("alert"), message: UserModel.shared.objUser?.message ?? "Please check email & Password")
                        //(toastText: UserModel.shared.objUser?.message ?? "", withStatus: toastFailure)
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
    
    
    
    func mangePostAPI(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (APIManager.apiResult2) -> ()) {
        APIManager.handler.PostRequest(url: url, params: params, isLoader: isLoader, header: nil, controller: self) { (result) in
            switch result {
            case .success(let data):
                completion(.success(data))
                break
            case .failure(let error):
                completion(.failure(error.localizedLowercase))
                JSN.log("failur error login api ===>%@", error)
                break
            }
        }
    }
}
