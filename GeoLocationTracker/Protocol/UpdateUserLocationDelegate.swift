//
//  UpdateUserLocationDelegate.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 16/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import MapKit

protocol UpdateUserLocationDelegate:class{
    func didUpdateLocations(location : CLLocation)
}
