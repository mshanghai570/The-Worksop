//
//  Models/ProjectTargetType.swift
//  TheWorkshop-iOS
//

import Foundation

public enum ProjectTargetType: String, Codable, CaseIterable, Identifiable {
    case jailbreakTweak = "jailbreak_tweak"
    case jailedMod = "jailed_mod"
    case nativeExtension = "native_extension"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .jailbreakTweak: return "Jailbreak Tweak (Theos)"
        case .jailedMod: return "Jailed Mod (IPA Patch)"
        case .nativeExtension: return "Native Extension (Swift)"
        }
    }

    public var badgeColorHex: String {
        switch self {
        case .jailbreakTweak: return "#39FF14"
        case .jailedMod: return "#FF007F"
        case .nativeExtension: return "#00E676"
        }
    }
}
