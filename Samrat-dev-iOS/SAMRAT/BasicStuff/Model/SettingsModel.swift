//
//  SettingsModel.swift
//  SAMRAT
//
//  Created by Keyur Baravaliya on 12/05/21.
//

import Foundation


class SettingsModel {
    static let shared = SettingsModel()
    var settingResponseObj:SettingResponse?
}

struct SettingResponse:Codable {
    var status:Bool?
    var message:String?
    var settings:SettingsResponseData?
    var countries: [CountriesData]?
}


struct SettingsResponseData:Codable {
    var minimum_booking_payment:String?
    var max_singer_selection:String?
    var contact_number:String?
    var location:String?
    var email:String?
    var facebook:String?
    var instagram:String?
    var twitter:String?
    var youtube:String?
    var whatsapp_number:String?
    var snapchat:String?
    var is_cod_enable:String?
    var is_online_payment_enable:String?
    var enable_first_time_open_message:String?
    var enable_first_time_open_message_text:String?
    var multiple_singer_booking:String?
    var map_latitude:String?
    var map_longitude:String?
    var is_social_login_show:String?
    var tax_charges: String?
    var multiple_booking_on_same_date: String?
    var is_maintainance_mode: String?
    var enable_maintenance_mode: String?
    var musician_one_singer_price: String?
    var musician_two_singer_price: String?
    var musician_three_singer_price: String?
    var musician_four_singer_price: String?
    var tap_secret_live_ios_kwt: String?
    var tap_secret_test_ios_kwt: String?
    var tap_secret_live_android_kwt: String?
    var tap_secret_test_android_kwt: String?
    var tap_secret_test_ios_ksa: String?
    var tap_secret_test_android_ksa: String?
    var tap_secret_live_ios_ksa: String?

}


