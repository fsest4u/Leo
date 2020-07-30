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
    
    // control menu - top
    var isVisibleMenu: Bool = false
    @IBOutlet weak var viewTopMenu: UIView!
    @IBOutlet weak var labelCurVelocity: UILabel!
    @IBOutlet weak var labelAverageVelocity: UILabel!
    @IBOutlet weak var labelBestVelocity: UILabel!
    @IBOutlet weak var labelElapsedTime: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    
    
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
    
    @IBOutlet weak var imageViewLeft: UIImageView!
    @IBOutlet weak var imageViewRight: UIImageView!
        
    var locationManager = CLLocationManager()
    var locationOverlay = NMFLocationOverlay()  // 사용자의 현재 위치
    var pathOverlay = NMFPath()                 // 사용자의 움직인 경로
    var locationInfo = LocationInfo()
    
    //MARK: Timer Variable
    var startTime = TimeInterval()
    var timer = Timer()
    var isTiming = Bool()
    var isPaused = Bool()
    var pausedTime: NSDate?   //track the time current pause started
    var pausedIntervals = [TimeInterval]()   //track previous pauses
    
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
    
    // MARK: - Control Menu
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
    
    // MARK: - Top Menu
    func displayTopMenu(location: CLLocation) {
        
        labelCurVelocity.text = locationInfo.getCurrentSpeed(srcSpeed: location.speed)
        labelAverageVelocity.text = locationInfo.getAverageSpeed()
        labelBestVelocity.text = locationInfo.getBestSpeed()
        labelDistance.text = locationInfo.getDistance(location: location)
        
    }
    
    // MARK: - Bottom Menu
    @IBAction func onClick_BtnLeft(_ sender: UIButton) {
        
        sender.isSelected.toggle()
//        print("left - \(sender.isSelected)")
        if sender.isSelected {
            playStatus = .stop
            doStatus()
        }
        // temp_code, dylee
//        else {
//            playStatus = .share
//            doStatus()
//        }
    }
    
    @IBAction func onClick_BtnRight(_ sender: UIButton) {
        
        sender.isSelected.toggle()
//        print("right - \(sender.isSelected)")
        if sender.isSelected {
            playStatus = .play
            doStatus()
        }
        else {
            playStatus = .pause
            doStatus()
        }
    }
    
    func doStatus() {
        
        switch playStatus {
        case .stop:
            print("stop ############")
//            imageViewLeft.image = UIImage(named: "open")
            
            btnRight.isSelected = false
            imageViewRight.image = UIImage(named: "play")
            
            labelCurVelocity.text = "0.0"
            labelAverageVelocity.text = "0.0"
            labelBestVelocity.text = "0.0"
            labelElapsedTime.text = "00:00:00"
            labelDistance.text = "0.0"
            
            stopTimer()
            
            removePathInfo()
            
        case .share:
            print("share ############")
            imageViewLeft.image = UIImage(named: "stop")

        case .play:     
            print("play ############")
            imageViewRight.image = UIImage(named: "pause")

            btnLeft.isSelected = false
            imageViewLeft.image = UIImage(named: "stop")
            
            if isPaused {
                pauseTimer()

            }
            else {
                startTimer()

            }
            
        case .pause:
            print("pause ############")
            imageViewRight.image = UIImage(named: "play")
            labelCurVelocity.text = "0.0"
            
            pauseTimer()
            
        default:
            print("default ############")
        }
    }
    
    // MARK: - Path Info
    func viewPathInfo() {
        
        pathOverlay.color = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
        pathOverlay.path = NMGLineString(points: locationInfo.arrNMGLatLng)
        pathOverlay.mapView = naverMapView.mapView
        
    }
    
    func removePathInfo() {
        locationInfo.arrNMGLatLng.removeAll()
        pathOverlay.mapView = nil
    }
    
    //MARK: Timer
    
    func stopTimer() {
        
        timer.invalidate()
        
        isTiming = false
        isPaused = false
        pausedTime = nil   //clear current paused state
        pausedIntervals = []  //reset the pausedTimeCollector on new workout

    }
    
    func startTimer() {
        if !timer.isValid {
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatedTimer), userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate
        }
        
        isTiming = true
        isPaused = false
        pausedIntervals = []  //reset the pausedTimeCollector on new workout
    }
    
    func pauseTimer() {
        
        if isTiming == true && isPaused == false {
            
            timer.invalidate() //Stop the Timer
            isPaused = true //isPaused
            isTiming = false //Stopped Timing
            pausedTime = NSDate() //asuuming you are starting a brand new workout timer
            
        }
        else if isTiming == false && isPaused == true {
            
            let pausedSeconds = NSDate().timeIntervalSince(pausedTime! as Date)  //get time paused
            pausedIntervals.append(pausedSeconds)  // add to paused time collector
            pausedTime = nil   //clear current paused state
            
            if !timer.isValid {
                
                timer.invalidate()
                //timer = nil
                
                timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updatedTimer),     userInfo: nil, repeats: true)
                
            }
            
            
            isPaused = false
            isTiming = true
            
        }
    }
    
    @objc func updatedTimer() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
      var pausedSeconds = pausedIntervals.reduce(0) { $0 + $1 }   //calculate total time timer was previously paused
      if let pausedTime = pausedTime {
        pausedSeconds += NSDate().timeIntervalSince(pausedTime as Date)  //add current pause if paused
      }
        var elapsedTime: TimeInterval = currentTime - startTime - pausedSeconds  //subtract time paused
      let minutes = Int(elapsedTime / 60.0)

        elapsedTime -= (TimeInterval(minutes) * 60)
      let seconds = Int(elapsedTime)

        elapsedTime -= TimeInterval(seconds)

      let strMinutes = String(format: "%02d", minutes)
      let strSeconds = String(format: "%02d", seconds)

      labelElapsedTime.text = "00:\(strMinutes):\(strSeconds)"
    }

}

