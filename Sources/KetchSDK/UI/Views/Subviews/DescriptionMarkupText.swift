//
//  DescriptionMarkupText.swift
//  KetchSDK
//

import SwiftUI

struct DescriptionMarkupText: View {
    let description: String
    let handleUrl: (URL) -> Void

    var body: some View {
        if #available(iOS 15.0, *) {
            formattedText(with: description)
                .environment(\.openURL, OpenURLAction { url in
                    handleUrl(url)
                    return .handled
                })
        } else {
            formattedText(with: description)
                .onOpenURL(perform: handleUrl)
        }
    }

    @ViewBuilder
    private func formattedText(with description: String) -> some View {
        description.markupFragments().convertToLinks().reduce(Text("")) { result, fragment in
            let text = Text(LocalizedStringKey(String(fragment.substring)))
            switch fragment.type {
            case .markupLink: return result + text.underline()
            default: return result + text
            }
        }
    }
}

private extension String {
    func markupFragments() -> [MarkupFragment] {
        self[self.startIndex..<self.endIndex]
            .markupFragments(type: .markupLink)
            .markupFragments(type: .url)
            .markupFragments(type: .phone)
    }
}

private extension Array where Element == MarkupFragment {
    func markupFragments(type: MarkupFragmentType) -> [MarkupFragment] {
        reduce(into: []) { result, fragment in
            if case .text = fragment.type {
                result.append(contentsOf: fragment.substring.markupFragments(type: type))
            } else {
                result.append(fragment)
            }
        }
    }

    func convertToLinks() -> [MarkupFragment] {
        map { fragment in
            switch fragment.type {
            case .url:
                let url = fragment.substring

                return MarkupFragment(type: .markupLink, substring: Substring("[\(url)](\(url))"))

            case .phone:
                let phone = fragment.substring

                return MarkupFragment(type: .markupLink, substring: Substring("[\(phone)](tel:\(phone))"))

            default: return fragment
            }
        }
    }
}

private extension Substring {
    func markupFragments(type: MarkupFragmentType) -> [MarkupFragment] {
        guard let regex = type.regex else { return [MarkupFragment(type: .text, substring: self)] }

        var results = [MarkupFragment]()
        var lastIndex = startIndex

        regex.enumerateMatches(
            in: String(self),
            range: NSMakeRange(0, utf16.count)
        ) { result, flags, stop in
            if let result = result, let inputRange = Range(result.range, in: self) {
                if inputRange.lowerBound > lastIndex {
                    let substring = self[lastIndex..<inputRange.lowerBound]
                    results.append(MarkupFragment(type: .text, substring: substring))
                }

                results.append(MarkupFragment(type: type, substring: self[inputRange]))
                lastIndex = inputRange.upperBound
            }
        }

        if endIndex > lastIndex {
            let substring = self[lastIndex..<endIndex]
            results.append(MarkupFragment(type: .text, substring: substring))
        }

        return results
    }
}

private struct MarkupFragment {
    let type: MarkupFragmentType
    let substring: Substring
}

private enum MarkupFragmentType {
    case text
    case url
    case phone
    case markupLink

    var regex: NSRegularExpression? {
        switch self {
        case .text: return nil
        case .url: return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        case .phone: return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
        case .markupLink: return try? NSRegularExpression(pattern: "\\[(.*?)\\)", options: [])
        }
    }
}
