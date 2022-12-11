//
//  CountrySelectionSection.swift
//  KetchSDK
//
//  Created by Anton Lyfar on 09.12.2022.
//

import SwiftUI

struct CountrySelectionSection: View {
    let title: String?
    let contentColor: Color
    let value: Binding<String>

    @State private var selectedCountry: Country = {
        guard let code = Locale.current.regionCode,
              let name = Locale.current.localizedString(forRegionCode: code) else { return Country(code: nil, name: nil) }

        return Country(code: code, name: name)
    }()

    private struct Country: Hashable {
        let code: String?
        let name: String?
    }

    private let countries: [Country] = {
        NSLocale.isoCountryCodes.compactMap { countryCode in
            guard let name = Locale.current.localizedString(forRegionCode: countryCode) else { return nil }

            return Country(code: countryCode, name: name)
        }
    }()

    var body: some View {
        VStack {
            if let title = title {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                }
            }

            Menu {
                Picker(
                    selection: $selectedCountry,
                    label: Text(selectedCountry.name ?? "Select state"),
                    content: {
                        ForEach(countries, id: \.self) { country in
                            Text(country.name!)
                        }
                    }
                )
                .pickerStyle(.automatic)
                .accentColor(.white)
            } label: {
                HStack {
                    Text(selectedCountry.name ?? "Select state")
                        .font(.system(size: 14))
                        .foregroundColor(contentColor)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(contentColor)
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(contentColor, lineWidth: 1)
                )
            }
        }
        .onChange(of: selectedCountry) { newValue in
            if let code = newValue.code {
                value.wrappedValue = code
            }
        }
    }
}
