//
//  MigrationOption.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation

public enum MigrationOption: Int {

    case `default` = 0
    case never = 1
    case fromAllow = 2
    case fromDeny = 3
    case always = 4
}
