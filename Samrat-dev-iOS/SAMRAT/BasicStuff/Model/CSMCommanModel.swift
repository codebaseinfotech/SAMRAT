//
//  CSMCommanModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import Foundation

class CSMCommanModel {
    static let shared = CSMCommanModel()
    var csmResponseObj:CSMResponseObj?
}

struct CSMResponseObj:Codable {
    var status:Bool?
    var message:String?
    var data:CSMResponseData?
}

struct CSMResponseData:Codable {
    var id:Int?
    var slug:String?
    var title:String?
    var title_ar:String?
    var description:String?
    var description_ar:String?
    var status:Int?
    var created_at:String?
    var updated_at:String?
}
