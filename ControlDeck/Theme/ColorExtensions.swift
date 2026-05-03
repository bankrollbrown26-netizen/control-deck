//
//  ColorExtensions.swift
//
//  Hex color initializer + a few brand-token convenience accessors.
//

import SwiftUI

extension Color {
    /// `.hex("8b5cf6")` — accepts 3, 4, 6, or 8 digit RGB / RGBA / RRGGBB / RRGGBBAA.
    static func hex(_ string: String) -> Color {
        var s = string.trimmingCharacters(in: .whitespacesAndNewlines)
                      .replacingOccurrences(of: "#", with: "")
        if s.count == 3 { s = s.map { "\($0)\($0)" }.joined() }
        if s.count == 4 { s = s.map { "\($0)\($0)" }.joined() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)

        let r, g, b, a: Double
        switch s.count {
        case 6:
            r = Double((v & 0xFF0000) >> 16) / 255
            g = Double((v & 0x00FF00) >> 8)  / 255
            b = Double( v & 0x0000FF)        / 255
            a = 1
        case 8:
            r = Double((v & 0xFF000000) >> 24) / 255
            g = Double((v & 0x00FF0000) >> 16) / 255
            b = Double((v & 0x0000FF00) >> 8)  / 255
            a = Double( v & 0x000000FF)        / 255
        default:
            r = 1; g = 0; b = 1; a = 1   // hot pink fallback so mistakes are obvious
        }
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    // MARK: - Brand tokens
    static let brandAI       = Color.hex("8b5cf6")
    static let brandAISoft   = Color.hex("8b5cf6").opacity(0.12)
    static let brandPub      = Color.hex("16a34a")
    static let brandPubSoft  = Color.hex("16a34a").opacity(0.14)
    static let brandWarn     = Color.hex("d97706")
    static let brandWarnSoft = Color.hex("d97706").opacity(0.14)
}

extension LinearGradient {
    /// The brand AI gradient used by the app icon, the ✦ glyph, and AI panel header.
    static let brandAI = LinearGradient(
        colors: [.hex("8b5cf6"), .hex("ec4899"), .hex("f59e0b")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
