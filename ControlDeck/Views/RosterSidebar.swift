//
//  RosterSidebar.swift
//
//  The left column. Lists every model in the workspace with a status dot,
//  plus a "+ New model" row and a Library/Settings section.
//

import SwiftUI

struct RosterSidebar: View {
    @Environment(AppStore.self) private var store
    @Binding var showSettings: Bool

    var body: some View {
        List(selection: Binding<ModelProfile.ID?>(
            get: { store.selectedModelID },
            set: { id in if let id { store.select(model: id) } }
        )) {
            Section("Roster") {
                ForEach(store.roster) { model in
                    RosterRow(model: model)
                        .tag(model.id)
                }

                Button {
                    store.addNewModel()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.accentColor)
                        Text("New model")
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }

            Section("Library") {
                Label("Themes", systemImage: "paintpalette")
                    .badge("\(ThemePreset.all.count)")
                Label("Media", systemImage: "photo.on.rectangle")
                    .badge("142")
                Label("Templates", systemImage: "rectangle.stack")
            }

            Section("Workspace") {
                Button {
                    showSettings = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.plain)

                Label("Team", systemImage: "person.2")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Calling Card")
        .toolbar {
            ToolbarItem(placement: .principal) {
                BrandMark()
            }
        }
    }
}

struct BrandMark: View {
    var body: some View {
        HStack(spacing: 8) {
            Text("C")
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .italic()
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(LinearGradient.brandAI, in: RoundedRectangle(cornerRadius: 6))
            Text("Calling Card")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }
}

struct RosterRow: View {
    let model: ModelProfile

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)

            Text(model.stageName)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)

            Spacer(minLength: 0)

            Text(model.status.label)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var statusColor: Color {
        switch model.status {
        case .published:   return .brandPub
        case .draft:       return .brandWarn
        case .unpublished: return .secondary.opacity(0.5)
        }
    }
}
