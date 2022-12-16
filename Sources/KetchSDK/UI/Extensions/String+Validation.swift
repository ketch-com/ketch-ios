//
//  String+Validation.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 10.12.2022.
//

import Foundation

extension String {
    struct Validation {
        let isValid: (String) -> Bool
        let errorText: String
    }
}

extension String.Validation {
    static var email = Self(
        isValid: textFieldValidatorEmail,
        errorText: "Please enter valid email"
    )

    static var notEmpty = Self(
        isValid: { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false },
        errorText: "Required"
    )

    private static func textFieldValidatorEmail(_ string: String) -> Bool {
        guard string.count <= 100 else { return false }

        let emailFormat = [
            "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}",
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\",
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-",
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5",
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-",
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21",
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        ].joined()

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)

        return emailPredicate.evaluate(with: string)
    }
}
