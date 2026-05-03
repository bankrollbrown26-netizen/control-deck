//
//  ThemeGrid.swift
//
//  Adaptive grid of theme presets. Tapping a chip switches the
//  current model's theme (and updates the WKWebView preview live
//  via window.document.documentElement.dataset.theme).
//

import SwiftUI

struct ThemeGrid: View {
    @Environment(AppStore.self) private var store

    let columns = [GridItem(.adaptive(minimum: 130, maximum: 200), spacing: 10)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("THEME")
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    // Suggest from vibe — hands off to AI panel via the parent.
                    // For now, pick a random theme that complements the tagline.
                    let suggestion = ThemePreset.all.randomElement()!
                    store.updateCurrent { $0.themeID = suggestion.id }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "sparkles")
                        Text("Suggest from vibe")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandAISoft, in: Capsule())
                    .foregroundStyle(Color.brandAI)
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(ThemePreset.all) { theme in
                    ThemeChip(
                        theme: theme,
                        active: store.current.themeID == theme.id
                    ) {
                        withAnimation(.smooth(duration: 0.25)) {
                            store.updateCurrent { $0.themeID = theme.id }
                        }
                    }
                }
            }
        }
    }
}

struct ThemeChip: View {
    let theme: ThemePreset
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    theme.swatch
                        .frame(height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.white.opacity(0.10), lineWidth: 1)
                        )

                    if active {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(Color.accentColor, in: Circle())
                            .padding(6)
                    }
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(theme.name)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(theme.mood)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(active ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: active ? Color.accentColor.opacity(0.15) : .black.opacity(0.04),
                    radius: active ? 8 : 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}
