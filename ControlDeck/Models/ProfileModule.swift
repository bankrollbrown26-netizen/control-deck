//
//  ProfileModule.swift
//
//  A single section of a model's profile page (Hero, Vibe, Stats, etc.).
//  Order is editable via drag-and-drop; visibility is per-module.
//

import Foundation

struct ProfileModule: Identifiable, Hashable, Codable {
    var id: UUID             // var so we can clone with fresh UUIDs
    var key: String          // stable key — matches the data-module attribute on the public page
    var name: String         // display name, e.g. "Hero"
    var subtitle: String     // one-liner shown under the name
    var symbol: String       // SF Symbol used in the row
    var enabled: Bool

    static let defaults: [ProfileModule] = [
        .init(id: UUID(), key: "hero",      name: "Hero",            subtitle: "Cinematic card",     symbol: "rectangle.fill.on.rectangle.fill", enabled: true),
        .init(id: UUID(), key: "vibe",      name: "Signature Vibe",  subtitle: "Tone & palette",     symbol: "paintpalette",                     enabled: true),
        .init(id: UUID(), key: "stats",     name: "Stat Cards",      subtitle: "Animated counters",  symbol: "number.square",                    enabled: true),
        .init(id: UUID(), key: "gallery",   name: "Gallery",         subtitle: "Editorial moments",  symbol: "photo.on.rectangle.angled",        enabled: true),
        .init(id: UUID(), key: "nights",    name: "Featured Nights", subtitle: "Press & history",    symbol: "calendar.badge.clock",             enabled: true),
        .init(id: UUID(), key: "moodboard", name: "Moodboard",       subtitle: "Marquee strip",      symbol: "rectangle.split.3x1",              enabled: true),
        .init(id: UUID(), key: "quote",     name: "Quote Strip",     subtitle: "Pull-quote",         symbol: "quote.opening",                    enabled: true),
        .init(id: UUID(), key: "booking",   name: "Booking Funnel",  subtitle: "Brief → mailto",     symbol: "envelope",                         enabled: true),
        .init(id: UUID(), key: "social",    name: "Social Links",    subtitle: "Platform tiles",     symbol: "link",                             enabled: true),
        .init(id: UUID(), key: "footer",    name: "Footer / Legal",  subtitle: "Mark & links",       symbol: "text.append",                      enabled: true)
    ]
}
