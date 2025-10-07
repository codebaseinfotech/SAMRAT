//
//  FaqsModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 04/05/21.
//

import Foundation

class FaqsModel {
    static let shared = FaqsModel()
    var faqsResponseObj:FaqsResponseObj?
}

struct FaqsResponseObj:Codable {
    var status:Bool?
    var message:String?
    var data:[FaqsData]?
}


struct FaqsData:Codable {
    var id:Int?
    var title:String?
    var description:String?
    var status:Int?
    var created_at:String?
    var updated_at:String?
}


