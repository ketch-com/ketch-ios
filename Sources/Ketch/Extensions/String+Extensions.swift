//
//  String+Extensions.swift
//  Ketch
//
//  Created by Aleksey Bodnya on 3/27/20.
//  Copyright © 2020 Switchbit. All rights reserved.
//

import Foundation
import CryptoKit

extension String {

    /// SHA256 string of encoded current string
    var sha256: String {
        guard let input = data(using: .utf8) else {
            return self
        }
        let hashed = SHA256.hash(data: input)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
