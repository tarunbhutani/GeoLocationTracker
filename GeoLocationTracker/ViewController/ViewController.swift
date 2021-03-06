//
//  ViewController.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 15/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import UIKit
import MapKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    @IBOutlet var mapview: MKMapView!
    lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    lazy var geofenceAreasViewModel = GeofenceAreasViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapview.delegate = self
        mapview.showsUserLocation = true
        appDelegate?.locationManager?.requestAlwaysAuthorization()
        geofenceAreasViewModel.fetchGeoFenceAreaList()
        bindDatasource()
        
    }
    
    deinit {
        geofenceAreasViewModel.deinitNotification()
    }
    
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
    
    @IBAction func presentCurrentLocation(_ sender: UIButton) {
        
        mapview.zoomToUserLocation()
    }
    
    private func bindDatasource() {
        geofenceAreasViewModel.geofenceAreaDatasource.subscribe{ [weak self] geoLocationObj in
            // Remove all anotation...
            self?.mapview.removeAnnotations(self?.mapview.annotations ?? [])
            self?.mapview.removeOverlays(self?.mapview.overlays ?? [])
            
            if let geoLocatioinList = geoLocationObj.element {
                geoLocatioinList.forEach{ [weak self] obj in
                    self?.addAnotation(geoLocationObj: obj)
                    self?.addRadius(geoLocationObj: obj)
                }
            }
        }.disposed(by: disposeBag)
    }
    
    private func addAnotation(geoLocationObj : GeoLocationModel) {
        DispatchQueue.main.async { [weak self] in
//            let annotation =  MKPointAnnotation()
//
//            let CLLCoordType = CLLocationCoordinate2D(latitude: Double(geoLocationObj.locationLatitude) ?? 0.0, longitude:  Double(geoLocationObj.locationLongitude) ?? 0.0)
//            annotation.coordinate = CLLCoordType
//            annotation.title = geoLocationObj.remark
            
            self?.mapview.addAnnotation(geoLocationObj)
        }
    }
    
    private func addRadius(geoLocationObj : GeoLocationModel){
        
        DispatchQueue.main.async { [weak self ] in
            let CLLCoordType = CLLocationCoordinate2D(latitude: Double(geoLocationObj.locationLatitude) ?? 0.0, longitude:  Double(geoLocationObj.locationLongitude) ?? 0.0)
            let circle = MKCircle(center: CLLCoordType, radius: CLLocationDistance(geoLocationObj.radius))
                
            self?.mapview.addOverlay(circle)
        }
        
    }

}



extension ViewController:LocationPickerDelegate{
    
    func searchedLocation(_ viewController: LocationPickerViewController, mapItem: MKMapItem) {
        viewController.navigationController?.popViewController(animated: true)
        DispatchQueue.main.async { [weak self] in
            self?.mapview.zoomToUserLocation(coordinate: mapItem.placemark.coordinate)
        }
    }
    
}


extension ViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeoLocation"
        if annotation is GeoLocationModel {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let info = UIButton(type: .custom)
                info.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                info.setImage(UIImage(named: "info")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = info
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let geotification = view.annotation as? GeoLocationModel{
            
            let fenceRegion = Utilities.region(with: geotification)
            let isUnderRegion = fenceRegion.contains(CLLocationCoordinate2D(latitude: appDelegate?.currentLatitude ?? 0.0, longitude: appDelegate?.currentLongitude ?? 0.0))
            if isUnderRegion || (Utilities.getCurrentConnectedWifiSSID() ?? "" == geotification.wifiSSID ?? " "){
                self.showAlert(withTitle: nil, message: "You are inside of \(geotification.remark) region")
            }else{
                self.showAlert(withTitle: nil, message: "You are outside of \(geotification.remark) region")
            }
            
            
        }
        
    }
}
