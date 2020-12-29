//
//  KetchError.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/30/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

/// Possible errors may occur during setup and using Ketch framework
public enum KetchError: ValidationError {

    /// Method `setup` is called more than once
    case alreadySetup

    /// Method `setup` is not called before starting using API for network calls
    case haveNotSetupYet

    /// The convenient method to get the reason why validation failed
    public var description: String {
        switch self {
        case .alreadySetup:
            return "Ketch is already setup."
        case .haveNotSetupYet:
            return "You must call Ketch.setup() method before starting working with it."
        }
    }
}
