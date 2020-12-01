//
//  ConsentStatusView.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/9/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class ConsentStatusView: UIView {

    init(activityCode: String, legalBasisCode: String) {
        self.activityCode = activityCode
        self.legalBasisCode = legalBasisCode
        super.init(frame: .zero)
        finishInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func finishInit() {
        checkboxLabel.title = activityCode
        [checkboxLabel, allowedSwitch].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            checkboxLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxLabel.topAnchor.constraint(equalTo: topAnchor),
            checkboxLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            allowedSwitch.leadingAnchor.constraint(equalTo: checkboxLabel.trailingAnchor, constant: 8),
            allowedSwitch.topAnchor.constraint(equalTo: topAnchor),
            allowedSwitch.bottomAnchor.constraint(equalTo: bottomAnchor),
            allowedSwitch.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    public let activityCode: String
    public let legalBasisCode: String

    public var isSelected: Bool {
        get { return checkboxLabel.isSelected }
        set { checkboxLabel.isSelected = newValue }
    }

    public var allowed: Bool {
        return allowedSwitch.isOn
    }

    private let checkboxLabel = CheckboxLabel()

    private let allowedSwitch = UISwitch()
}
