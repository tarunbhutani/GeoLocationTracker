//
//  FavoriteLocationsViewController.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 18/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteLocationsViewController: UIViewController {

    
    @IBOutlet var tableView: UITableView!
    
    lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    lazy var disposeBag = DisposeBag()
    lazy var viewModel = GeofenceAreasViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 56
        tableView.rowHeight = UITableView.automaticDimension
        
        bindDatasource()
        // fetch all user's favorite geofence areas
        viewModel.fetchGeoFenceAreaList()
        
    }
    
    private func bindDatasource(){
        viewModel.geofenceAreaDatasource.bind(to: tableView.rx.items(cellIdentifier: FavoriteLocationTableViewCell.identifier, cellType: FavoriteLocationTableViewCell.self)){row, data, cell in
            cell.geoLocation = data
            }.disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(GeoLocationModel.self))
            .bind{ [unowned self] indexPath, model in
                //print("message did need to sent to user jid ", model.contactJid)
                self.performSegue(withIdentifier: "presentUpdateGeoLocationVC", sender: model)
            }.disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let model = sender as? GeoLocationModel, let destinationVC = segue.destination as? AddNewGeoLocationViewController{
            destinationVC.geoFenceLocationObj = model
        }
    }
    
    

}
