//
//  Config.swift
//  KetchSDK
//

import Foundation

extension KetchSDK {
    public struct Configuration: Codable {
        public let experiences: Experience?
        public let theme: Theme?
        
        //Legacy
        public let rights: [Right]?
        public let jurisdiction: Jurisdiction?
        public let purposes: [Purpose]?
    }
}

extension KetchSDK.Configuration {
    public struct Experience: Codable {
        public let content: ContentConfig?
        
        public struct ContentConfig: Codable {
            public let display: ContentDisplay?
        }
        
        public enum ContentDisplay: String, Codable {
            case banner, modal
        }
    }

    
    public struct Theme: Codable {
        let banner: BannerConfig?
        let modal: ModalConfig?
    }
    
    public struct BannerConfig: Codable {
        let container: BannerContainerConfig?
    }
    
    public struct BannerContainerConfig: Codable {
        let position: Position?
        let size: Size?
        let backdrop: Backdrop
        
        public enum Position: String, Codable {
            case bottom, top, leftCorner, rightCorner, bottomMiddle, center
        }
        
        public enum Size: String, Codable {
            case standard, compact
        }
    }
    
    public struct ModalConfig: Codable {
        let container: ModalContainerConfig?
    }
    
    public struct ModalContainerConfig: Codable {
        let position: Position?
        let backdrop: Backdrop
        
        public enum Position: String, Codable {
            case left, right, center
        }
    }
    
    public struct Backdrop: Codable {
        let disableContentInteractions: Bool
    }
}

//Legacy
extension KetchSDK.Configuration {
    public struct Right: Codable {
        public let code: String?
        public let name: String?
        public let description: String?
    }
    
    public struct Jurisdiction: Codable {
        public let code: String?
        public let defaultJurisdictionCode: String?
        public let variable: String?
        public let jurisdictions: [String: String]?
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
            public let name: String?
            public let description: String?
            public let retentionPeriod: String?
            public let externalTransfers: String?
        }
    }
}
