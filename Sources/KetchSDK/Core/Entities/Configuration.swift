//
//  Config.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct Configuration: Codable {
        public let language: String?
        public let organization: Organization?
        public let property: Property?
        public let environments: [Environment]?
        public let jurisdiction: Jurisdiction?
        public let identities: [String: Identity]?
        public let scripts: [String]?
        public let environment: Environment?
        public let deployment: Deployment?
        public let privacyPolicy: Policy?
        public let termsOfService: Policy?
        public let rights: [Right]?
        public let regulations: [String]?
        public let theme: Theme?
        public let experiences: Experience?
        public let purposes: [Purpose]?
        public let canonicalPurposes: [String: CanonicalPurpose]?
        public let services: [String: String]?
        public let options: [String: String]?
        public let legalBases: [LegalBase]?
        public let vendors: [Vendor]?
        public let translations: Translations?
    }
}

extension KetchSDK.Configuration {
    public struct Organization: Codable {
        public let code: String?
    }

    public struct Property: Codable {
        public let code: String?
        public let name: String?
        public let platform: String?
    }

    public struct Environment: Codable {
        public let code: String?
        public let pattern: String?
        public let hash: String?
    }

    public struct Jurisdiction: Codable {
        public let code: String?
        public let defaultJurisdictionCode: String?
        public let variable: String?
        public let jurisdictions: [String: String]?
    }

    public struct Identity: Codable {
        public let type: String?
        public let variable: String?
        public let jwtKey: String?
        public let jwtLocation: Int?
    }

    public struct Deployment: Codable {
        public let code: String?
        public let version: Int?
    }

    public struct Policy: Codable {
        public let code: String?
        public let version: Int?
        public let url: String?
    }

    public struct Right: Codable {
        public let code: String
        public let name: String
        public let description: String
    }

    public struct Theme: Codable {
        public let code: String?
        public let name: String?
        public let description: String?

        public let watermark: Bool?

        public let buttonBorderRadius: Int?

        public let bannerBackgroundColor: String?
        public var bannerContentColor: String?
        public let bannerButtonColor: String?
        public let bannerSecondaryButtonColor: String?
        public let bannerSecondaryButtonVariant: String?
        public let bannerPosition: BannerPosition?

        public let modalHeaderBackgroundColor: String?
        public let modalHeaderContentColor: String?
        public var modalContentColor: String?
        public let modalButtonColor: String?
        public let modalPosition: ModalPosition?
        public var modalSwitchOffColor: String?
        public var modalSwitchOnColor: String?

        public let lightboxRibbonColor: String?
        public let formHeaderColor: String?
        public let statusColor: String?
        public let highlightColor: String?
        public let feedbackColor: String?
        public let font: String?

        public let formHeaderBackgroundColor: String?
        public var formHeaderContentColor: String?
        public let formContentColor: String?
        public let formButtonColor: String?
        public var formSwitchOffColor: String?
        public var formSwitchOnColor: String?

        public enum BannerPosition: Int, Codable {
            case UNKNOWN = 0
            case BOTTOM = 1
            case TOP = 2
            case BOTTOM_LEFT = 3
            case BOTTOM_RIGHT = 4
        }

        public enum ModalPosition: Int, Codable {
            case UNKNOWN = 0
            case CENTER = 1
            case LEFT_FULL_HEIGHT = 2
            case RIGHT_FULL_HEIGHT = 3
        }
        
        public let purposeButtonsLookIdentical: Bool?
    }

    public struct Experience: Codable {
        public let consent: ConsentExperience?
        public let preference: PreferenceExperience?

        public struct ConsentExperience: Codable {
            public let code: String
            public let version: Int
            public let banner: Banner
            public let modal: Modal
            public let jit: JIT?
            public let experienceDefault: ExperienceDefault

            public struct Banner: Codable {
                public let title: String?
                public let footerDescription: String
                public let buttonText: String
                public let primaryButtonAction: ExperiencePrimaryButtonAction?
                public let secondaryButtonText: String?
                public let secondaryButtonDestination: ExperienceButtonDestination?
            }

            public enum ExperiencePrimaryButtonAction: Int, Codable {
                case saveCurrentState = 1
                case acceptAll = 2
            }

            public enum ExperienceButtonDestination: Int, Codable {
                case gotoModal = 1
                case gotoPreference = 2
                case rejectAll = 3
            }

