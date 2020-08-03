//
//  Util.swift
//  Leo
//
//  Created by spdevapp on 2020/07/29.
//  Copyright © 2020 hyeon. All rights reserved.
//

import Foundation

class Util {

    static func convertMStoKmH(meterPerSecond: Double) -> Double {
        
        let kilometerPerHour: Double = meterPerSecond * 3600 / 1000
        
        return kilometerPerHour
        
    }
}
