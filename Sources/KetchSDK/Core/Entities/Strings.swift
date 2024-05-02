//
//  Labels.swift
//  KetchSDK
//
//  Created by Ryan Overton on 8/15/23.
//

#if !os(macOS)

import Foundation
extension KetchSDK{
    public struct LocalizedStrings: Codable {
        let poweredBy, purpose, rejectAll, acceptAll: String
        let accept, legalBasis, cookies, cookie: String
        let dataCategories, dataCategory, vendors, vendor: String
        let serviceProvider, duration, category, description: String
        let retentionPeriod, externalTransfer, strictlyNecessary, functional: String
        let performance, marketing, session, persistent: String
        let firstParty, thirdParty, preferenceOverviewButtonText, preferenceConsentsExitButtonText: String
        let preferenceRightsRequest, preferenceRightsRequestDetails, preferenceRightsPersonalDetails, preferenceRightsFirstName: String
        let preferenceRightsLastName, preferenceRightsEmail, preferenceRightsCountry, preferenceRightsSelectCountry: String
        let preferenceRightsState, preferenceRightsThankYou, preferenceRightsWeHaveReceived, preferenceRightsCancelButtonText: String
        let preferenceRightsExitButtonText, preferenceRightsSubmitNewRequest, stringsRequired, enterValidEmail: String
        let countryAfghanistan, countryAlbania, countryAlgeria, countryAndorra: String
        let countryAngola, countryAntiguaAndBarbuda, countryArgentina, countryArmenia: String
        let countryAustralia, countryAustria, countryAzerbaijan, countryBahamas: String
        let countryBahrain, countryBangladesh, countryBarbados, countryBelarus: String
        let countryBelgium, countryBelize, countryBenin, countryBhutan: String
        let countryBolivia, countryBosniaAndHerzegovina, countryBotswana, countryBrazil: String
        let countryBruneiDarussalam, countryBulgaria, countryBurkinaFaso, countryBurundi: String
        let countryCambodia, countryCameroon, countryCanada, countryCapeVerde: String
        let countryCentralAfricanRepublic, countryChad, countryChile, countryChina: String
        let countryColombia, countryComoros, countryCongo, countryCongoTheDemocraticRepublic: String
        let countryCostaRica, countryCoteDivoire, countryCroatia, countryCuba: String
        let countryCyprus, countryCzechRepublic, countryDenmark, countryDjibouti: String
        let countryDominica, countryDominicanRepublic, countryEcuador, countryEgypt: String
        let countryElSalvador, countryEquatorialGuinea, countryEritrea, countryEstonia: String
        let countryEthiopia, countryFiji, countryFinland, countryFrance: String
        let countryGabon, countryGambia, countryGeorgia, countryGermany: String
        let countryGhana, countryGreece, countryGrenada, countryGuatemala: String
        let countryGuinea, countryGuineaBissau, countryGuyana, countryHaiti: String
        let countryVaticanCity, countryHonduras, countryHungary, countryIceland: String
        let countryIndia, countryIndonesia, countryIraq, countryIreland: String
        let countryIsrael, countryItaly, countryJamaica, countryJapan: String
        let countryJordan, countryKazakhstan, countryKenya, countryKiribati: String
        let countryNorthKorea, countrySouthKorea, countryKosovo, countryKuwait: String
        let countryKyrgyzstan, countryLaos, countryLatvia, countryLebanon: String
        let countryLesotho, countryLiberia, countryLibya, countryLiechtenstein: String
        let countryLithuania, countryLuxembourg, countryNorthMacedonia, countryMadagascar: String
        let countryMalawi, countryMalaysia, countryMaldives, countryMali: String
        let countryMalta, countryMarshallIslands, countryMauritania, countryMauritius: String
        let countryMexico, countryMicronesia, countryMoldova, countryMonaco: String
        let countryMongolia, countryMontenegro, countryMorocco, countryMozambique: String
        let countryMyanmar, countryNamibia, countryNauru, countryNepal: String
        let countryNetherlands, countryNewZealand, countryNicaragua, countryNiger: String
        let countryNigeria, countryNorway, countryOman, countryPakistan: String
        let countryPalau, countryPanama, countryPapuaNewGuinea, countryParaguay: String
        let countryPeru, countryPhilippines, countryPoland, countryPortugal: String
        let countryQatar, countryRomania, countryRussianFederation, countryRwanda: String
        let countrySaintKittsAndNevis, countrySaintLucia, countrySaintVincentAndTheGrenadines, countrySamoa: String
        let countrySANMarino, countrySaoTomeAndPrincipe, countrySaudiArabia, countrySenegal: String
        let countrySerbia, countrySeychelles, countrySierraLeone, countrySingapore: String
        let countrySlovakia, countrySlovenia, countrySolomonIslands, countrySomalia: String
        let countrySouthAfrica, countrySpain, countrySriLanka, countrySudan: String
        let countrySouthSudan, countrySuriname, countryEswatini, countrySweden: String
        let countrySwitzerland, countrySyria, countryTaiwan, countryTajikistan: String
        let countryTanzania, countryThailand, countryTimorLeste, countryTogo: String
        let countryTonga, countryTrinidadAndTobago, countryTunisia, countryTurkey: String
        let countryTurkmenistan, countryTuvalu, countryUganda, countryUkraine: String
        let countryUnitedArabEmirates, countryUnitedKingdom, countryUnitedStates, countryUruguay: String
        let countryUzbekistan, countryVanuatu, countryVenezuela, countryVietnam: String
        let countryYemen, countryZambia, countryZimbabwe, purposes: String
        let specialPurposes, features, specialFeatures, privacyPolicy: String
        let legalText, maximumStorage, preferenceRightsPhoneNumber, preferenceRightsSelectStateProvince: String
        let preferenceRightsPostalCode, preferenceRightsAddressLineOne, preferenceRightsAddressLineTwo, enterValidPhoneNumber: String
        let of, iAmAAn, selectARelationship, tellUsAboutYourRelationshipToUs: String
        let exIWorkedInTheItDepartmentIn2015, optedIn, optedOut, here: String
        let rightsTabPortholeRedirectFooter, clickHere, rightsTabPortholeRedirectFooterAlt, pleaseSelectARequestType: String
        let greeting, provenance: String

