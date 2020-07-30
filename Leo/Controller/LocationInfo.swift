//
//  LocationInfo.swift
//  Leo
//
//  Created by 이동윤 on 2020/07/30.
//  Copyright © 2020 hyeon. All rights reserved.
//

import Foundation
import UIKit
import NMapsMap
import CoreLocation

class LocationInfo {
    

    var arrNMGLatLng: [NMGLatLng] = []
    var arrLocationInfo: [CLLocation] = []
    
    var curLocationInfo = CLLocation()
    
    var totDistance: Double = 0

    
    // current speed
    func getCurrentSpeed(srcSpeed: Double) -> String {

        var speed = srcSpeed
        if speed <= 0 {
            speed = 0
        }
        let strSpeed = String(format: "%.1f", speed)
        print("getCurrentSpeed : \(strSpeed)")
        return strSpeed
    }
    
    // average speed
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
        let strSpeed = String(format: "%.1f", averSpeed)
        print("getAverageSpeed : \(strSpeed)")
        return strSpeed
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
        let strSpeed = String(format: "%.1f", maxSpeed)
        print("getBestSpeed : \(strSpeed)")
        return strSpeed
    }
    
    // total distance
    func getDistance(location: CLLocation) -> String {
        
        if arrNMGLatLng.count <= 0 {
            return "0.0"
        }
        let latlng1 = arrNMGLatLng.last!
        let latlng2 = getLatLng(location: location)
        
        let distance = latlng2.distance(to: latlng1)
        totDistance = totDistance + distance
//        totDistance = Double(arrLocationInfo.distance(from: 0, to: arrLocationInfo.count - 1))
        let strDistance = String(format: "%.1f", totDistance / 1000.0)
        print("getDistance : \(strDistance)")
        
        return strDistance
        
    }
    
    func getLatLng(location: CLLocation) -> NMGLatLng {
        
        return NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        
    }
    
}
