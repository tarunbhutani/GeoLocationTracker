//
//  AddNewGeoLocationViewController.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 15/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxCocoa
import RxSwift
import Toast_Swift
import RealmSwift

class AddNewGeoLocationViewController: UIViewController {
    // MARK: properties
    
    lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    var annotation = MKPointAnnotation()
    
    let distance: CLLocationDistance = 650
    let pitch: CGFloat = 30
    let heading = 90.0
    let disposeBag = DisposeBag()
    
    var selectedLatitude:Double?
    var selectedLongitude:Double?
    
    //MARK: Outlets
    @IBOutlet var mapview: MKMapView!
    
    @IBOutlet var txt_wifi_ssid: UITextField!
    
    @IBOutlet var txt_radius: UITextField!
    
    @IBOutlet var txt_remark: UITextField!
    
    @IBOutlet var lbl_invalid_radius: UILabel!
    
    @IBOutlet var lbl_invalid_remark: UILabel!
    
    @IBOutlet var btn_save: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateData()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapviewTap(_:)))
        mapview.addGestureRecognizer(gestureRecognizer)
        mapview.showsUserLocation = true
        // Get user's connected wifi connection
        txt_wifi_ssid.text = Utilities.getCurrentConnectedWifiSSID() ?? ""
    }
    
    // MARK: Outlets Actions
    
    @IBAction func addGeoLocation(_ sender: UIBarButtonItem) {
        
        DispatchQueue.main.async {
            
            if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                self.showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
                return
            }
            
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                let message = "Please allow app to access the device location inorder to save geofence area"
                self.showAlert(withTitle:"Warning", message: message)
            }
            
            guard let latitude = self.selectedLatitude, let longitude  = self.selectedLongitude else {
                self.showAlert(withTitle:"Warning", message: "Please select the geo location")
                return
            }
            
            // Query using an NSPredicate
            let predicate = NSPredicate(format: "locationLatitude = %@ AND locationLongitude = %@", "\(latitude)", "\(longitude)")
            
            RealmService.instance.isObjectExist(GeoLocationModel.self, predicate: predicate){ [weak self] isExist, area in
                if !isExist {
                    self?.storeGeofenceArea(latitude: latitude, longitude: longitude)
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.showAlert(withTitle:"Warning", message: "Geo location already exist")
                }
            }

        }
        
    }
    
    /*
     * show user's current location on map
     */
    
    @IBAction func presentCurrentLocation(_ sender: UIButton) {
        
        self.selectedLatitude = appDelegate?.currentLatitude
        self.selectedLongitude = appDelegate?.currentLongitude
        
        mapview.zoomToUserLocation()
    }
    
    
    func storeGeofenceArea(latitude:Double, longitude:Double) {
        let identifier = NSUUID().uuidString
        let geopLocation =  GeoLocationModel(value: ["locationLatitude":"\(latitude)",
            "locationLongitude":"\(longitude)",
            "wifiSSID": txt_wifi_ssid.text ?? "",
            "radius": Int(txt_radius.text ?? "0") ?? 0,
            "remark":txt_remark.text ?? "",
            "identifier":identifier])
        
        RealmService.instance.addObject(geopLocation)
        
        /*
        * Start monitoring the geo fence area.
        */
        let fenceRegion = Utilities.region(with: geopLocation)
        appDelegate?.locationManager?.startMonitoring(for: fenceRegion)
        
    }
    
    
    
    @objc func handleMapviewTap(_ gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.location(in: mapview)
        let coordinate = mapview.convert(location,toCoordinateFrom: mapview)
        self.selectedLatitude = coordinate.latitude
        self.selectedLongitude = coordinate.longitude
        
        annotation.coordinate = coordinate
        mapview.addAnnotation(annotation)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        switch segue.destination {
        case let vc as LocationPickerViewController:
            vc.locationDelegate = self
        default:
            break
        }
    }
    
    
    //MARK: Validate Data
    
    func validateData() {
        let isRadiusValid:Observable<Bool> = txt_radius.rx.text.map{
            guard let radius = $0, radius.count > 0 else{return false}
            return ((Int(radius) ?? 0 <= 1000) && (Int(radius) ?? 0 >= 10))
        }
        let isRemarkValid:Observable<Bool> = txt_remark.rx.text.map{ $0?.count ?? 0 > 0}
        
        let everythingValid: Observable<Bool> = Observable.combineLatest(isRadiusValid, isRemarkValid) { $0 && $1}
        
        
        isRadiusValid.bind(to: lbl_invalid_radius.rx.isHidden).disposed(by: disposeBag)
        
        isRemarkValid.bind(to: lbl_invalid_remark.rx.isHidden).disposed(by: disposeBag)
     
        everythingValid.bind(to: btn_save.rx.isEnabled).disposed(by: disposeBag)
        
        lbl_invalid_radius.isHidden = true
        lbl_invalid_remark.isHidden = true
        
    }
    
}

extension AddNewGeoLocationViewController:LocationPickerDelegate{
    
    func searchedLocation(_ viewController: LocationPickerViewController, mapItem: MKMapItem) {
        viewController.navigationController?.popViewController(animated: true)
        self.selectedLatitude = mapItem.placemark.coordinate.latitude
        self.selectedLongitude = mapItem.placemark.coordinate.longitude
        
        let coordinate = mapItem.placemark.coordinate
        self.annotation.coordinate = coordinate
        self.mapview.addAnnotation(self.annotation)
        
        let camera = MKMapCamera(lookingAtCenter: coordinate,
                                 fromDistance: self.distance,
                                 pitch: self.pitch,
                                 heading: self.heading)
        self.mapview.setCamera(camera, animated: true)
    }
    
}

