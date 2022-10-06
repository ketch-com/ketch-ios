//
//  CheckboxLabel.swift
//  Sample
//
//  Created by Aleksey Bodnya on 4/9/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

class CheckboxLabel: UIControl {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        finishInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func finishInit() {
        [checkboxLabel, titleLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        checkboxLabel.setContentHuggingPriority(.required, for: .horizontal)
        checkboxLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        NSLayoutConstraint.activate([
            checkboxLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            checkboxLabel.topAnchor.constraint(equalTo: topAnchor),
            checkboxLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: checkboxLabel.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        addTarget(self, action: #selector(tap), for: .touchUpInside)

        checkboxLabel.text = isSelected ? onSymbol : offSymbol
    }

    var title: String?  {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    private let onSymbol = "☑"
    private let offSymbol = "☐"

    private let checkboxLabel = UILabel()

    private let titleLabel = UILabel()

    override var isSelected: Bool {
        didSet {
            checkboxLabel.text = isSelected ? onSymbol : offSymbol
        }
    }

    @objc private func tap() {
        isSelected = !isSelected
    }
}
