//
//  DataRightsView+Entry.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 11.12.2022.
//

import Foundation

extension DataRightsView {
    struct UserData: UserDataCoding {
        let firstName: String
        let lastName: String
        let email: String
        let country: String?
        let stateRegion: String?
        let description: String?
        let phone: String?
        let postalCode: String?
        let addressLine1: String?
        let addressLine2: String?
    }

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
            case isValid(DataRightsView.UserData)
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

        var request: DataRightsView.UserData {
            DataRightsView.UserData(
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

protocol UserDataCoding {
    var firstName: String { get }
    var lastName: String { get }
    var email: String { get }
    var country: String? { get }
    var stateRegion: String? { get }
    var description: String? { get }
    var phone: String? { get }
    var postalCode: String? { get }
    var addressLine1: String? { get }
    var addressLine2: String? { get }
}

extension UserDataCoding {
    var configUserData: KetchSDK.InvokeRightConfig.User {
        .init(
            email: email,
            first: firstName,
            last: lastName,
            country: country,
            stateRegion: stateRegion,
            description: description,
            phone: phone,
            postalCode: postalCode,
            addressLine1: addressLine1,
            addressLine2: addressLine2
        )
    }
}
