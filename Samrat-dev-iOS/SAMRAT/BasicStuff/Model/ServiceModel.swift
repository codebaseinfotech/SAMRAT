//
//  ServiceModel.swift
//  SAMRAT
//
//  Created by Macmini on 16/08/21.
//

import Foundation

class ServiceModel {
    static let shared = ServiceModel()
    var seriveseResponseObj:ServiceResponse?
}

struct ServiceResponse:Codable {
    var status:Bool?
    var booking_service:[serviceDetails]?
}

struct serviceDetails:Codable {
    var id:Int?
    var title:String?
    var title_ar:String?
    var description:String?
    var description_ar:String?
    var price:Int?
    var status:Int?
    var created_at:String?
    var updated_at:String?
    
}
