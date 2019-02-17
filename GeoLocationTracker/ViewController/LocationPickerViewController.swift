//
//  LocationPickerViewController.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 15/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa

protocol LocationPickerDelegate {
    func searchedLocation(_ viewController: LocationPickerViewController , mapItem : MKMapItem)
}

class LocationPickerViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private var searchBar: UISearchBar!
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: instance property
    var locationDelegate : LocationPickerDelegate?
    let disposeBag = DisposeBag()
    
    var locationSearchViewModel:LocationPickerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
        bindData()
     
        
    }

    func initializeViewModel() {
        locationSearchViewModel = LocationPickerViewModel()
    }
    func bindData() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        searchBar.rx.text
            .orEmpty
            .debounce(0.2, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .subscribe(onNext: { [unowned self] query in // Here we will be notified of every new value
                
                self.locationSearchViewModel?.fetchLocation(query: query)
            }).disposed(by: disposeBag)
        
        
        locationSearchViewModel?.locationObserver.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)){row, data, cell in
            cell.textLabel?.text = "\(data.placemark)"
            }.disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(MKMapItem.self))
            .bind{ [unowned self] indexPath, model in
                self.locationDelegate?.searchedLocation(self, mapItem: model)
            }.disposed(by: disposeBag)
        
    }
}

