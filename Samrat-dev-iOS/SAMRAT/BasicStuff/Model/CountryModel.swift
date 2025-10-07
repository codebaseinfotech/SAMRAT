//
//  CountryModel.swift
//  SAMRAT
//
//  Created by Ajay Veer on 10/08/22.
//

import Foundation


// MARK: - CountriesResObj
struct CountriesResObj: Codable {
    var status: Bool?
    var message: String?
    var data: [CountriesData]?
}

// MARK: - Datum
struct CountriesData: Codable {
    var id: Int?
    var flag : String?
    var country: String?
    var country_en: String?
    var country_ar: String?
    var code: String?
    var tax_type: Int?
    var tax_value: String?
    var currency_id: Int?
    var status: Int?
    var created_at: String?
    var updated_at: String?
    var flag_url: String?
    var tax_type_format: String?
    var tax_value_format: String?
    var code_format: String?
    var currency: CountriesCurrency?
}

// MARK: - Currency
struct CountriesCurrency: Codable {
    var id: Int?
    var currency: String?
    var currency_symbol: String?
    var currency_code: String?
    var status: Int?
    var created_at : String?
    var updated_at: String?
    
    var currency_ar: String?
    var currency_symbol_ar: String?
    var currency_en: String?
    var currency_symbol_en: String?
}