        enum CodingKeys: String, CodingKey {
            case poweredBy = "powered_by"
            case purpose
            case rejectAll = "reject_all"
            case acceptAll = "accept_all"
            case accept
            case legalBasis = "legal_basis"
            case cookies, cookie
            case dataCategories = "data_categories"
            case dataCategory = "data_category"
            case vendors, vendor
            case serviceProvider = "service_provider"
            case duration, category, description
            case retentionPeriod = "retention_period"
            case externalTransfer = "external_transfer"
            case strictlyNecessary = "strictly_necessary"
            case functional, performance, marketing, session, persistent
            case firstParty = "first_party"
            case thirdParty = "third_party"
            case preferenceOverviewButtonText = "preference_overview_button_text"
            case preferenceConsentsExitButtonText = "preference_consents_exit_button_text"
            case preferenceRightsRequest = "preference_rights_request"
            case preferenceRightsRequestDetails = "preference_rights_request_details"
            case preferenceRightsPersonalDetails = "preference_rights_personal_details"
            case preferenceRightsFirstName = "preference_rights_first_name"
            case preferenceRightsLastName = "preference_rights_last_name"
            case preferenceRightsEmail = "preference_rights_email"
            case preferenceRightsCountry = "preference_rights_country"
            case preferenceRightsSelectCountry = "preference_rights_select_country"
            case preferenceRightsState = "preference_rights_state"
            case preferenceRightsThankYou = "preference_rights_thank_you"
            case preferenceRightsWeHaveReceived = "preference_rights_we_have_received"
            case preferenceRightsCancelButtonText = "preference_rights_cancel_button_text"
            case preferenceRightsExitButtonText = "preference_rights_exit_button_text"
            case preferenceRightsSubmitNewRequest = "preference_rights_submit_new_request"
            case stringsRequired = "required"
            case enterValidEmail = "enter_valid_email"
            case countryAfghanistan = "country_afghanistan"
            case countryAlbania = "country_albania"
            case countryAlgeria = "country_algeria"
            case countryAndorra = "country_andorra"
            case countryAngola = "country_angola"
            case countryAntiguaAndBarbuda = "country_antigua_and_barbuda"
            case countryArgentina = "country_argentina"
            case countryArmenia = "country_armenia"
            case countryAustralia = "country_australia"
            case countryAustria = "country_austria"
            case countryAzerbaijan = "country_azerbaijan"
            case countryBahamas = "country_bahamas"
            case countryBahrain = "country_bahrain"
            case countryBangladesh = "country_bangladesh"
            case countryBarbados = "country_barbados"
            case countryBelarus = "country_belarus"
            case countryBelgium = "country_belgium"
            case countryBelize = "country_belize"
            case countryBenin = "country_benin"
            case countryBhutan = "country_bhutan"
            case countryBolivia = "country_bolivia"
            case countryBosniaAndHerzegovina = "country_bosnia_and_herzegovina"
            case countryBotswana = "country_botswana"
            case countryBrazil = "country_brazil"
            case countryBruneiDarussalam = "country_brunei_darussalam"
            case countryBulgaria = "country_bulgaria"
            case countryBurkinaFaso = "country_burkina_faso"
            case countryBurundi = "country_burundi"
            case countryCambodia = "country_cambodia"
            case countryCameroon = "country_cameroon"
            case countryCanada = "country_canada"
            case countryCapeVerde = "country_cape_verde"
            case countryCentralAfricanRepublic = "country_central_african_republic"
            case countryChad = "country_chad"
            case countryChile = "country_chile"
            case countryChina = "country_china"
            case countryColombia = "country_colombia"
            case countryComoros = "country_comoros"
            case countryCongo = "country_congo"
            case countryCongoTheDemocraticRepublic = "country_congo_the_democratic_republic"
            case countryCostaRica = "country_costa_rica"
            case countryCoteDivoire = "country_cote_divoire"
            case countryCroatia = "country_croatia"
            case countryCuba = "country_cuba"
            case countryCyprus = "country_cyprus"
            case countryCzechRepublic = "country_czech_republic"
            case countryDenmark = "country_denmark"
            case countryDjibouti = "country_djibouti"
            case countryDominica = "country_dominica"
            case countryDominicanRepublic = "country_dominican_republic"
            case countryEcuador = "country_ecuador"
            case countryEgypt = "country_egypt"
            case countryElSalvador = "country_el_salvador"
            case countryEquatorialGuinea = "country_equatorial_guinea"
            case countryEritrea = "country_eritrea"
            case countryEstonia = "country_estonia"
            case countryEthiopia = "country_ethiopia"
            case countryFiji = "country_fiji"
            case countryFinland = "country_finland"
            case countryFrance = "country_france"
            case countryGabon = "country_gabon"
            case countryGambia = "country_gambia"
            case countryGeorgia = "country_georgia"
            case countryGermany = "country_germany"
            case countryGhana = "country_ghana"
            case countryGreece = "country_greece"
            case countryGrenada = "country_grenada"
            case countryGuatemala = "country_guatemala"
            case countryGuinea = "country_guinea"
            case countryGuineaBissau = "country_guinea_bissau"
            case countryGuyana = "country_guyana"
            case countryHaiti = "country_haiti"
            case countryVaticanCity = "country_vatican_city"
            case countryHonduras = "country_honduras"
            case countryHungary = "country_hungary"
            case countryIceland = "country_iceland"
            case countryIndia = "country_india"
            case countryIndonesia = "country_indonesia"
            case countryIraq = "country_iraq"
            case countryIreland = "country_ireland"
            case countryIsrael = "country_israel"
            case countryItaly = "country_italy"
            case countryJamaica = "country_jamaica"
            case countryJapan = "country_japan"
            case countryJordan = "country_jordan"
            case countryKazakhstan = "country_kazakhstan"
            case countryKenya = "country_kenya"
            case countryKiribati = "country_kiribati"
            case countryNorthKorea = "country_north_korea"
            case countrySouthKorea = "country_south_korea"
            case countryKosovo = "country_kosovo"
            case countryKuwait = "country_kuwait"
            case countryKyrgyzstan = "country_kyrgyzstan"
            case countryLaos = "country_laos"
            case countryLatvia = "country_latvia"
            case countryLebanon = "country_lebanon"
            case countryLesotho = "country_lesotho"
            case countryLiberia = "country_liberia"
            case countryLibya = "country_libya"
            case countryLiechtenstein = "country_liechtenstein"
            case countryLithuania = "country_lithuania"
            case countryLuxembourg = "country_luxembourg"
            case countryNorthMacedonia = "country_north_macedonia"
            case countryMadagascar = "country_madagascar"
            case countryMalawi = "country_malawi"
            case countryMalaysia = "country_malaysia"
            case countryMaldives = "country_maldives"
            case countryMali = "country_mali"
            case countryMalta = "country_malta"
            case countryMarshallIslands = "country_marshall_islands"
            case countryMauritania = "country_mauritania"
            case countryMauritius = "country_mauritius"
            case countryMexico = "country_mexico"
            case countryMicronesia = "country_micronesia"
            case countryMoldova = "country_moldova"
            case countryMonaco = "country_monaco"
            case countryMongolia = "country_mongolia"
            case countryMontenegro = "country_montenegro"
            case countryMorocco = "country_morocco"
            case countryMozambique = "country_mozambique"
            case countryMyanmar = "country_myanmar"
            case countryNamibia = "country_namibia"
            case countryNauru = "country_nauru"
            case countryNepal = "country_nepal"
            case countryNetherlands = "country_netherlands"
            case countryNewZealand = "country_new_zealand"
            case countryNicaragua = "country_nicaragua"
            case countryNiger = "country_niger"
            case countryNigeria = "country_nigeria"
            case countryNorway = "country_norway"
            case countryOman = "country_oman"
            case countryPakistan = "country_pakistan"
            case countryPalau = "country_palau"
            case countryPanama = "country_panama"
            case countryPapuaNewGuinea = "country_papua_new_guinea"
            case countryParaguay = "country_paraguay"
            case countryPeru = "country_peru"
            case countryPhilippines = "country_philippines"
            case countryPoland = "country_poland"
            case countryPortugal = "country_portugal"
            case countryQatar = "country_qatar"
            case countryRomania = "country_romania"
            case countryRussianFederation = "country_russian_federation"
            case countryRwanda = "country_rwanda"
            case countrySaintKittsAndNevis = "country_saint_kitts_and_nevis"
            case countrySaintLucia = "country_saint_lucia"
            case countrySaintVincentAndTheGrenadines = "country_saint_vincent_and_the_grenadines"
            case countrySamoa = "country_samoa"
            case countrySANMarino = "country_san_marino"
            case countrySaoTomeAndPrincipe = "country_sao_tome_and_principe"
            case countrySaudiArabia = "country_saudi_arabia"
            case countrySenegal = "country_senegal"
            case countrySerbia = "country_serbia"
            case countrySeychelles = "country_seychelles"
            case countrySierraLeone = "country_sierra_leone"
            case countrySingapore = "country_singapore"
            case countrySlovakia = "country_slovakia"
            case countrySlovenia = "country_slovenia"
            case countrySolomonIslands = "country_solomon_islands"
            case countrySomalia = "country_somalia"
            case countrySouthAfrica = "country_south_africa"
            case countrySpain = "country_spain"
            case countrySriLanka = "country_sri_lanka"
            case countrySudan = "country_sudan"
            case countrySouthSudan = "country_south_sudan"
            case countrySuriname = "country_suriname"
            case countryEswatini = "country_eswatini"
            case countrySweden = "country_sweden"
            case countrySwitzerland = "country_switzerland"
            case countrySyria = "country_syria"
            case countryTaiwan = "country_taiwan"
            case countryTajikistan = "country_tajikistan"
            case countryTanzania = "country_tanzania"
            case countryThailand = "country_thailand"
            case countryTimorLeste = "country_timor_leste"
            case countryTogo = "country_togo"
            case countryTonga = "country_tonga"
            case countryTrinidadAndTobago = "country_trinidad_and_tobago"
            case countryTunisia = "country_tunisia"
            case countryTurkey = "country_turkey"
            case countryTurkmenistan = "country_turkmenistan"
            case countryTuvalu = "country_tuvalu"
            case countryUganda = "country_uganda"
            case countryUkraine = "country_ukraine"
            case countryUnitedArabEmirates = "country_united_arab_emirates"
            case countryUnitedKingdom = "country_united_kingdom"
            case countryUnitedStates = "country_united_states"
            case countryUruguay = "country_uruguay"
            case countryUzbekistan = "country_uzbekistan"
            case countryVanuatu = "country_vanuatu"
            case countryVenezuela = "country_venezuela"
            case countryVietnam = "country_vietnam"
            case countryYemen = "country_yemen"
            case countryZambia = "country_zambia"
            case countryZimbabwe = "country_zimbabwe"
            case purposes
            case specialPurposes = "special_purposes"
            case features
            case specialFeatures = "special_features"
            case privacyPolicy = "privacy_policy"
            case legalText = "legal_text"
            case maximumStorage = "maximum_storage"
            case preferenceRightsPhoneNumber = "preference_rights_phone_number"
            case preferenceRightsSelectStateProvince = "preference_rights_select_state_province"
            case preferenceRightsPostalCode = "preference_rights_postal_code"
            case preferenceRightsAddressLineOne = "preference_rights_address_line_one"
            case preferenceRightsAddressLineTwo = "preference_rights_address_line_two"
            case enterValidPhoneNumber = "enter_valid_phone_number"
            case of
            case iAmAAn = "i_am_a_an"
            case selectARelationship = "select_a_relationship"
            case tellUsAboutYourRelationshipToUs = "tell_us_about_your_relationship_to_us"
            case exIWorkedInTheItDepartmentIn2015 = "ex_i_worked_in_the_it_department_in_2015"
            case optedIn = "opted_in"
            case optedOut = "opted_out"
            case here
            case rightsTabPortholeRedirectFooter = "rights_tab_porthole_redirect_footer"
            case clickHere = "click_here"
            case rightsTabPortholeRedirectFooterAlt = "rights_tab_porthole_redirect_footer_alt"
            case pleaseSelectARequestType = "please_select_a_request_type"
            case greeting, provenance
        }
    }
}

#endif
