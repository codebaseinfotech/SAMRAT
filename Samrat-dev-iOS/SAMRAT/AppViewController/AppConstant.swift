//
//  AppConstant.swift
//  Yummi
//
//  Created by Mohsin Baloch on 26/04/20.
//  Copyright © 2020 HypeTen. All rights reserved.
//

import Foundation
import UIKit

class AppConstant: NSObject {

    static let shared: AppConstant = AppConstant()
    
    var appMessages = AppMessages()
    
    var firstTimeHome = true
    var firstTimeMusician = true
    var firstTimeCat = true
    var firstTimeGallery = true
    var appOrangeColor = UIColor(red: 204/255.0, green: 138/255.0, blue: 101/255.0, alpha: 1.0)
}


class AppMessages : NSObject{
    var NoInternet = "No internet connection available, Please connect to internet and try again!"
    var BlankValidation = "First Name/Last Name should not be blank"
    var MobileValidation = "Mobile Number is not valid"
    var APIError = "Api Execution Error"
    var loginError = "Please Login First"
    var dummyTextToShare = "Dummy Text to Share"
    var errorFirstName = "Invalid First Name. Allow [3-18] Character"
    var errorLastName = "Invalid Last Name. Allow [3-18] Character"
    var errorInvalidEmail = "Invalid Email Address"
    var errorPassword = "Invalid Password."
    var errorGender = "Select Any Gender"
}