            public struct Modal: Codable {
                public let title: String
                public let bodyTitle: String?
                public let bodyDescription: String?
                public let buttonText: String

                public let showCloseIcon: Bool?
                public let consentTitle: String?
                public let hideConsentTitle: Bool?
                public let hideLegalBases: Bool?
                public let extensions: [String: String]?
            }

            public struct JIT: Codable {
                public let title: String?
                public let showCloseIcon: Bool?
                public let bodyDescription: String?
                public let acceptButtonText: String
                public let declineButtonText: String
                public let moreInfoText: String?
                public let moreInfoDestination: ExperienceButtonDestination?
            }

            public enum ExperienceDefault: Int, Codable {
                case banner = 1
                case modal
            }
        }
    }

    public struct PreferenceExperience: Codable {
        public let code: String
        public let version: Int
        public let title: String
        public let rights: RightsTab?
        public let consents: ConsentsTab
        public let overview: OverviewTab

        public struct RightsTab: Codable {
            public let tabName: String
            public let bodyTitle: String?
            public let bodyDescription: String?
            public let buttonText: String
        }

        public struct ConsentsTab: Codable {
            public let tabName: String
            public let bodyTitle: String?
            public let bodyDescription: String?
            public let buttonText: String
            public let hideConsentTitle: Bool
            public let hideLegalBases: Bool
        }

        public struct OverviewTab: Codable {
            public let tabName: String
            public let bodyTitle: String?
            public let bodyDescription: String
        }
    }

    public struct Purpose: Codable {
        public let code: String
        public let name: String?
        public let description: String?
        public let legalBasisCode: String
        public let requiresPrivacyPolicy: Bool?
        public let requiresOptIn: Bool?
        public let allowsOptOut: Bool?
        public let requiresDisplay: Bool?
        public let categories: [PurposeCategory]?
        public let tcfType: String?
        public let tcfID: String?
        public let canonicalPurposeCode: String?
        public let legalBasisName: String?
        public let legalBasisDescription: String?

        public struct PurposeCategory: Codable {
            public let name: String
            public let description: String
            public let retentionPeriod: String
            public let externalTransfers: String
        }
    }

    public struct CanonicalPurpose: Codable {
        public let code: String?
        public let name: String?
        public let purposeCodes: [String]?
    }

    public struct LegalBase: Codable {
        public let code: String?
        public let name: String?
        public let description: String?
    }

    public struct Vendor: Codable {
        public let id: String
        public let name: String
        public let purposes: [VendorPurpose]?
        public let specialPurposes: [VendorPurpose]?
        public let features: [VendorPurpose]?
        public let specialFeatures: [VendorPurpose]?
        public let policyUrl: String?
        public let cookieMaxAgeSeconds: Int?
        public let usesCookies: Bool?
        public let usesNonCookieAccess: Bool?

        public struct VendorPurpose: Codable {
            public let name: String
            public let legalBasis: String?
        }
    }
    
