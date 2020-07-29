//
//  ViewController.swift
//  Leo
//
//  Created by spdevapp on 2020/07/28.
//  Copyright © 2020 hyeon. All rights reserved.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

    @IBOutlet weak var naverMapView: NMFNaverMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initMapOption()
    }
    
    func initMapOption() {
        
        naverMapView.mapView.addOptionDelegate(delegate: self)

        naverMapView.mapView.mapType = .terrain
        naverMapView.mapView.setLayerGroup(NMF_LAYER_GROUP_BICYCLE, isEnabled: true)
        naverMapView.mapView.isNightModeEnabled = true
        
    }


}

extension ViewController: NMFMapViewOptionDelegate {
    
    func mapViewOptionChanged(_ mapView: NMFMapView) {
        
        print("mapViewOptionChanged")
    }
}

