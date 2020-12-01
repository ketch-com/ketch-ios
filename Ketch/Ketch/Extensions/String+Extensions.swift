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

    /// String with adding percent encoding for url query allowed characters
    var urlEncoded: String {
        if let result = addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return result
        }
        return self
    }

    /// SHA256 string of encoded current string
    var sha256: String {
        guard let input = data(using: .utf8) else {
            return self
        }
        let hashed = SHA256.hash(data: input)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }

    /// String decoded from Base64 string
    var base64Decode: String? {
        if let data = Data(base64Encoded: self), let result = String(data: data, encoding: .utf8) {
            return result
        }
        return nil
    }
}
