//
//  Services.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/25/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import UIKit

enum ServicesKeys: String {
    case astrolabe
    case gangplank
    case halyard
    case supercargo
    case wheelhouse
}

public struct Services: Codable {

    public var astrolabe: String?
    public var gangplank: String?
    public var halyard: String?
    public var supercargo: String?
    public var wheelhouse: String?
}

