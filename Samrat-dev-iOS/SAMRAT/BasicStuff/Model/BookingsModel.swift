//
//  BookingsModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 06/05/21.
//

import Foundation

class BookingsModel  {
    static let shared = BookingsModel()
    var bookingResObj:BookingResObj?
}

struct BookingResObj:Codable {
    var status:Bool?
    var message:String?
    var cur_page:Int?
    var total_page:Int?
    var bookings:[Bookings]?
    var data:[dateData]?
}

struct dateData:Codable {
    var booking_date:String?
}

struct Bookings:Codable {
    var id:Int?
    var customer_id:Int?
    var singer_id:Int?
    var booking_date:String?
    var is_default_musician:Int?
    var payment_name:String?
    var status:Int?
    var created_at:String?
    var updated_at:String?
    var musicians:[Musicians]?
    var singers:[Singer]?
    var transactions:[Transactions]?
    
}


struct Musicians:Codable {
    var id:Int?
    var musician_category_id:Int?
    var name:String?
    var description:String?
    var image:String?
    var status:Int?
    var is_deleted:Int?
    var created_at:String?
    var updated_at:String?
    var category_name:String?
    var category_description:String?
}

struct Singer:Codable {
    var id:Int?
    var category_id:Int?
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
    var category_description:String?
}

struct Transactions:Codable {
    var id:Int?
    var singer_booking_id:Int?
    var payment_type:Int?
    var payment_amount:String?
    var transaction_id:String?
    var card_type:Int?
    var card_number:String?
    var card_exp_month:Int?
    var card_exp_year:Int?
    var created_at:String?
    var updated_at:String?
}
