//
//  Options.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

enum OptionsKeys: String {
    case localStorage
    case migration
}

public struct Options: Codable {

    public var localStorage: Int?
    public var migration: Int?
}
