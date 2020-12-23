//
//  UserData.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

public struct UserData {

    public var email: String
    public var first: String
    public var last: String
    public var country: String
    public var region: String

    public init(email: String, first: String, last: String, country: String, region: String) {
        self.email = email
        self.first = first
        self.last = last
        self.country = country
        self.region = region
    }
}
