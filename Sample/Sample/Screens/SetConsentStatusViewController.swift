//
//  SetConsentStatusViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class SetConsentStatusViewController: UIViewController, UsageViewControllerProtocol {

    var config: Configuration? = nil
    var purposes: [Purpose] = []

    @IBOutlet weak var identityKeyTextField: UITextField!
    @IBOutlet weak var conentsStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var setStatusButton: UIButton!

    var consentViews: [ConsentStatusView] {
        return conentsStackView.subviews.compactMap { $0 as? ConsentStatusView }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        purposes = config?.purposes?.filter { $0.code != nil && $0.legalBasisCode != nil } ?? []
        if purposes.count > 3 {
            purposes = Array(purposes.prefix(3))
        }
        purposes.forEach { (activity) in
            let view = ConsentStatusView(activityCode: activity.code!, legalBasisCode: activity.legalBasisCode!)
            conentsStackView.addArrangedSubview(view)
        }
        if consentViews.count > 0 {
            consentViews[0].isSelected = true
        }
        validateSetButton()
    }

    @IBAction func identityKeyChanged(_ sender: Any) {
        validateSetButton()
        textView.text = ""
    }

    @IBAction func segmentControlValueChanged(_ sender: Any) {
        textView.text = ""
    }

    func validateSetButton() {
        setStatusButton.isEnabled = (identityKeyTextField.text?.count ?? 0) > 0
    }

    @IBAction func setConsentStatus(_ sender: Any) {
        var consents = [String: ConsentStatus]()
        for view in consentViews {
            guard view.isSelected else {
                continue
            }
            let consentStatus = ConsentStatus(allowed: view.allowed, legalBasisCode: view.legalBasisCode)
            consents[view.activityCode] = consentStatus
        }
        let identityKey = identityKeyTextField.text ?? ""
        setStatusButton.isEnabled = false
        Ketch.setConsentStatus(
            configuration: config!,
            identities: [identityKey: "testValue"],
            consents: consents,
            migrationOption: .always) { [weak self] (result) in
                self?.setStatusButton.isEnabled = true
                self?.textView.text = result.description
        }
    }
}
