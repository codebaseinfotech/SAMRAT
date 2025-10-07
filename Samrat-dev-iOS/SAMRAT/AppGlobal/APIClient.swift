//
//  APIClient.swift
//  SAMRAT
//
//  Created by Ankit Gabani on 03/04/23.
//

import Foundation
import Alamofire
import SVProgressHUD
import UIKit

class APIClient: NSObject {
    
    typealias completion = ( _ result: Dictionary<String, Any>, _ error: Error?) -> ()
    
    class var sharedInstance: APIClient {
        
        struct Static {
            static let instance: APIClient = APIClient()
        }
        return Static.instance
    }
    
    var responseData: NSMutableData!
    
    func pushNetworkErrorVC()
    {
        
    }
    
    
    func MakeAPICallWithAuthHeaderPost(_ url: String, parameters: [String: Any], completionHandler:@escaping (NSDictionary?, Error?, Int?) -> Void) {
        
        print("url = \(url)")
        
        if NetConnection.isConnectedToNetwork() == true
        {
            
            let token = UserDefaults.standard.value(forKey: "userToken") as? String
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding(destination: .methodDependent), headers: apiHeaderParam()).responseJSON { response in
                
                switch(response.result) {
                
                case .success:
                    if response.value != nil{
                        if let responseDict = ((response.value as AnyObject) as? NSDictionary) {
                            completionHandler(responseDict, nil, response.response?.statusCode)
                        }
                    }
                    
                case .failure:
                    print(response.error!)
                    print("Http Status Code: \(String(describing: response.response?.statusCode))")
                    completionHandler(nil, response.error, response.response?.statusCode )
                }
            }
        }
        else
        {
            print("No Network Found!")
            pushNetworkErrorVC()
            SVProgressHUD.dismiss()
        }
    }
    
    func MakeAPICallWithAuthHeaderGet(_ url: String, parameters: [String: Any], completionHandler:@escaping (NSDictionary?, Error?, Int?) -> Void) {
        
        print("url = \(url)")
        
        if NetConnection.isConnectedToNetwork() == true
        {
            let token = UserDefaults.standard.value(forKey: "userToken") as? String
            
            
            Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding(destination: .methodDependent), headers: apiHeaderParam()).responseJSON { response in
                
                switch(response.result) {
                
                case .success:
                    if response.value != nil{
                        if let responseDict = ((response.value as AnyObject) as? NSDictionary) {
                            completionHandler(responseDict, nil, response.response?.statusCode)
                        }
                    }
                    
                case .failure:
                    print(response.error!)
                    print("Http Status Code: \(String(describing: response.response?.statusCode))")
                    completionHandler(nil, response.error, response.response?.statusCode )
                }
            }
        }
        else
        {
            print("No Network Found!")
            pushNetworkErrorVC()
            SVProgressHUD.dismiss()
        }
    }
    
    
    func showIndicator(){
        SVProgressHUD.show()
    }
    
    func hideIndicator(){
        SVProgressHUD.dismiss()
    }
    
    func showSuccessIndicator(message: String){
        SVProgressHUD.showSuccess(withStatus: message)
    }
}
