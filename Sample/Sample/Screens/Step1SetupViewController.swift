//
//  Step1SetupViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class Step1SetupViewController: UIViewController {

    @IBOutlet weak var organizationCodeTextField: UITextField!
    @IBOutlet weak var applicationCodeTextField: UITextField!
    @IBOutlet weak var setupButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        validateSetupButton()
    }

    @IBAction func setupTap(_ sender: Any) {
        let organizationCode = organizationCodeTextField.text ?? ""
        let applicationCode = applicationCodeTextField.text ?? ""
        setupButton.isEnabled = false
        try! Ketch_gRPC.setup(organizationCode: organizationCode, applicationCode: applicationCode)
        performSegue(withIdentifier: "pushStep2", sender: self)
    }

    @IBAction func textFieldEditingChanged(_ sender: Any) {
        validateSetupButton()
    }

    func validateSetupButton() {
        setupButton.isEnabled = [organizationCodeTextField, applicationCodeTextField]
            .map { ($0?.text?.count ?? 0) > 0 }
            .reduce(true) { $0 && $1 }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? Step2FullConfigViewController {
            vc.organizationCode = organizationCodeTextField.text ?? ""
            vc.applicationCode = applicationCodeTextField.text ?? ""
        }

        super.prepare(for: segue, sender: sender)
    }
}