extension ViewController: NMFMapViewOptionDelegate {
    
    func mapViewOptionChanged(_ mapView: NMFMapView) {
        
        print("mapViewOptionChanged - mapView \(mapView)")
        let position = NMFCameraPosition(locationInfo.getLatLng(location: locationInfo.curLocationInfo), zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))

    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        print("status: \(status.rawValue)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        print("manager.location +++++++++++++++++++++++")
        guard let managerLocation = manager.location else {
            return
        }
        
//        print("altitude : \(managerLocation.altitude)")
//        print("latitude : \(managerLocation.coordinate.latitude)")
//        print("longitude : \(managerLocation.coordinate.longitude)")
//        print("speed : \(managerLocation.speed)")
//        print("timestamp : \(managerLocation.timestamp)")
        
//        print("course : \(managerLocation.course)")
//        print("altitude : \(manager.location?.courseAccuracy)")
//        print("floor : \(managerLocation.floor)")
//        print("verticalAccuracy : \(managerLocation.verticalAccuracy)")
//        print("horizontalAccuracy : \(managerLocation.horizontalAccuracy)")
//        print("speedAccuracy : \(managerLocation.speedAccuracy)")
        
        locationInfo.curLocationInfo = managerLocation
        
        let curLatLng = locationInfo.getLatLng(location: locationInfo.curLocationInfo)
        locationOverlay.location = curLatLng

        let position = NMFCameraPosition(curLatLng, zoom: naverMapView.mapView.zoomLevel, tilt: 0, heading: 0)
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: position))
        
        if .play != playStatus {
            return
        }
    
        displayTopMenu(location: locationInfo.curLocationInfo)

        if locationInfo.appendLocationInfo(location: locationInfo.curLocationInfo) {
            print("Update Path Info ... ")
            viewPathInfo()

        }
    }
    

}
