//
//  SingerServiceModel.swift
//  SAMRAT
//
//  Created by Macbook on 25/04/22.
//

import Foundation

class SingerServiceModel {
    static let shared = SingerServiceModel()
    var servicesAmtDataObj : servicesAmtObj?
}


struct servicesAmtObj: Codable {
    var status: Bool?
    var data:servicesAmtData?
    var message: String?
    
}

struct servicesAmtData: Codable {
    var id:Int?
    var singer_id:Int?
    var title:String?
    var title_ar:String?
    var description:String?
    var description_ar:String?
    var display_order:Int?
    var image:String?
    var charge_type:Int?
    var price:IDIng?
    var duration:String?
    var additional_hour_price:Int?
    var commission_type:Int?
    var commission_value:Double?
    var min_hr:String?
    var max_hr:String?
    var status:Int?
    var deleted_at:String?
    var created_at:String?
    var updated_at:String?
    var commission_amount:Int?
    var sub_total_service_amount:String?
    var total_service_amount:Int?
}
