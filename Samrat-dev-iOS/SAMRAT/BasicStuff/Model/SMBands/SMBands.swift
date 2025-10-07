//
//	SMBands.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class SMBands : NSObject, NSCoding{

	var bands : [SMBandsBand]!
	var message : String!
	var status : Bool!


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
		bands = [SMBandsBand]()
		if let bandsArray = dictionary["bands"] as? [NSDictionary]{
			for dic in bandsArray{
				let value = SMBandsBand(fromDictionary: dic)
				bands.append(value)
			}
		}
		message = dictionary["message"] as? String == nil ? "" : dictionary["message"] as? String
		status = dictionary["status"] as? Bool == nil ? false : dictionary["status"] as? Bool
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		let dictionary = NSMutableDictionary()
		if bands != nil{
			var dictionaryElements = [NSDictionary]()
			for bandsElement in bands {
				dictionaryElements.append(bandsElement.toDictionary())
			}
			dictionary["bands"] = dictionaryElements
		}
		if message != nil{
			dictionary["message"] = message
		}
		if status != nil{
			dictionary["status"] = status
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         bands = aDecoder.decodeObject(forKey: "bands") as? [SMBandsBand]
         message = aDecoder.decodeObject(forKey: "message") as? String
         status = aDecoder.decodeObject(forKey: "status") as? Bool

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    public func encode(with aCoder: NSCoder) 
	{
		if bands != nil{
			aCoder.encode(bands, forKey: "bands")
		}
		if message != nil{
			aCoder.encode(message, forKey: "message")
		}
		if status != nil{
			aCoder.encode(status, forKey: "status")
		}

	}

}