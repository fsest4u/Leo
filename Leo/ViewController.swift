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
    
    var locationOverlay = NMFLocationOverlay()
    var pathOverlay = NMFPath()
    
    var arrNMGLatLng: [NMGLatLng] = []
    
    var curLatitude: Double = DEFAULT_LATITUDE
    var curLongitude: Double = DEFAULT_LOGITUDE
    
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
        locationOverlay = naverMapView.mapView.locationOverlay

        naverMapView.mapView.minZoomLevel = ZOOM_LEVEL_MIN
        naverMapView.mapView.maxZoomLevel = ZOOM_LEVEL_MAX
        
    }

}

extension ViewController: NMFMapViewOptionDelegate {
    
    func mapViewOptionChanged(_ mapView: NMFMapView) {
        
        print("mapViewOptionChanged - mapView \(mapView)")
        let position = NMFCameraPosition(NMGLatLng(lat: curLatitude, lng: curLongitude), zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))

    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("status: \(status.rawValue)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let value: CLLocationCoordinate2D = manager.location!.coordinate
        print("value = \(value.latitude) \(value.longitude)")
        curLatitude = value.latitude
        curLongitude = value.longitude
        
        let curNMGLatLng = NMGLatLng(lat: curLatitude, lng: curLongitude)
        locationOverlay.location = curNMGLatLng
        if appendPathInfo(curNMGLatLng: curNMGLatLng) {
            print("Update Path Info ... ")
            viewPathInfo()

            let position = NMFCameraPosition(curNMGLatLng, zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
            naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))
            
        }
    }
    
    func appendPathInfo(curNMGLatLng: NMGLatLng) -> Bool {
        let lastNMGLatLng = getLastNMGLatLng()
        let distance = curNMGLatLng.distance(to: lastNMGLatLng)
        if distance > GAP_DISTANCE {
            print("distance : \(distance)")
            arrNMGLatLng.append(curNMGLatLng)
            return true
        }
        else {
            return false
        }
    }
    
    func viewPathInfo() {
        
        pathOverlay.color = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        pathOverlay.path = NMGLineString(points: arrNMGLatLng)
        pathOverlay.mapView = naverMapView.mapView
        
    }
    
    func removePathInfo() {
        
        pathOverlay.mapView = nil
    }
    
    func getLastNMGLatLng() -> NMGLatLng {
        
        var count = arrNMGLatLng.count
        // 최초 입력
        if count <= 0 {
            let curNMGLatLng = NMGLatLng(lat: curLatitude, lng: curLongitude)
            arrNMGLatLng.append(curNMGLatLng)
        }
        count = arrNMGLatLng.count
        
        return arrNMGLatLng[count - 1]
        
    }
}
