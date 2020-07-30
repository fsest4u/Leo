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

// Like CLLocation
//struct LocationInfo {
//
//    var altitude: Double
//    var latitude: Double
//    var longitude: Double
//    var speed: Double
//    var timestamp: Date //??
//
//    init() {
//        altitude = 0
//        latitude = DEFAULT_LATITUDE
//        longitude = DEFAULT_LOGITUDE
//        speed = 0
//        timestamp = Date()
//    }
//}

class ViewController: UIViewController {

    @IBOutlet weak var naverMapView: NMFNaverMapView!

    var locationManager = CLLocationManager()
    
    var locationOverlay = NMFLocationOverlay()  // 사용자의 현재 위치
    var pathOverlay = NMFPath()                 // 사용자의 움직인 경로
    
    var arrNMGLatLng: [NMGLatLng] = []
    var arrLocationInfo: [CLLocation] = []
    
    var curLocationInfo = CLLocation()

//    var curLatitude: Double = DEFAULT_LATITUDE
//    var curLongitude: Double = DEFAULT_LOGITUDE
    
    // control menu - top
    var isVisibleMenu: Bool = false
    @IBOutlet weak var viewTopMenu: UIView!
    @IBOutlet weak var labelCurVelocity: UILabel!
    @IBOutlet weak var labelAverageVelocity: UILabel!
    @IBOutlet weak var labelBestVelocity: UILabel!
    @IBOutlet weak var labelElapsedTime: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    
    var totDistance: Double = 0
    
    // control menu - bottom
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
    
    func displayTopMenu(locationInfo: CLLocation) {
        
        // current speed
        var speed = locationInfo.speed
        if speed <= 0 {
            speed = 0
        }
        labelCurVelocity.text = String(speed)
        labelAverageVelocity.text = getAverageSpeed()
        labelBestVelocity.text = getBestSpeed()
        
        labelDistance.text = getDistance(locationInfo: locationInfo)
        
    }
    
    // best speed
    func getBestSpeed() -> String {
        let count = arrLocationInfo.count
        if count <= 0 {
            return "0.0"
        }
        var maxSpeed = arrLocationInfo.map { $0.speed }.max()!
        if maxSpeed < 0 {
            maxSpeed = 0
        }
        let strSpeed = String(format: "%.2f", maxSpeed)
        print("getBestSpeed : \(strSpeed)")
        return strSpeed
    }
    
    func getAverageSpeed() -> String {
        let count = arrLocationInfo.count
        if count <= 0 {
            return "0.0"
        }
        var totSpeed = 0.0
        for i in 0...(count - 1) {
            var speed = arrLocationInfo[i].speed
            if speed < 0 {
                speed = 0
            }
            totSpeed = totSpeed + speed
        }
        
        let averSpeed = totSpeed / Double(count)
        let strSpeed = String(format: "%.2f", averSpeed)
        print("getAverageSpeed : \(strSpeed)")
        return strSpeed
    }
    
    // total distance
    func getDistance(locationInfo: CLLocation) -> String {
        
        if arrNMGLatLng.count <= 0 {
            return "0.0"
        }
        let latlng1 = arrNMGLatLng.last!
        let latlng2 = getLatLng(locationInfo: locationInfo)
        
        let distance = latlng2.distance(to: latlng1)
        totDistance = totDistance + distance
//        totDistance = Double(arrLocationInfo.distance(from: 0, to: arrLocationInfo.count - 1))
        let strDistance = String(format: "%.2f", totDistance / 1000.0)
        print("getDistance : \(strDistance)")
        
        return strDistance
        
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
        let position = NMFCameraPosition(getLatLng(locationInfo: curLocationInfo), zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))

    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("status: \(status.rawValue)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        print("manager.location +++++++++++++++++++++++")
        guard let managerLocation = manager.location else {
            return
        }
        
        print("altitude : \(managerLocation.altitude)")
        print("latitude : \(managerLocation.coordinate.latitude)")
        print("longitude : \(managerLocation.coordinate.longitude)")
        print("speed : \(managerLocation.speed)")
        print("timestamp : \(managerLocation.timestamp)")
        
//        print("course : \(managerLocation.course)")
//        print("altitude : \(manager.location?.courseAccuracy)")
//        print("floor : \(managerLocation.floor)")
//        print("verticalAccuracy : \(managerLocation.verticalAccuracy)")
//        print("horizontalAccuracy : \(managerLocation.horizontalAccuracy)")
//        print("speedAccuracy : \(managerLocation.speedAccuracy)")
        
//        curLocationInfo.altitude = managerLocation.altitude
//        curLocationInfo.latitude = managerLocation.coordinate.latitude
//        curLocationInfo.longitude = managerLocation.coordinate.longitude
//        curLocationInfo.speed = managerLocation.speed
//        curLocationInfo.timestamp = managerLocation.timestamp
        curLocationInfo = managerLocation
        
        let curLatLng = getLatLng(locationInfo: curLocationInfo)
        locationOverlay.location = curLatLng

        let position = NMFCameraPosition(curLatLng, zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))
        
        if .play != playStatus {
            return
        }
    
        displayTopMenu(locationInfo: curLocationInfo)

        if appendLocationInfo(locationInfo: curLocationInfo) {
            print("Update Path Info ... ")
            viewPathInfo()

        }
    }
    
    func appendLocationInfo(locationInfo: CLLocation) -> Bool {
//        let index = getIndexLastLocationInfo()
//        let lastLatLng = arrNMGLatLng[index]
//        let distance = curNMGLatLng.distance(to: lastLatLng)
//        print("distance : \(distance)")
//        if distance > GAP_DISTANCE {
        // temp_code
        if true {//locationInfo.speed > 0 {
            let curLatLng = getLatLng(locationInfo: locationInfo)
            arrNMGLatLng.append(curLatLng)
            arrLocationInfo.append(locationInfo)
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
    
    func getLatLng(locationInfo: CLLocation) -> NMGLatLng {
        
        return NMGLatLng(lat: locationInfo.coordinate.latitude, lng: locationInfo.coordinate.longitude)
        
    }
    
    func getIndexLastLocationInfo() -> Int {
        
        var count = arrLocationInfo.count
        // 최초 입력
        if count <= 0 {
            let curLatLng = getLatLng(locationInfo: curLocationInfo)
            arrNMGLatLng.append(curLatLng)
            arrLocationInfo.append(curLocationInfo)
        }
        count = arrLocationInfo.count
        
//        return arrLocationInfo[count - 1]
        return count - 1
    }
}
