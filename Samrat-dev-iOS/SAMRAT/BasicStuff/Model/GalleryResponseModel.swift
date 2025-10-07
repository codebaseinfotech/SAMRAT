//
//  GalleryResponseModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import Foundation

class GalleryResponseModel {
    static let shared = GalleryResponseModel()
    var galleryResponseObj:GalleryResponse?
}

struct GalleryResponse:Codable {
    var status:Bool?
    var message:String?
    var data:[GalleryResponseData]?
}

struct GalleryResponseData:Codable {
    var id:Int?
    var title:String?
    var image:String?
    var link:String?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
}
