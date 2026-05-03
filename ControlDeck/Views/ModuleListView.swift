//
//  ModuleListView.swift
//
//  Middle column. Shows the current model's modules as a List with
//  built-in drag-to-reorder (.onMove) and per-row eye toggles. Tapping
//  a row selects it for editing in the detail column.
//

import SwiftUI

struct ModuleListView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        List(selection: Binding<ProfileModule.ID?>(
            get: { store.selectedModuleID },
            set: { id in if let id { store.select(module: id) } }
        )) {
            Section {
                // Header card — shows the current model.
                ModelHeaderCard(model: store.current)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 12, trailing: 0))
                    .listRowSeparator(.hidden)
            }

            Section {
                ForEach(store.current.modules) { module in
                    ModuleRow(module: module)
                        .tag(module.id)
                }
                .onMove { source, dest in
                    store.moveModules(from: source, to: dest)
                }
            } header: {
                HStack {
                    Text("Modules")
                    Spacer()
                    Text("\(store.current.modules.filter(\.enabled).count) / \(store.current.modules.count)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .environment(\.editMode, .constant(.active))     // always-on drag handles
        .navigationTitle(store.current.stageName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Model header card

struct ModelHeaderCard: View {
    let model: ModelProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ThemePreset.with(id: model.themeID).swatch
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.stageName)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .italic()
                        .lineLimit(1)
                    Text(model.publicURL)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                StatusPill(status: model.status)
                ThemeChipMini(themeID: model.themeID)
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 16)
    }
}

struct StatusPill: View {
    let status: PublishStatus

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color.opacity(0.55), radius: 3)
            Text(text)
                .font(.system(size: 10.5, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.14), in: Capsule())
        .foregroundStyle(color)
    }

    private var text: String {
        switch status {
        case .published:   return "Published"
        case .draft:       return "Draft"
        case .unpublished: return "Unpublished"
        }
    }
    private var color: Color {
        switch status {
        case .published:   return .brandPub
        case .draft:       return .brandWarn
        case .unpublished: return .secondary
        }
    }
}

struct ThemeChipMini: View {
    let themeID: String
    var body: some View {
        let t = ThemePreset.with(id: themeID)
        HStack(spacing: 6) {
            t.swatch
                .frame(width: 14, height: 14)
                .clipShape(Circle())
            Text(t.name)
                .font(.system(size: 10.5, weight: .medium))
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.thinMaterial, in: Capsule())
    }
}

// MARK: - Module row

struct ModuleRow: View {
    @Environment(AppStore.self) private var store
    let module: ProfileModule

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: module.symbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(module.enabled ? Color.primary : Color.secondary.opacity(0.5))
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(module.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(module.enabled ? Color.primary : Color.secondary)
                Text(module.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Visibility toggle
            Button {
                store.toggleModule(module.id)
            } label: {
                Image(systemName: module.enabled ? "eye" : "eye.slash")
                    .foregroundStyle(module.enabled ? .brandPub : .secondary)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .opacity(module.enabled ? 1.0 : 0.6)
    }
}
