//
//  GeoLocationModel.swift
//  GeoLocationTracker
//
//  Created by InSynchro M SDN BHD on 16/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

@objcMembers class GeoLocationModel: Object {
    
    
    dynamic var locationLatitude:String = "0.0"
    dynamic var locationLongitude:String = "0.0"
    dynamic var wifiSSID: String? = nil
    dynamic var radius = 0
    dynamic var remark:String = ""
    dynamic var identifier: String = ""
    
    override var description: String{
        return "Latitude: \(locationLatitude), Longitude: \(locationLongitude), wifiSSID: \(wifiSSID ?? ""), radius: \(radius), identifier: \(identifier)"
    }
    
    convenience init(locationLatitude:String, locationLongitude:String, wifiSSID:String?, radius:Int, remark:String, identifier :String){
        self.init()
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.wifiSSID = wifiSSID
        self.radius = radius
        self.remark = remark
        self.identifier = identifier
    }
    
}
