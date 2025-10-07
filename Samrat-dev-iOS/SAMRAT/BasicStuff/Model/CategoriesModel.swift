//
//  CategoriesModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 03/05/21.
//

import Foundation


class CategoriesModel {
    static let shared = CategoriesModel()
    var categoriesObj: CatagoriesResponse?
    var singerObjBasedOnCat: singersObj?
    var settingResponse: SettingResponse?
}

class CatagoriesResponse: Codable {
    var status:Bool?
    var message:String?
    var data:[CategoriesData]?
}

struct CategoriesData:Codable {
    var id:Int?
    var name:String?
    var description:String?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
    var allow_multiple_singer_bookings:Int?
    var sub_categories_recursive:[CategoriesData]?
}