    public struct Translations: Codable {
        let accept, acceptAll, category, clickHere: String
        let cookie, cookies, countryAfghanistan, countryAlbania: String
        let countryAlgeria, countryAndorra, countryAngola, countryAntiguaAndBarbuda: String
        let countryArgentina, countryArmenia, countryAustralia, countryAustria: String
        let countryAzerbaijan, countryBahamas, countryBahrain, countryBangladesh: String
        let countryBarbados, countryBelarus, countryBelgium, countryBelize: String
        let countryBenin, countryBhutan, countryBolivia, countryBosniaAndHerzegovina: String
        let countryBotswana, countryBrazil, countryBruneiDarussalam, countryBulgaria: String
        let countryBurkinaFaso, countryBurundi, countryCambodia, countryCameroon: String
        let countryCanada, countryCapeVerde, countryCentralAfricanRepublic, countryChad: String
        let countryChile, countryChina, countryColombia, countryComoros: String
        let countryCongo, countryCongoTheDemocraticRepublic, countryCostaRica, countryCoteDivoire: String
        let countryCroatia, countryCuba, countryCyprus, countryCzechRepublic: String
        let countryDenmark, countryDjibouti, countryDominica, countryDominicanRepublic: String
        let countryEcuador, countryEgypt, countryElSalvador, countryEquatorialGuinea: String
        let countryEritrea, countryEstonia, countryEswatini, countryEthiopia: String
        let countryFiji, countryFinland, countryFrance, countryGabon: String
        let countryGambia, countryGeorgia, countryGermany, countryGhana: String
        let countryGreece, countryGrenada, countryGuatemala, countryGuinea: String
        let countryGuineaBissau, countryGuyana, countryHaiti, countryHonduras: String
        let countryHungary, countryIceland, countryIndia, countryIndonesia: String
        let countryIraq, countryIreland, countryIsrael, countryItaly: String
        let countryJamaica, countryJapan, countryJordan, countryKazakhstan: String
        let countryKenya, countryKiribati, countryKosovo, countryKuwait: String
        let countryKyrgyzstan, countryLaos, countryLatvia, countryLebanon: String
        let countryLesotho, countryLiberia, countryLibya, countryLiechtenstein: String
        let countryLithuania, countryLuxembourg, countryMadagascar, countryMalawi: String
        let countryMalaysia, countryMaldives, countryMali, countryMalta: String
        let countryMarshallIslands, countryMauritania, countryMauritius, countryMexico: String
        let countryMicronesia, countryMoldova, countryMonaco, countryMongolia: String
        let countryMontenegro, countryMorocco, countryMozambique, countryMyanmar: String
        let countryNamibia, countryNauru, countryNepal, countryNetherlands: String
        let countryNewZealand, countryNicaragua, countryNiger, countryNigeria: String
        let countryNorthKorea, countryNorthMacedonia, countryNorway, countryOman: String
        let countryPakistan, countryPalau, countryPanama, countryPapuaNewGuinea: String
        let countryParaguay, countryPeru, countryPhilippines, countryPoland: String
        let countryPortugal, countryQatar, countryRomania, countryRussianFederation: String
        let countryRwanda, countrySaintKittsAndNevis, countrySaintLucia, countrySaintVincentAndTheGrenadines: String
        let countrySamoa, countrySANMarino, countrySaoTomeAndPrincipe, countrySaudiArabia: String
        let countrySenegal, countrySerbia, countrySeychelles, countrySierraLeone: String
        let countrySingapore, countrySlovakia, countrySlovenia, countrySolomonIslands: String
        let countrySomalia, countrySouthAfrica, countrySouthKorea, countrySouthSudan: String
        let countrySpain, countrySriLanka, countrySudan, countrySuriname: String
        let countrySweden, countrySwitzerland, countrySyria, countryTaiwan: String
        let countryTajikistan, countryTanzania, countryThailand, countryTimorLeste: String
        let countryTogo, countryTonga, countryTrinidadAndTobago, countryTunisia: String
        let countryTurkey, countryTurkmenistan, countryTuvalu, countryUganda: String
        let countryUkraine, countryUnitedArabEmirates, countryUnitedKingdom, countryUnitedStates: String
        let countryUruguay, countryUzbekistan, countryVanuatu, countryVaticanCity: String
        let countryVenezuela, countryVietnam, countryYemen, countryZambia: String
        let countryZimbabwe, dataCategories, dataCategory, description: String
        let duration, enterValidEmail, enterValidPhoneNumber, exIWorkedInTheItDepartmentIn2015: String
        let externalTransfer, features, firstParty, functional: String
        let greeting, here, iAmAAn, legalBasis: String
        let legalText, marketing, maximumStorage, of: String
        let optedIn, optedOut, performance, persistent: String
        let pleaseSelectARequestType, poweredBy, preferenceConsentsExitButtonText, preferenceOverviewButtonText: String
        let preferenceRightsAddressLineOne, preferenceRightsAddressLineTwo, preferenceRightsCancelButtonText, preferenceRightsCountry: String
        let preferenceRightsEmail, preferenceRightsExitButtonText, preferenceRightsFirstName, preferenceRightsLastName: String
        let preferenceRightsPersonalDetails, preferenceRightsPhoneNumber, preferenceRightsPostalCode, preferenceRightsRequest: String
        let preferenceRightsRequestDetails, preferenceRightsSelectCountry, preferenceRightsSelectStateProvince, preferenceRightsState: String
        let preferenceRightsSubmitNewRequest, preferenceRightsThankYou, preferenceRightsWeHaveReceived, privacyPolicy: String
        let provenance, purpose, purposes, rejectAll: String
        let stringsRequired, retentionPeriod, rightsTabPortholeRedirectFooter, rightsTabPortholeRedirectFooterAlt: String
        let selectARelationship, serviceProvider, session, specialFeatures: String
        let specialPurposes, strictlyNecessary, tellUsAboutYourRelationshipToUs, thirdParty: String
        let vendor, vendors: String

