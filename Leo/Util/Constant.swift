//
//  constant.swift
//  Leo
//
//  Created by spdevapp on 2020/07/29.
//  Copyright © 2020 hyeon. All rights reserved.
//

import Foundation

let DEBUG_MODE = true

let ZOOM_LEVEL_DEFAULT: Double = 14
let ZOOM_LEVEL_MIN: Double = 10      // min 0.0
let ZOOM_LEVEL_MAX: Double = 18     // max 22.0

let DEFAULT_LATITUDE: Double = 37.570202
let DEFAULT_LOGITUDE: Double = 126.977047

let GAP_DISTANCE:Double = 50    // meter

enum PlayStatus: Int {
    case none = 0   // init
    case stop
    case share      // save
    case play       // play or resume
    case pause
}

var playStatus: PlayStatus = .none
