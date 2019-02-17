//
//  LocalSearchOperation.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 15/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import MapKit

class LocalSearch: BaseOperation {
    
    public var matchingItems:[MKMapItem]?
    private let query:String
    
    init(query :String){
        self.query = query
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let response = response else {
                self?.matchingItems = []
                return
            }
            self?.matchingItems = response.mapItems
            self?.executing(false)
            self?.finish(true)
        }
        
        
        
        
    }
    
}
