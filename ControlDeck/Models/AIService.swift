//
//  AIService.swift
//
//  Mock generator for the AI Panel. Returns the same canned drafts the
//  web demo uses so the app works offline and during App Store review.
//
//  To enable real Claude generation: drop an API key in Settings,
//  swap the body of `generate(_:for:)` with a URLSession call to
//  https://api.anthropic.com/v1/messages with the system prompt from
//  ARCHITECTURE.md §10. The shape of `AIResult` matches what Claude
//  returns.
//

import Foundation

enum AITask: String, CaseIterable, Identifiable {
    case tagline
    case bioShort         = "bio.short"
    case bioLong          = "bio.long"
    case galleryCaptions  = "gallery.captions"
    case themeSuggest     = "theme.suggest"
    case ctaRewrite       = "cta.rewrite"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .tagline:          return "Tagline"
        case .bioShort:         return "Short bio"
        case .bioLong:          return "Long bio"
        case .galleryCaptions:  return "Gallery captions"
        case .themeSuggest:     return "Suggest theme"
        case .ctaRewrite:       return "Rewrite CTA"
        }
    }

    var subtitle: String {
        switch self {
        case .tagline:          return "A magnetic single line"
        case .bioShort:         return "2 sentences, editorial voice"
        case .bioLong:          return "1 paragraph, brand-paper voice"
        case .galleryCaptions:  return "From image moods + alts"
        case .themeSuggest:     return "Match palette to your tone"
        case .ctaRewrite:       return "3 voices · pick & refine"
        }
    }

    var symbol: String {
        switch self {
        case .tagline:          return "sparkles"
        case .bioShort:         return "text.alignleft"
        case .bioLong:          return "text.justify"
        case .galleryCaptions:  return "photo.stack"
        case .themeSuggest:     return "paintpalette"
        case .ctaRewrite:       return "arrow.up.right.square"
        }
    }
}

struct AIResult: Identifiable, Hashable {
    let id = UUID()
    let task: AITask
    let text: String
}

@MainActor
final class AIService {
    static let shared = AIService()

    /// Async — returns a single draft. Swap with a real API call later.
    func generate(_ task: AITask, for model: ModelProfile) async -> AIResult {
        // Simulate latency
        try? await Task.sleep(nanoseconds: 700_000_000)

        let pool: [String]
        switch task {
        case .tagline:
            pool = [
                "After-hours sound director. Vinyl & velvet.",
                "Builds rooms that read like film.",
                "Late-night architecture in sound and light.",
                "A cinematic ear. A residency in the dark.",
                "Long-form nights. Score-led. Quietly precise."
            ]
        case .bioShort:
            pool = [
                "Sound director and editorial muse working between Miami, Lisbon, and the late hours. Builds rooms that feel like film.",
                "DJ and editorial fixture. Slow-burn openings, cinematic peaks. Resident at Velvet Sessions, Miami.",
                "An after-hours architect — vinyl, velvet, and a lighting plot you remember in the morning."
            ]
        case .bioLong:
            pool = [
                "\(model.stageName) is a DJ and editorial fixture whose sets read like reels — slow-burn openings, midnight peaks, bookended in cinematic strings. Resident at Velvet Sessions Miami; recent press includes WAX issue 11 and Houses & Hours Lisbon.",
                "Working between \(model.homeBase.isEmpty ? "Miami and Lisbon" : model.homeBase), \(model.stageName) builds long-form rooms that feel less like nightclubs and more like films you walk into. Vinyl-first, score-led, and quietly precise."
            ]
        case .galleryCaptions:
            pool = [
                """
                tile 01 — "Last set, 04:12 — house lights still down."
                tile 02 — "Vinyl wall, Lisbon — three crates deep."
                tile 03 — "WAX, issue 11 — cover sit, March."
                tile 04 — "Velvet Sessions, vol. 04."
                tile 05 — "Houses & Hours, runway dinner."
                tile 06 — "Studio, 7:00 a.m. — third coffee."
                """
            ]
        case .themeSuggest:
            pool = [
                "Best match: Velvet Noir — your tone reads slow, cinematic, late-hours. Runner-up: Goth Luxe (more candlelight) or Champagne Muse (softer).",
                "Recommended: Goth Luxe — long sets, vinyl-led, editorial press. Runner-up: Velvet Noir."
            ]
        case .ctaRewrite:
            pool = [
                """
                1. Request the deck
                2. Open a brief
                3. Send a date
                """,
                """
                1. Talk dates
                2. Get the deck
                3. Make it official
                """
            ]
        }

        let text = pool.randomElement() ?? pool[0]
        return AIResult(task: task, text: text)
    }
}
