//
//  GeofenceAreasViewModel.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 16/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class GeofenceAreasViewModel {
    
    // Mark: Instance property
    private let privateGeofenceAreaDatasource = BehaviorRelay<[GeoLocationModel]>(value: [])
    
    var geofenceAreaDatasource:Observable<[GeoLocationModel]>{
        return privateGeofenceAreaDatasource.asObservable()
    }
    
    private let disposeBag = DisposeBag()
    
    var notificationToken: NotificationToken? = nil
    
    // MARK: Instance methods
    func fetchGeoFenceAreaList(){
        getObserver().subscribe(
            onNext: { [weak self] list in
                self?.privateGeofenceAreaDatasource.accept(list)
            },
            onError: { error in
                print(#function, " line ", #line, " Error ", error)
        }).disposed(by: disposeBag)
        
    }
    
    private func getObserver() -> Observable<[GeoLocationModel]>{
        
        return Observable.create{ [weak self] observer -> Disposable in
            
            let objects = RealmService.instance.getAllObjects(GeoLocationModel.self)
            
            self?.notificationToken = objects.observe({ change in
                switch change {
                case .initial(let list ):
                    observer.onNext(Array(list))
                    
                case .update(let list ,  _ , _ , _ ):
                    observer.onNext(Array(list))
                    
                case .error(let error):
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        }
        
    }
    
    
    func deinitNotification() {
        notificationToken?.invalidate()
    }
    

    
}
