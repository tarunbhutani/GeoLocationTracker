//
//  Utilities.swift
//  GeoLocationTracker
//
//  Created by InSynchro M SDN BHD on 17/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import MapKit

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
}

struct Utilities {
    static func getCurrentConnectedWifiSSID() -> String? {
        return NetworkList.getNetworkInfos().first?.ssid
    }
    
    static func region(with geoLocationObj: GeoLocationModel) -> CLCircularRegion {
        let CLLCoord = CLLocationCoordinate2D(latitude: Double(geoLocationObj.locationLatitude) ?? 0.0, longitude:  Double(geoLocationObj.locationLongitude) ?? 0.0)
        
        let region = CLCircularRegion(center: CLLCoord, radius: CLLocationDistance(geoLocationObj.radius), identifier: geoLocationObj.identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        return region
    }
    
}

extension MKMapView {
    func zoomToUserLocation() {
        print("userLocation.location ", userLocation.location)
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        setRegion(region, animated: true)
    }
    
    func zoomToUserLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        setRegion(region, animated: true)
    }
}
