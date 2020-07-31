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

    // MARK: - Functions

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
    
    func getCurrentSpeed(location: CLLocation) -> String {
        
        let distance = getDistance(location: location)
        let elapsedTime = getElapsedTime(location: location)
        print("distance : \(distance)")
        print("elapsedTime : \(elapsedTime)")

        if elapsedTime != 0 {
            let speed = distance / elapsedTime * 3600 / 1000
            let strSpeed = String(format: "%.1f", speed)
            print("getCurrentSpeed : \(strSpeed)")
            return strSpeed
        }
        else {
            return "0.0"
        }
        
    }
    
    func getDistance(location: CLLocation) -> Double {
        if arrNMGLatLng.count <= 0 {
            return 0.0
        }
        let latlng1 = arrNMGLatLng.last!
        let latlng2 = getLatLng(location: location)
        
        let distance = latlng2.distance(to: latlng1)
        print("getDistance : \(distance) m")
        return distance
    }
    
    func getElapsedTime(location: CLLocation) -> Double {
        
        if arrLocationInfo.count <= 0 {
            return 0.0
        }
        let oldLocation = arrLocationInfo.last!
        let elapsedSecond = location.timestamp.seconds(sinceDate: oldLocation.timestamp) ?? 0
        
        print("getElapsedTime : \(elapsedSecond) sec")
        return Double(elapsedSecond)
        
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
    func getTotalDistance(location: CLLocation) -> String {
        let distance = getDistance(location: location)
        totDistance = totDistance + distance
//        totDistance = Double(arrLocationInfo.distance(from: 0, to: arrLocationInfo.count - 1))
        let strDistance = String(format: "%.1f", totDistance / 1000)
        print("getTotalDistance : \(strDistance) km")
        return strDistance
        
    }
    
    func getLatLng(location: CLLocation) -> NMGLatLng {
        
        return NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        
    }
    
    func getIndexLastLocationInfo() -> Int {
        
        var count = arrLocationInfo.count
        // 최초 입력
        if count <= 0 {
            let curLatLng = getLatLng(location: curLocationInfo)
            arrNMGLatLng.append(curLatLng)
            arrLocationInfo.append(curLocationInfo)
        }
        count = arrLocationInfo.count
        
        print("getIndexLast index : \(count - 1)")
//        return arrLocationInfo[count - 1]
        return count - 1
    }
    
    func appendLocationInfo(location: CLLocation) -> Bool {

        // temp_code, dylee
        if location.speed > 0 {
//        if true {
            let curLatLng = getLatLng(location: location)
            arrNMGLatLng.append(curLatLng)
            arrLocationInfo.append(location)
            return true
        }
        else {
            return false
        }
    }
    
    func removeLocationInfo() {
        arrNMGLatLng.removeAll()
        arrLocationInfo.removeAll()
        totDistance = 0
    }
    
}
