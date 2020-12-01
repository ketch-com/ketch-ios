//
//  Step2BootstrapConfigViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class Step2BootstrapConfigViewController: UIViewController {

    var organizationCode: String = ""
    var applicationCode: String = ""
    var bootstrapConfig: BootstrapConfiguration? = nil

    @IBOutlet weak var organizationCodeLabel: UILabel!
    @IBOutlet weak var applicationCodeLabel: UILabel!
    @IBOutlet weak var getConfigButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isHidden = true
        organizationCodeLabel.text = organizationCode
        applicationCodeLabel.text = applicationCode
        navigationItem.leftBarButtonItem = UIBarButtonItem()
    }

    @IBAction func getBootstrapConfig(_ sender: Any) {
        getConfigButton.isEnabled = false
        Ketch.getBootstrapConfiguration { [weak self] (result) in
            self?.getConfigButton.isEnabled = true
            self?.bootstrapConfig = result.object
            self?.textView.text = result.description
            self?.nextButton.isHidden = result.object == nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? Step3FullConfigViewController {
            vc.bootstrapConfig = bootstrapConfig
        }

        super.prepare(for: segue, sender: sender)
    }
}
