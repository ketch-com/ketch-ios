//
//  ConsentStatus.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

public struct ConsentStatus: Codable, Equatable {

    public var allowed: Bool?
    public var legalBasisCode: String?

    public init(allowed: Bool, legalBasisCode: String) {
        self.allowed = allowed
        self.legalBasisCode = legalBasisCode
    }
}
