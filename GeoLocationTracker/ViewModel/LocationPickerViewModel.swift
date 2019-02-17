//
//  LocationPickerViewModel.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 15/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import MapKit

class LocationPickerViewModel {
    
    private let locationBehaviourRelay = BehaviorRelay<[MKMapItem]>(value: [])
    
    private let operationQueue = OperationQueue()
    
    var locationObserver: Observable<[MKMapItem]> {
        return locationBehaviourRelay.asObservable()
    }
    
    func fetchLocation(query : String) {
        let locationSearchOperation = LocalSearch(query: query)
        locationSearchOperation.completionBlock = { [weak self] in
            
            self?.locationBehaviourRelay.accept(locationSearchOperation.matchingItems ?? [])
        }
        
        operationQueue.addOperations([locationSearchOperation], waitUntilFinished: false)
        
    }
    
}
