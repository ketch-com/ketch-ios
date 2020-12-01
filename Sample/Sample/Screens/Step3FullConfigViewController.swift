//
//  Step3FullConfigViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class Step3FullConfigViewController: UIViewController {

    var bootstrapConfig: BootstrapConfiguration? = nil
    var configuration: Configuration? = nil
    var environments: [Environment] = []

    @IBOutlet weak var languageCodeLabel: UILabel!
    @IBOutlet weak var environementSegmentedControl: UISegmentedControl!

    @IBOutlet weak var getFullConfigButton: UIButton!
    @IBOutlet weak var usageStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        usageStackView.isHidden = true
        languageCodeLabel.text = NSLocale.preferredLanguages.first!.uppercased()
        environments = bootstrapConfig?.environments?.filter { $0.code != nil } ?? []
        if environments.count > 3 {
            environments = Array(environments.prefix(3))
        }
        environementSegmentedControl.removeAllSegments()
        environments.forEach { (environment) in
            environementSegmentedControl.insertSegment(
                withTitle: environment.code!,
                at: environementSegmentedControl.numberOfSegments,
                animated: false
            )
        }
        environementSegmentedControl.selectedSegmentIndex = 0
    }

    @IBAction func getFullConfiguration(_ sender: Any) {
        let environment = environments[environementSegmentedControl.selectedSegmentIndex]
        getFullConfigButton.isEnabled = false
        Ketch.getFullConfiguration(bootstrapConfiguration: bootstrapConfig!, environmentCode: environment.code!) { [weak self] (result) in
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
