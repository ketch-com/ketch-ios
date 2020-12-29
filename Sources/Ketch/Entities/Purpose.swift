//
//  Purpose.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

public struct Purpose: Codable {

    public var code: String?
    public var name: String?
    public var description: String?
    public var legalBasisCode: String?
    public var requiresPrivacyPolicy: Bool?
    public var requiresOptIn: Bool?
    public var allowsOptOut: Bool?
}