        enum CodingKeys: String, CodingKey {
            case accept
            case acceptAll = "accept_all"
            case category
            case clickHere = "click_here"
            case cookie, cookies
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
            case countryEswatini = "country_eswatini"
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
            case countryNorthKorea = "country_north_korea"
            case countryNorthMacedonia = "country_north_macedonia"
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
            case countrySouthKorea = "country_south_korea"
            case countrySouthSudan = "country_south_sudan"
            case countrySpain = "country_spain"
            case countrySriLanka = "country_sri_lanka"
            case countrySudan = "country_sudan"
            case countrySuriname = "country_suriname"
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
            case countryVaticanCity = "country_vatican_city"
            case countryVenezuela = "country_venezuela"
            case countryVietnam = "country_vietnam"
            case countryYemen = "country_yemen"
            case countryZambia = "country_zambia"
            case countryZimbabwe = "country_zimbabwe"
            case dataCategories = "data_categories"
            case dataCategory = "data_category"
            case description, duration
            case enterValidEmail = "enter_valid_email"
            case enterValidPhoneNumber = "enter_valid_phone_number"
            case exIWorkedInTheItDepartmentIn2015 = "ex_i_worked_in_the_it_department_in_2015"
            case externalTransfer = "external_transfer"
            case features
            case firstParty = "first_party"
            case functional, greeting, here
            case iAmAAn = "i_am_a_an"
            case legalBasis = "legal_basis"
            case legalText = "legal_text"
            case marketing
            case maximumStorage = "maximum_storage"
            case of
            case optedIn = "opted_in"
            case optedOut = "opted_out"
            case performance, persistent
            case pleaseSelectARequestType = "please_select_a_request_type"
            case poweredBy = "powered_by"
            case preferenceConsentsExitButtonText = "preference_consents_exit_button_text"
            case preferenceOverviewButtonText = "preference_overview_button_text"
            case preferenceRightsAddressLineOne = "preference_rights_address_line_one"
            case preferenceRightsAddressLineTwo = "preference_rights_address_line_two"
            case preferenceRightsCancelButtonText = "preference_rights_cancel_button_text"
            case preferenceRightsCountry = "preference_rights_country"
            case preferenceRightsEmail = "preference_rights_email"
            case preferenceRightsExitButtonText = "preference_rights_exit_button_text"
            case preferenceRightsFirstName = "preference_rights_first_name"
            case preferenceRightsLastName = "preference_rights_last_name"
            case preferenceRightsPersonalDetails = "preference_rights_personal_details"
            case preferenceRightsPhoneNumber = "preference_rights_phone_number"
            case preferenceRightsPostalCode = "preference_rights_postal_code"
            case preferenceRightsRequest = "preference_rights_request"
            case preferenceRightsRequestDetails = "preference_rights_request_details"
            case preferenceRightsSelectCountry = "preference_rights_select_country"
            case preferenceRightsSelectStateProvince = "preference_rights_select_state_province"
            case preferenceRightsState = "preference_rights_state"
            case preferenceRightsSubmitNewRequest = "preference_rights_submit_new_request"
            case preferenceRightsThankYou = "preference_rights_thank_you"
            case preferenceRightsWeHaveReceived = "preference_rights_we_have_received"
            case privacyPolicy = "privacy_policy"
            case provenance, purpose, purposes
            case rejectAll = "reject_all"
            case stringsRequired = "required"
            case retentionPeriod = "retention_period"
            case rightsTabPortholeRedirectFooter = "rights_tab_porthole_redirect_footer"
            case rightsTabPortholeRedirectFooterAlt = "rights_tab_porthole_redirect_footer_alt"
            case selectARelationship = "select_a_relationship"
            case serviceProvider = "service_provider"
            case session
            case specialFeatures = "special_features"
            case specialPurposes = "special_purposes"
            case strictlyNecessary = "strictly_necessary"
            case tellUsAboutYourRelationshipToUs = "tell_us_about_your_relationship_to_us"
            case thirdParty = "third_party"
            case vendor, vendors
        }
    }
}
