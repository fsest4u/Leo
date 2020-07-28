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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let mapView = NMFMapView(frame: view.frame)
        view.addSubview(mapView)
    }


}

