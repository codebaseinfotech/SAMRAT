//
//  CreateBookingModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 30/04/21.
//

import Foundation

class CreateBookingModel {
    static let shared = CreateBookingModel()
    var createBookObj : createBookingObj?
}

struct createBookingObj: Codable {
    var status:Bool?
    var message:String?
    var payment: paymentUser?
    var singer_booking_id:IDIng?
    var is_cod:Int?
    var total_amount:String?
    var success_message:String?
    var error_message:String?
}


struct paymentUser: Codable {
    var status:Bool?
    var message:String?
    var payment_link:String?
    var singer_booking_id:IDIng?
}

struct createBookingObjOld: Codable {
    var status:Bool?
    var message:String?
    var payment: paymentUserOld?
    var singer_booking_id:IDIng?
    var is_cod:Int?
    var total_amount:String?
    var success_message:String?
    var error_message:String?
}


struct paymentUserOld: Codable {
    var status:Bool?
    var message:String?
    var payment_link:String?
    var singer_booking_id:IDIng?
}


enum IDIng: Codable {
    case integer(Int)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(IDIng.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ID"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}
