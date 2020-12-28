//
//  Step3FullConfigViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class Step2FullConfigViewController: UIViewController {

    let environment = "production"
    let countryCode = "US"
    let regionCode = "CA"
    
    var organizationCode: String!
    var applicationCode: String!
    var configuration: Configuration? = nil

    @IBOutlet weak var environmentTextField: UITextField!
    
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var regionCodeLabel: UILabel!
    @IBOutlet weak var languageCodeLabel: UILabel!

    @IBOutlet weak var getFullConfigButton: UIButton!
    @IBOutlet weak var usageStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        usageStackView.isHidden = true
        environmentTextField.text = environment
        countryCodeLabel.text = countryCode
        regionCodeLabel.text = regionCode
        languageCodeLabel.text = NSLocale.preferredLanguages.first!.uppercased()
    }

    @IBAction func getFullConfiguration(_ sender: Any) {
        let environment = environmentTextField.text ?? "production"
        environmentTextField.text = environment
        getFullConfigButton.isEnabled = false
        Ketch_gRPC.getFullConfiguration(environmentCode: environment, countryCode: countryCode, regionCode: regionCode, ip: "") { [weak self] result in
            self?.getFullConfigButton.isEnabled = true
            self?.configuration = result.object
            self?.textView.text = result.description
            self?.usageStackView.isHidden = result.object == nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var vc = segue.destination as? UsageViewControllerProtocol {
            vc.config = configuration
        }

        super.prepare(for: segue, sender: sender)
    }

}
