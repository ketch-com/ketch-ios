//
//  ViewController.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10/05/2022.
//  Copyright (c) 2022 Anton Lyfar. All rights reserved.
//

import UIKit
import KetchSDK

class ViewController: UIViewController {
    private var ketch = KetchSDK()

    override func viewDidLoad() {
        super.viewDidLoad()

        ketch.getConfig()

    }
}

