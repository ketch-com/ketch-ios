//
//  DataRightsView+Entry.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 11.12.2022.
//

import Foundation

extension DataRightsView {
    class FieldEntry: ObservableObject, Identifiable {
        var id = UUID()
        let title: String
        let validations: [String.Validation]
        @Published var value = String()
        @Published var error: String?

        init(title: String, validations: [String.Validation] = []) {
            self.title = title
            self.validations = validations
        }

        func validationErrorText(for text: String) -> String? {
            validations.first { validation in
                validation.isValid(text) == false
            }?.errorText
        }

        func setError() {
            error = validationErrorText(for: value)
        }
    }

    class DataRightsEntry: ObservableObject {
        @Published var selectedRight: Props.DataRightsView.Right?

        let requestDetails = FieldEntry(title: "Request Details", validations: [.notEmpty])
        let firstName = FieldEntry(title: "First Name", validations: [.notEmpty])
        let lastName = FieldEntry(title: "Last Name", validations: [.notEmpty])
        let email = FieldEntry(title: "Email", validations: [.notEmpty, .email])
        let phone = FieldEntry(title: "Phone")
        let country = FieldEntry(title: "Country")
        let postalCode = FieldEntry(title: "Postal Code")
        let addressLine1 = FieldEntry(title: "Address Line 1")
        let addressLine2 = FieldEntry(title: "Address Line 2")

        enum Result {
            case isValid(DataRightsView.Action.Request)
            case error(title: String, message: String)
        }

        var fieldEntries: [FieldEntry] {
            [
                requestDetails,
                firstName,
                lastName,
                email,
                phone,
                country,
                postalCode,
                addressLine1,
                addressLine2
            ]
        }

        var firstNotValid: DataRightsView.FieldEntry? {
            fieldEntries.first { entry in
                entry.validationErrorText(for: entry.value) != nil
            }
        }

        var request: DataRightsView.Action.Request {
            DataRightsView.Action.Request(
                firstName: firstName.value,
                lastName: lastName.value,
                email: email.value,
                country: country.value,
                stateRegion: nil,
                description: requestDetails.value,
                phone: phone.value,
                postalCode: postalCode.value,
                addressLine1: addressLine1.value,
                addressLine2: addressLine2.value
            )
        }
    }
}
