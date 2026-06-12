//
//  APIManager.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation
import Alamofire
import Network
import AVFoundation

let apiToken = "123"
let language = Language.shared.isArabic ? "ar":"en"
let content_type = "application/json"
let accept = "application/json"
let deviceId = UIDevice.current.identifierForVendor!.uuidString
let deviceType = "2"
var devicePushToken = "123"
//version 1.6(11)
//version 1.7(12)
//version 1.8(13)
//version 1.9(14)
let appVersion = "32" //Need to increase version by +1 whenever new build needs to upload on app store

struct BaseUrl {
    static let liveUrl = "https://samrat.app/api/"
//    static let liveUrl = "https://dev.samrat.app/api/"
}

struct ApiUrl {
    
    //static let mainUrl = BaseUrl.testServer
    
    static let mainUrl = BaseUrl.liveUrl
    
    static let login = mainUrl + "login"
    static let registration = mainUrl + "v3/registration"
    static let singer = mainUrl + "v8/singers"
    static let serviceAmount = mainUrl + "v9/bookings/get-singer-service-amount"
    static let createBooking = mainUrl + "v10/bookings/create"
    static let getMusicians = mainUrl + "v7/musicians"
    static let mp3Path = "https://samrat.app/public/"
    static let categories = mainUrl + "v3/categories/singers"
    static let change_password = mainUrl + "change-password"
    static let faq = mainUrl + "v1/faqs"
    static let contact_us = mainUrl + "v1/contact-us"
    static let settings = mainUrl + "v1/settings"
    static let BookingServices = mainUrl + "v8/booking-services"
    static let Paymentoption = mainUrl + "v10/bookings/totalBookingAmount"
    static let update = mainUrl + "profile/update"
    static let profile = mainUrl + "profile"
    static let aboutUs = mainUrl + "v1/about-us"
    static let termsAndCondition = mainUrl + "v1/terms-and-conditions"
    static let cancellation_policy = mainUrl + "v1/cancellation-policy"
    static let privacy_policy = mainUrl + "v1/privacy-policy"
    static let get_gallery = mainUrl + "v1/get-gallery"
    static let getBokkings = mainUrl + "v3/bookings/get"
    static let getBokkingsDates = mainUrl + "v7/bookings/getBookingDate"
    static let socialLoginRegister = mainUrl + "social-login-register"
    static let forgotPwd = mainUrl + "v3/forgot-password"
    static let saveLanguage = mainUrl + "save-language"
    static let sendOTP = mainUrl + "send-otp"
    static let verifyOTP = mainUrl + "verify-otp"
    static let checkUpdate = mainUrl + "v1/check-app-status"
    static let delete_Account = mainUrl + "delete-account"
    static let getCountries = mainUrl + "v3/countries"
    static let transactionStore = mainUrl + "v4/transaction/store"
    static let logout_App = mainUrl + "v8/logout"
    
    static let GET_BOOOKING_BANDS = mainUrl + "v8/bookings/bands"
}

func apiHeaderParam() -> [String : String]?  {
    var headersParam: [String : String] = [String : String]()
    if SamratGlobal.loggedInUser()?.user == nil {
        headersParam = ["Accept":accept,"Content-Type":content_type,"language":Language.shared.isArabic ? "ar":"en","apiToken":apiToken]
    }else {
        let loginToken = SamratGlobal.loggedInUser()?.token ?? ""
        
        headersParam = ["Authorization":loginToken,"Accept":accept,"Content-Type":content_type,"language":Language.shared.isArabic ? "ar":"en","apiToken":apiToken]
        
    }
    return headersParam
}

class APIManager: NSObject {

    // MARK: - Other Methods
    static var isConnectedToNetwork: Bool {
        let network = NetworkReachabilityManager()
        return (network?.isReachable)!
    }

    static let handler = APIManager()

    // MARK: - API Logging Helper
    private func logAPIRequest(url: String, method: String, params: [String: Any]? = nil, headers: [String: String]?) {
        print("\n╔══════════════════════════════════════════════════════════════")
        print("║ 🚀 API REQUEST")
        print("╠══════════════════════════════════════════════════════════════")
        print("║ URL: \(url)")
        print("║ Method: \(method)")
        if let params = params {
            print("║ Parameters: \(params)")
        }
        if let headers = headers {
            print("║ Headers: \(headers)")
        }
        print("╚══════════════════════════════════════════════════════════════\n")
    }

