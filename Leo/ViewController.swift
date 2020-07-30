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
    
    // control menu
    var isVisibleMenu: Bool = false
    @IBOutlet weak var viewTopMenu: UIView!
    
    @IBOutlet weak var viewBottomMenu: UIView!
    @IBOutlet weak var viewLeftBtn: UIView! {
        didSet {
            viewLeftBtn.layer.masksToBounds = true
            viewLeftBtn.layer.borderWidth = 0.5
            viewLeftBtn.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.2705882353, blue: 0.6196078431, alpha: 1)
            viewLeftBtn.layer.cornerRadius = viewLeftBtn.frame.width / 2
        }
    }
    @IBOutlet weak var viewRightBtn: UIView!  {
        didSet {
            viewRightBtn.layer.masksToBounds = true
            viewRightBtn.layer.borderWidth = 0.5
            viewRightBtn.layer.borderColor = #colorLiteral(red: 0.1254901961, green: 0.2705882353, blue: 0.6196078431, alpha: 1)
            viewRightBtn.layer.cornerRadius = viewRightBtn.frame.width / 2
        }
    }
    @IBOutlet weak var btnLeft: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initLocation()
        initMapOption()
        addTapGesture()

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
    
    // MARK: - Gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addTapGesture() {
        
        let tapMapView = UITapGestureRecognizer(target: self, action: #selector(showControlMenu))
        naverMapView.mapView.addGestureRecognizer(tapMapView)
    }
    
    func remodeGesture() {
        
        if let gestureRecognizers = naverMapView.mapView.gestureRecognizers {
            for gesture in gestureRecognizers {
//                print("gesture name : \(gesture.name)")
                if let recognizer = gesture as? UITapGestureRecognizer {
                    naverMapView.mapView.removeGestureRecognizer(recognizer)
                    
                }
            }
        }
    }
    
    @objc func showControlMenu() {
        
        print("## showControlMenu... isVisibleMenu : \(isVisibleMenu)")
        isVisibleMenu = !isVisibleMenu
        let aniAlpha: CGFloat = 0.6
        let aniNonAlpha: CGFloat = 0.0
        let aniTime = 0.3
        
        if isVisibleMenu {
            
            self.viewTopMenu.alpha = aniNonAlpha
            self.viewTopMenu.isHidden = false
            UIView.animate(withDuration: aniTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.viewTopMenu.alpha = aniAlpha
            })
            
            self.viewBottomMenu.alpha = aniNonAlpha
            self.viewBottomMenu.isHidden = false
            UIView.animate(withDuration: aniTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.viewBottomMenu.alpha = aniAlpha

            })
            
            
        }
        else {
            
            self.viewTopMenu.alpha = aniAlpha
            UIView.animate(withDuration: aniTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.viewTopMenu.alpha = aniNonAlpha
            },
                           completion: { (value: Bool) in
                            self.viewTopMenu.isHidden = true
            })
            
            self.viewBottomMenu.alpha = aniAlpha
            UIView.animate(withDuration: aniTime, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                self.viewBottomMenu.alpha = aniNonAlpha
            },
                           completion: { (value: Bool) in
                            self.viewBottomMenu.isHidden = true
            })
            
            
        }
        
    }
    
    // MARK: - Control Menu
    @IBAction func onClick_BtnLeft(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        print("left - \(sender.isSelected)")
        if sender.isSelected {
            playStatus = .stop
            btnRight.isSelected = false
        }
        else {
            playStatus = .share
        }
    }
    
    @IBAction func onClick_BtnRight(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        print("right - \(sender.isSelected)")
        if sender.isSelected {
            playStatus = .play
            btnLeft.isSelected = false
        }
        else {
            playStatus = .pause
        }
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
        
        print("locationManager...")
        let value: CLLocationCoordinate2D = manager.location!.coordinate
        print("value = \(value.latitude) \(value.longitude)")
        curLatitude = value.latitude
        curLongitude = value.longitude
        
        let curNMGLatLng = NMGLatLng(lat: curLatitude, lng: curLongitude)
        locationOverlay.location = curNMGLatLng
        
        let position = NMFCameraPosition(curNMGLatLng, zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))
        
        if .play != playStatus {
            return
        }
        
//        print("manager.location +++++++++++++++++++++++")
//        print("altitude : \(manager.location?.altitude)")
//        print("coordinate : \(manager.location?.coordinate)")
//        print("course : \(manager.location?.course)")
////        print("altitude : \(manager.location?.courseAccuracy)")
//        print("floor : \(manager.location?.floor)")
//        print("horizontalAccuracy : \(manager.location?.horizontalAccuracy)")
//        print("speed : \(manager.location?.speed)")
//        print("speedAccuracy : \(manager.location?.speedAccuracy)")
//        print("timestamp : \(manager.location?.timestamp)")
//        print("verticalAccuracy : \(manager.location?.verticalAccuracy)")
//
//        print("locations +++++++++++++++++++++++")
//        print("locations : \(locations)")
//        print("+++++++++++++++++++++++")

        if appendPathInfo(curNMGLatLng: curNMGLatLng) {
            print("Update Path Info ... ")
            viewPathInfo()

        }
    }
    
    func appendPathInfo(curNMGLatLng: NMGLatLng) -> Bool {
        let lastNMGLatLng = getLastNMGLatLng()
        let distance = curNMGLatLng.distance(to: lastNMGLatLng)
        print("distance : \(distance)")
        if distance > GAP_DISTANCE {
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
