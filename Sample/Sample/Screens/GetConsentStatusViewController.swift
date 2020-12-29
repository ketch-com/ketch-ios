//
//  GetConsentStatusViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class GetConsentStatusViewController: UIViewController, UsageViewControllerProtocol {

    var config: Configuration? = nil
    var purposes: [Purpose] = []

    @IBOutlet weak var identityKeyTextField: UITextField!
    @IBOutlet weak var conentsStackView: UIStackView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var getStatusButton: UIButton!

    var checkboxLabels: [CheckboxLabel] {
        return conentsStackView.subviews.compactMap { $0 as? CheckboxLabel }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        purposes = config?.purposes?.filter { $0.code != nil && $0.legalBasisCode != nil } ?? []
        if purposes.count > 3 {
            purposes = Array(purposes.prefix(3))
        }
        purposes.forEach { (activity) in
            let view = CheckboxLabel()
            view.title = activity.code!
            conentsStackView.addArrangedSubview(view)
        }
        if checkboxLabels.count > 0 {
            checkboxLabels[0].isSelected = true
        }
        validateGetButton()
    }

    @IBAction func segmentControlValueChanged(_ sender: Any) {
        textView.text = ""
    }

    @IBAction func identityKeyChanged(_ sender: Any) {
        validateGetButton()
        textView.text = ""
    }

    func validateGetButton() {
        getStatusButton.isEnabled = (identityKeyTextField.text?.count ?? 0) > 0
    }

    @IBAction func getConsentStatus(_ sender: Any) {
        var purposes = [String: String]()
        for (index, view) in checkboxLabels.enumerated() {
            guard view.isSelected else {
                continue
            }
            let activity = self.purposes[index]
            purposes[activity.code!] = activity.legalBasisCode!
        }
        let identityKey = identityKeyTextField.text ?? ""
        getStatusButton.isEnabled = false
        Ketch.getConsentStatus(
            configuration: config!,
            identities: [identityKey: "testValue"],
            purposes: purposes) { [weak self] (result) in
            self?.getStatusButton.isEnabled = true
            self?.textView.text = result.description
        }
    }

}
