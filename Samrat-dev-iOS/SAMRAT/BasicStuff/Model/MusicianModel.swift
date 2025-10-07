//
//  MusicianModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 30/04/21.
//

import Foundation


class MusicianModel {
    static var shared = MusicianModel()
    var musicanResponseObj:musicianRespoObj?
}

struct musicianRespoObj:Codable {
    var status:Bool?
    var message:String?
    var data:[musiciansObj]?
}

struct musiciansObj:Codable {
    var id:Int?
    var name:String?
    var description:String?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
    var max_selection:Int?
    var min_selection:Int?
    var selection_label:String?
    var selection_label_ar:String?
    var musicians:[musiciansDetails]?
}

struct musiciansDetails:Codable {
    var id:Int?
    var musician_category_id:Int?
    var name:String?
    var description:String?
    var image:String?
    var audio:String?
    var price:Double?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
    var category_name:String?
    var category_name_ar: String?
    var isPlay : Bool?
}
