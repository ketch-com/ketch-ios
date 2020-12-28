//
//  InvokeRightViewController.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/6/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit
import Ketch

class InvokeRightViewController: UIViewController, UsageViewControllerProtocol {

    var config: Configuration? = nil
    var rights: [Right] = []

    @IBOutlet weak var identityKeyTextField: UITextField!
    @IBOutlet weak var rightsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var invokeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        rights = config?.rights?.filter { $0.code != nil } ?? []
        if rights.count > 3 {
            rights = Array(rights.prefix(3))
        }
        rightsSegmentedControl.removeAllSegments()
        rights.forEach { (right) in
            rightsSegmentedControl.insertSegment(
                withTitle: right.code!,
                at: rightsSegmentedControl.numberOfSegments,
                animated: false
            )
        }
        rightsSegmentedControl.selectedSegmentIndex = 0
        validateButton()
    }

    @IBAction func identityKeyChanged(_ sender: Any) {
        validateButton()
        textView.text = ""
    }

    @IBAction func segmentControlValueChanged(_ sender: Any) {
        textView.text = ""
    }

    func validateButton() {
        invokeButton.isEnabled = (identityKeyTextField.text?.count ?? 0) > 0
    }

    @IBAction func invokeRights(_ sender: Any) {
        let right = rights[rightsSegmentedControl.selectedSegmentIndex]
        let identityKey = identityKeyTextField.text ?? ""
        invokeButton.isEnabled = false
        Ketch.invokeRight(
            configuration: config!,
            identities: [identityKey: "testValue"],
            right: right.code!,
            userData: UserData(email: "example@domain.com", first: "John", last: "Doe", country: "US", region: "CA")) { [weak self] (result) in
            self?.invokeButton.isEnabled = true
            self?.textView.text = result.description
        }
    }

}
