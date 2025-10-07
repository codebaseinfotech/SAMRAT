//
//  SingerModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 29/04/21.
//

import Foundation

//MARK:- Singer Models

class SingerModel {
    static var shared = SingerModel()
    var singersObj : singersObj?
}

// MARK: - SingersObj
struct singersObj: Codable {
    var status: Bool?
    var message: String?
    var data: [singersData]?
}

// MARK: - Datum
struct singersData: Codable {
    var id: Int?
    var category_id: String?
    var display_order: Int?
    var name, description: String?
    var image, detail_image: String?
    var audio: String?
    var price: String?
    var duration: String?
    var minimum_booking_value_type, minimum_booking_value, commission_type, commission_value: Int?
    var is_service, multiple_service_booking, default_band_price, single_price: Int?
    var two_price, three_price, four_price, status: Int?
    var is_deleted: Int?
    var created_at, updated_at: String?
    var singer_id, abc: Int?
    var category_name: String?
    var category_description: String?
    var category_image: String?
    var country: DatumCountry?
    var musicians: [musiciansData]?
    var services: [servicesData]?
    var singer_categories: [singer_Categories]?
    var optional_services: [OptionalService]?
}

// MARK: - DatumCountry
struct DatumCountry: Codable {
    var id, singer_id, country_id: Int?
    var musician_id: String?
    var minimum_booking_value_type, minimum_booking_value, commission_type, commission_value: Int?
    var default_band_price, single_price, two_price, three_price: Int?
    var four_price: Int?
    var display_order: Int?
    var status: Int?
    var created_at, updated_at: String?
}

// MARK: - Musician
struct musiciansData: Codable {
    var id: Int?
    var display_order: Int?
    var musician_category_id: Int?
    var name, description: String?
    var image: String?
    var audio: String?
    var single_singer_price, two_singer_price, three_singer_price, four_singer_price: Int?
    var status, is_deleted: Int?
    var created_at, updated_at: String?
    var category_name: String?
    var category_name_ar: String?
    var country: MusicianCountry?
}

// MARK: - MusicianCountry
struct MusicianCountry: Codable {
    var id, musician_id, country_id, single_singer_price: Int?
    var two_singer_price, three_singer_price, four_singer_price: Int?
    var display_order: Int?
    var status: Int?
    var created_at, updated_at: String?
}

// MARK: - OptionalService
struct OptionalService: Codable {
    var id: Int?
    var title, description: String?
    var price, singer_id, status: Int?
    var created_at, updated_at: String?
}

// MARK: - Service
struct servicesData: Codable {
    var id: Int?
    var title: String?
    var image: String?
    var description: String?
    var display_order, charge_type, price: Int?
    var min_hr, max_hr: String?
    var additional_hour_price: Int?
    var down_payment_type: Int?
    var down_payment_value: String?
    var commission_type, commission_value: Int?
    var duration: String?
    var country_id, status, commission_amount, total_service_amount: Int?
    var max_hr_text: String?
    var max_hr_array: [MaxHrArray]?
    var min_hr_text: String?
    var charge_type_text: String?
}

// MARK: - MaxHrArray
struct MaxHrArray: Codable {
    var title, value: String?
}

// MARK: - SingerCategory
struct singer_Categories: Codable {
    var id: Int?
    var parent_id, display_order: Int?
    var name: String?
    var name_ar: String?
    var description, description_ar: String?
    var allow_multiple_singer_bookings, status: Int?
    var country_ids: String?
    var is_deleted: Int?
    var created_at: String?
    var updated_at: String?
    var laravel_through_key: Int?
    var allow_multiple_singer_bookings_text: String?
    var country_names: String?
    
}

struct SingerJsonModel: Codable {
    var singer_id: String?
    var musician_ids: String?
    var is_default_musicians: Int?
    var device_type: String?
    var is_default_services: Int?
    var booking_type: String?
    var singer_services: [singer_Services]?
    var service_ids: String?
}

struct singer_Services: Codable {
    var service_id:String?
    var hrs:String?
    var title:String?
}
