//
//  ViewController.swift
//  Leo
//
//  Created by spdevapp on 2020/07/28.
//  Copyright © 2020 hyeon. All rights reserved.
//

import UIKit
import NMapsMap
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var naverMapView: NMFNaverMapView!

    var locationManager = CLLocationManager()
    
    let ZOOM_LEVEL_DEFAULT: Double = 14
    let ZOOM_LEVEL_MIN: Double = 8
    let ZOOM_LEVEL_MAX: Double = 16
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initLocation()
        initMapOption()
    }
    
    func initLocation() {
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

    }
    func initMapOption() {
        
        naverMapView.mapView.addOptionDelegate(delegate: self)

        naverMapView.mapView.mapType = .terrain
        naverMapView.mapView.setLayerGroup(NMF_LAYER_GROUP_BICYCLE, isEnabled: true)
        naverMapView.mapView.isNightModeEnabled = true
        
//        naverMapView.showCompass = true
//        naverMapView.showScaleBar = true
//        naverMapView.showZoomControls = true
//        naverMapView.showLocationButton = true
        naverMapView.mapView.positionMode = .compass

        naverMapView.mapView.minZoomLevel = ZOOM_LEVEL_MIN
        naverMapView.mapView.maxZoomLevel = ZOOM_LEVEL_MAX
        
    }


}

extension ViewController: NMFMapViewOptionDelegate {
    
    func mapViewOptionChanged(_ mapView: NMFMapView) {
        
        print("mapViewOptionChanged")
        

    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("status: \(status.rawValue)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let value: CLLocationCoordinate2D = manager.location!.coordinate
        print("value = \(value.latitude) \(value.longitude)")
        
        let position = NMFCameraPosition(NMGLatLng(lat: value.latitude, lng: value.longitude), zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))
    }
}