    private func logAPIResponse(url: String, statusCode: Int?, response: Any?, error: Error? = nil) {
        print("\n╔══════════════════════════════════════════════════════════════")
        print("║ 📥 API RESPONSE")
        print("╠══════════════════════════════════════════════════════════════")
        print("║ URL: \(url)")
        if let statusCode = statusCode {
            print("║ Status Code: \(statusCode)")
        }
        if let error = error {
            print("║ ❌ Error: \(error.localizedDescription)")
        }
        if let response = response {
            if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("║ Response: \(jsonString)")
            } else {
                print("║ Response: \(response)")
            }
        }
        print("╚══════════════════════════════════════════════════════════════\n")
    }
    
    var request: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    enum apiResult {
        case success([String:Any])
        case failure(String)
    }
    
    enum apiResult2 {
        case success(Data?)
        case failure(String)
    }
    
    func serverPostRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, setLogout: Bool = true, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            var headers:HTTPHeaders?
            if header == nil {
                headers = ["Content-Type": "application/json"]
            }else {
                headers = header
            }

            // Log Request
            logAPIRequest(url: url, method: "POST", params: params, headers: apiHeaderParam())

            Alamofire.request(url, method: HTTPMethod.post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in//(header != nil) ? header:

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                guard checkForLogout(response: response, vc: controller, setLogout: setLogout) else {
                    return
                }

                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        if isLoader == true {
                            stopLoader()
                        }

                    }
                    break

                case .failure(_):
                    stopLoader()
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        stopLoader()
                    }
                    //                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                    break
                }
            }
        } else {
            controller?.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func serverMultiPartFormRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, setLogout: Bool = true, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            let headers = ["Content-Type": "application/json"]

            // Log Request
            logAPIRequest(url: url, method: "POST (MultiPart)", params: params, headers: apiHeaderParam())

            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in//(header != nil) ? header:

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                guard checkForLogout(response: response, vc: controller, setLogout: setLogout) else {
                    return
                }

                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        stopLoader()
                    }
                    break

                case .failure(_):
                    stopLoader()
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            }
        } else {
            controller?.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func serverPostPaymentRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, setLogout: Bool = true, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            //            let headers = ["Content-Type": "application/json"]

            // Log Request
            logAPIRequest(url: url, method: "POST (Payment)", params: params, headers: apiHeaderParam())

            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                guard checkForLogout(response: response, vc: controller, setLogout: setLogout) else {
                    return
                }

                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        stopLoader()
                    }
                    break

                case .failure(_):
                    stopLoader()
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            }
        } else {
            controller?.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func serverGetRequest(url:String, isLoader:Bool, header:HTTPHeaders?,controller:UIViewController? = nil, setLogout: Bool = true, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                //                base.startLoader()
            }

            // Log Request
            logAPIRequest(url: url, method: "GET", params: nil, headers: apiHeaderParam())

            Alamofire.request(url, method: .get, parameters:nil, encoding: URLEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                guard checkForLogout(response: response, vc: controller, setLogout: setLogout) else {
                    return
                }

                switch(response.result) {
                case .success(_):

                    if let data = response.result.value {
                        let json = data as? [String:Any] ?? [:]
                        completion(.success(json))
                        //                        base.stopLoader()
                    }
                    break

                case .failure(_):
                    //                    base.stopLoader()
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            }

        } else {
            controller?.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func serverPostRequest3(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?,controller:UIViewController? = nil, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            let headers = ["Content-Type": "application/json"]

            // Log Request
            logAPIRequest(url: url, method: "POST", params: params, headers: apiHeaderParam())

            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseString(completionHandler: { [weak self] (response) in

                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let jsonString = data as? String ?? ""
                        let json = [String: Any]()

                        let string = jsonString
                        let data = string.data(using: .utf8)!
                        do {
                            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: Any] {
                                // Log Response
                                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: jsonArray, error: nil)
                                completion(.success(jsonArray))
                            } else {
                                print("bad json")
                                // Log Response Error
                                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: jsonString, error: nil)
                            }
                        } catch let error as NSError {
                            print(error)
                            // Log Response Error
                            self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: jsonString, error: error)
                        }
                        stopLoader()
                    }
                    break
                case .failure(let error):
                    stopLoader()
                    // Log Response Error
                    self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: nil, error: error)
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            })
            //            { (response) in
            //
            //                switch(response.result) {
            //                case .success(_):
            //                    if let data = response.result.value {
            //                        let json = data as? [String:Any] ?? [:]
            //                        completion(.success(json))
            //                        stopLoader()
            //                    }
            //                    break
            //
            //                case .failure(_):
            //                    stopLoader()
            //                    completion(.failure(Localized("pleaseCheckInternetConnection")))
            //                }
            //            }
        } else {
            controller?.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    //MARK:- Search Product
    func searchProduct(_ url: String, isLoader: Bool, completion: @escaping (apiResult) -> ()) {
        if Internet.isConnected() == true {
            //            if isLoader == true {
            //                base.startLoader()
            //            }
            //            let headers = ["Content-Type": "application/json"]

            // Log Request
            logAPIRequest(url: url, method: "GET (Search)", params: nil, headers: apiHeaderParam())

            Alamofire.SessionManager.default.session.getAllTasks { tasks in tasks.forEach { $0.cancel() }}
            Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response:DataResponse<Any>) in

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                switch(response.result) {
                case .success(_):
                    if let data = response.result.value {
                        let json = data as! [String:Any]
                        completion(.success(json))
                        //                        base.stopLoader()
                    }
                    break
                case .failure(_):
                    //                    base.stopLoader()
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            }
        } else {
            //            base.stopLoader()
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func PostRequest(url:String, params:[String:Any], isLoader:Bool,header:HTTPHeaders?, setLogout: Bool = true, controller:UIViewController, completion: @escaping (apiResult2) -> ()) {
        // Log Request
        logAPIRequest(url: url, method: "POST", params: params, headers: apiHeaderParam())

        if Internet.isConnected() == true {
            if isLoader == true {
                //                startLoaderWithColor()
            }

            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                guard checkForLogout(response: response, vc: controller, setLogout: setLogout) else {
                    return
                }

                switch(response.result) {
                case .success(_):
                    if let data = response.data {
                        completion(.success(data))
                        if isLoader == true {
                            //                            stopLoader()
                        }
                    }
                    break

                case .failure(_):
                    //                    stopLoader()
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            }
        } else {
            controller.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func PostWithCustomHeader(url:String, params:[String:Any], isLoader:Bool, setLogout: Bool = true, header:[String : String]?,controller: UIViewController, completion: @escaping (apiResult2) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                startLoaderWithColor()
            }
            let loginToken = SamratGlobal.loggedInUser()?.message ?? ""
            let tokenType = SamratGlobal.loggedInUser()?.message ?? ""

            // Log Request
            logAPIRequest(url: url, method: "POST (Custom Header)", params: params, headers: apiHeaderParam())

            Alamofire.request(url, method: .post, parameters:params, encoding: JSONEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

                guard checkForLogout(response: response, vc: controller, setLogout: setLogout) else {
                    return
                }

                switch(response.result) {
                case .success(_):
                    if let data = response.data {
                        completion(.success(data))
                        stopLoader()
                    }
                    break

                case .failure(_):
                    stopLoader()
                    completion(.failure(Localized("pleaseCheckInternetConnection")))
                }
            }
        } else {
            controller.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
    
    func GetRequest(url:String, isLoader:Bool, header:HTTPHeaders?,controller: UIViewController, completion: @escaping (apiResult2) -> ()) {
        if Internet.isConnected() == true {
            if isLoader == true {
                //                base.startLoader()
            }

            // Log Request
            logAPIRequest(url: url, method: "GET", params: nil, headers: apiHeaderParam())

            Alamofire.request(url, method: .get, parameters:nil, encoding: URLEncoding.default, headers: apiHeaderParam()).responseJSON { [weak self] (response) in

                // Log Response
                self?.logAPIResponse(url: url, statusCode: response.response?.statusCode, response: response.result.value, error: response.result.error)

               let statudCode = response.response?.statusCode

                if statudCode == 503{

                } else{
                    switch(response.result) {
                    case .success(_):
                        if let data = response.data {
                            completion(.success(data))
                            stopLoader()
                        }
                        break

                    case .failure(let error):
                        stopLoader()
                        completion(.failure(Localized("pleaseCheckInternetConnection")))
                    }
                }


            }

        } else {
            controller.showAlert(title: Localized("alert"), message: Localized("pleaseCheckInternetConnection"))
            //            base.customToast(toastText: Localized("pleaseCheckInternetConnection"), withStatus: toastFailure)
            completion(.failure(Localized("pleaseCheckInternetConnection")))
        }
    }
}

func checkForLogout( response: DataResponse<Any>, vc: UIViewController?, setLogout: Bool) -> Bool {
    if response.response?.statusCode == 401 && SamratGlobal.loggedInUser()?.user != nil {
        UserDefaults.standard.removeObject(forKey: UserKey.loginUserData.rawValue)
        UserDefaults.standard.synchronize()
        vc?.navigateToWelcomeScreen()//.encode(for: nil, using: UserKey<LoginResponse>.loginUserData)
        return false
    }
    return true
}

