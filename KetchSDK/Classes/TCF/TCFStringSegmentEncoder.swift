//
//  TCFStringSegmentEncoder.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 03.11.2022.
//

import Foundation

protocol TCFStringSegmentEncoder {
    func encode() throws -> String
}

extension TCFStringSegmentEncoder {
    func encode(_ bool: Bool, to length: Int) -> String {
        encode(bool ? 1 : 0, to: length)
    }

    func encode(_ integer: UInt8, to length: Int) -> String {
        String(integer, radix: 2).padLeft(to: length)
    }

    func encode(_ integer: Int16, to length: Int) -> String {
        String(integer, radix: 2).padLeft(to: length)
    }

    func encode(_ integer: Int, to length: Int) -> String {
        String(integer, radix: 2)
            .padLeft(to: length)
    }

    func encode(_ date: Date, to length: Int) -> String {
        encode(Int(date.timeIntervalSince1970 * 10), to: length)
    }

    func encode(_ indices: Set<Int16>, to length: Int) -> String {
        let minIndex: Int16 = 1
        let maxIndex = minIndex + Int16(length) - 1

        var bitString = [Character](repeating: "0", count: length)

        indices
            .forEach { index in
                guard (minIndex...maxIndex).contains(index) else { return }

                bitString[Int(index - minIndex)] = "1"
            }

        return String(bitString)
    }

    func trimWebSafeBase64EncodedString(_ value: String) -> String {
        Data(
            value
                .split(by: 8)
                .compactMap { UInt8($0, radix: 2) }
        )
        .base64EncodedString()
        .trimmingCharacters(in: ["="])
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
    }
}

private extension String {
    func padLeft(withCharacter character: String = "0", to length: Int) -> String {
        let padCount = length - count
        guard padCount > 0 else { return self }

        return String(repeating: character, count: padCount) + self
    }

    func padRight(withCharacter character: String = "0", toLength length: Int) -> String {
        let padCount = length - count
        guard padCount > 0 else { return self }

        return self + String(repeating: character, count: padCount)
    }

    func padRight(withCharacter character: String = "0", toNearestMultipleOf multiple: Int) -> String {
        let (byteCount, bitRemainder) = count.quotientAndRemainder(dividingBy: multiple)
        let totalBytes = byteCount + (bitRemainder > 0 ? 1 : 0)
        
        return padRight(toLength: totalBytes * multiple)
    }

    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
}
