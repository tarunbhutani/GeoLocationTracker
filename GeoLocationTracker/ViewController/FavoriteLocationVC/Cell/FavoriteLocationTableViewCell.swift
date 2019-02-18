//
//  FavoriteLocationTableViewCell.swift
//  GeoLocationTracker
//
//  Created by Tarun Bhutani on 18/02/2019.
//  Copyright © 2019 Tarun Bhutani. All rights reserved.
//

import UIKit
import MapKit

class FavoriteLocationTableViewCell: UITableViewCell {

    static let identifier = "FavoriteLocationTableViewCell"
    
    @IBOutlet var lbl_location_remark: UILabel!
    
    @IBOutlet var lbl_locatoin_status: UILabel!
    
    lazy var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var geoLocation:GeoLocationModel?{
        didSet{
            bindDataCell()
        }
    }
    
    func bindDataCell() {
        guard let location =  geoLocation else { return }
        lbl_location_remark.text = location.remark
        
        let fenceRegion = Utilities.region(with: location)
        let isUnderRegion = fenceRegion.contains(CLLocationCoordinate2D(latitude: appDelegate?.currentLatitude ?? 0.0, longitude: appDelegate?.currentLongitude ?? 0.0))
        if isUnderRegion || (Utilities.getCurrentConnectedWifiSSID() ?? "" == location.wifiSSID ?? " "){
            lbl_locatoin_status.text = "You are inside of \(location.remark) region"
        }else{
            lbl_locatoin_status.text = "You are outside of \(location.remark) region"
        }
        
        
    }

}
