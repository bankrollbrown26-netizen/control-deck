//
//  ModelProfile.swift
//
//  One model's calling-card profile. Everything is editable inside
//  the EditorView. A single concrete type rather than a tree of
//  module-specific types — simpler for the demo, easy to migrate
//  to a Codable JSON file later (mirrors model.example.json on the web side).
//

import Foundation

enum PublishStatus: String, Codable {
    case published, draft, unpublished

    var label: String {
        switch self {
        case .published:   return "PUB"
        case .draft:       return "DRAFT"
        case .unpublished: return "—"
        }
    }
}

struct ModelProfile: Identifiable, Hashable, Codable {
    let id: UUID
    var stageName: String
    var pronouns: String
    var tagline: String
    var bioShort: String
    var bioLong: String
    var homeBase: String
    var languages: String
    var ctaText: String
    var bookingEmail: String
    var themeID: String
    var modules: [ProfileModule]
    var status: PublishStatus

    var slug: String {
        stageName
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }

    var publicURL: String { "callingcard.app/\(slug)" }

    static let samples: [ModelProfile] = [
        ModelProfile(
            id: UUID(),
            stageName: "Nova Vellichor",
            pronouns: "she/her",
            tagline: "After-hours sound director. Vinyl & velvet.",
            bioShort: "Sound director and editorial muse working between Miami, Lisbon, and the late hours. Builds rooms that feel like film.",
            bioLong: "Nova Vellichor is a DJ and editorial fixture whose sets read like reels — slow-burn openings, midnight peaks, bookended in cinematic strings. She hosts the Velvet Sessions residency and has fronted campaigns for three independent fashion houses across the Atlantic corridor.",
            homeBase: "Miami × Lisbon",
            languages: "EN · PT · ES",
            ctaText: "Request the deck",
            bookingEmail: "bookings@novavellichor.studio",
            themeID: "velvet-noir",
            modules: ProfileModule.defaults,
            status: .published
        ),
        ModelProfile(
            id: UUID(),
            stageName: "Solenne Mirae",
            pronouns: "she/her",
            tagline: "Editorial movement. Studio nights.",
            bioShort: "Movement director and dance-floor architect. Soft tempos, sharp edges.",
            bioLong: "Solenne Mirae composes choreography for runway and music video. Her residencies are slower, quieter, more deliberate — a reading of the room before the room knows it's being read.",
            homeBase: "Lisbon",
            languages: "PT · EN · FR",
            ctaText: "Open a brief",
            bookingEmail: "studio@solennemirae.co",
            themeID: "champagne-muse",
            modules: ProfileModule.defaults,
            status: .draft
        ),
        ModelProfile(
            id: UUID(),
            stageName: "Riva Cassel",
            pronouns: "they/them",
            tagline: "Late-night architecture. Vinyl-led.",
            bioShort: "Selector and resident at WAX, Berlin. Long form. Quiet build. Big finish.",
            bioLong: "Riva Cassel runs the WAX residency in Berlin and tours selectively across Europe. Sets are vinyl-only, two decks, and tend to clock past four hours. Press features include LWE issue 38 and Resident Advisor's 2025 review of the Berghain Säule guest mix.",
            homeBase: "Berlin",
            languages: "EN · DE",
            ctaText: "Send a date",
            bookingEmail: "rc@wax.berlin",
            themeID: "goth-luxe",
            modules: ProfileModule.defaults,
            status: .published
        ),
        ModelProfile(
            id: UUID(),
            stageName: "Iyari North",
            pronouns: "she/they",
            tagline: "Sun-bleached. Studio-trained.",
            bioShort: "Editorial face and sound producer. Bright work, brighter tempos.",
            bioLong: "Iyari North splits time between Mexico City and LA, fronting beauty campaigns and producing original score work for short film.",
            homeBase: "CDMX × LA",
            languages: "ES · EN",
            ctaText: "Talk dates",
            bookingEmail: "iyari@northstudio.mx",
            themeID: "pop-star",
            modules: ProfileModule.defaults,
            status: .unpublished
        )
    ]
}
