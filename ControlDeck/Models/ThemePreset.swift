//
//  ThemePreset.swift
//
//  The 10 preset themes — mirrors /themes.json from the web project.
//  We only carry the visible-here surface (gradient + label + mood).
//  The full color/typography/motion config still lives in the web bundle
//  that the WKWebView preview loads.
//

import SwiftUI

struct ThemePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let mood: String
    let gradient: [Color]

    static let all: [ThemePreset] = [
        .init(id: "velvet-noir",     name: "Velvet Noir",     mood: "slow · cinematic",
              gradient: [.hex("0d0d12"), .hex("3a1f2e"), .hex("a07550")]),
        .init(id: "champagne-muse",  name: "Champagne Muse",  mood: "soft · golden",
              gradient: [.hex("f4ebd9"), .hex("d9c08b"), .hex("9c7641")]),
        .init(id: "neon-siren",      name: "Neon Siren",      mood: "electric · pulse",
              gradient: [.hex("0a0014"), .hex("7a008a"), .hex("ff2da8")]),
        .init(id: "miami-heat",      name: "Miami Heat",      mood: "sun · neon",
              gradient: [.hex("ff7e5f"), .hex("feb47b"), .hex("7afcff")]),
        .init(id: "ice-queen",       name: "Ice Queen",       mood: "crisp · sculptural",
              gradient: [.hex("e8f0f7"), .hex("a4c2dc"), .hex("5d7c9f")]),
        .init(id: "dark-rose",       name: "Dark Rose",       mood: "smoldering",
              gradient: [.hex("1c0a10"), .hex("4a1525"), .hex("b14660")]),
        .init(id: "runway-angel",    name: "Runway Angel",    mood: "white · pristine",
              gradient: [.hex("ffffff"), .hex("f1eaea"), .hex("dcccd0")]),
        .init(id: "goth-luxe",       name: "Goth Luxe",       mood: "candlelit",
              gradient: [.hex("000000"), .hex("1a0408"), .hex("5a0a14")]),
        .init(id: "golden-hour",     name: "Golden Hour",     mood: "amber · warm",
              gradient: [.hex("3a1c0a"), .hex("a06030"), .hex("ffc784")]),
        .init(id: "pop-star",        name: "Pop Star",        mood: "bright · bouncy",
              gradient: [.hex("ff5dc8"), .hex("ffd84d"), .hex("5dd6ff")])
    ]

    static func with(id: String) -> ThemePreset {
        all.first(where: { $0.id == id }) ?? all[0]
    }

    var swatch: LinearGradient {
        LinearGradient(colors: gradient,
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
}
