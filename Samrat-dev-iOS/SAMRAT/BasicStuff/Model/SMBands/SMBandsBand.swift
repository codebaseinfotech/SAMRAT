//
//	SMBandsBand.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class SMBandsBand : NSObject, NSCoding{

	var createdAt : String!
	var id : Int!
	var price : String!
	var status : Int!
	var title : String!
	var titleAr : String!
	var updatedAt : String!


	/**
	 * Overiding init method
	 */
	init(fromDictionary dictionary: NSDictionary)
	{
		super.init()
		parseJSONData(fromDictionary: dictionary)
	}

	/**
	 * Overiding init method
	 */
	override init(){
	}

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	@objc func parseJSONData(fromDictionary dictionary: NSDictionary)
	{
		createdAt = dictionary["created_at"] as? String == nil ? "" : dictionary["created_at"] as? String
		id = dictionary["id"] as? Int == nil ? 0 : dictionary["id"] as? Int
		price = dictionary["price"] as? String == nil ? "" : dictionary["price"] as? String
		status = dictionary["status"] as? Int == nil ? 0 : dictionary["status"] as? Int
		title = dictionary["title"] as? String == nil ? "" : dictionary["title"] as? String
		titleAr = dictionary["title_ar"] as? String == nil ? "" : dictionary["title_ar"] as? String
		updatedAt = dictionary["updated_at"] as? String == nil ? "" : dictionary["updated_at"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if createdAt != nil{
			dictionary["created_at"] = createdAt
		}
		if id != nil{
			dictionary["id"] = id
		}
		if price != nil{
			dictionary["price"] = price
		}
		if status != nil{
			dictionary["status"] = status
		}
		if title != nil{
			dictionary["title"] = title
		}
		if titleAr != nil{
			dictionary["title_ar"] = titleAr
		}
		if updatedAt != nil{
			dictionary["updated_at"] = updatedAt
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         createdAt = aDecoder.decodeObject(forKey: "created_at") as? String
         id = aDecoder.decodeObject(forKey: "id") as? Int
         price = aDecoder.decodeObject(forKey: "price") as? String
         status = aDecoder.decodeObject(forKey: "status") as? Int
         title = aDecoder.decodeObject(forKey: "title") as? String
         titleAr = aDecoder.decodeObject(forKey: "title_ar") as? String
         updatedAt = aDecoder.decodeObject(forKey: "updated_at") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder) 
	{
		if createdAt != nil{
			aCoder.encode(createdAt, forKey: "created_at")
		}
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if price != nil{
			aCoder.encode(price, forKey: "price")
		}
		if status != nil{
			aCoder.encode(status, forKey: "status")
		}
		if title != nil{
			aCoder.encode(title, forKey: "title")
		}
		if titleAr != nil{
			aCoder.encode(titleAr, forKey: "title_ar")
		}
		if updatedAt != nil{
			aCoder.encode(updatedAt, forKey: "updated_at")
		}

	}

}