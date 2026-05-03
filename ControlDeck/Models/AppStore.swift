//
//  AppStore.swift
//
//  Single source of truth. @Observable (iOS 17+) so every view that
//  reads from `store` re-renders automatically when state changes.
//
//  The persistence layer is intentionally simple — one JSON file
//  in Documents/. v2 swaps this for SwiftData or a remote backend.
//

import Foundation
import SwiftUI

enum Appearance: String, CaseIterable, Codable {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var label: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }
}

@Observable
final class AppStore {
    var roster: [ModelProfile]
    var selectedModelID: ModelProfile.ID
    var selectedModuleID: ProfileModule.ID
    var appearance: Appearance = .system

    /// Saved-state indicator shown in the publish bar.
    var saveState: SaveState = .saved(date: Date())

    enum SaveState {
        case saved(date: Date)
        case saving
        case error(String)

        var label: String {
            switch self {
            case .saved(let d):
                let f = RelativeDateTimeFormatter()
                f.unitsStyle = .short
                let s = f.localizedString(for: d, relativeTo: Date())
                return "Saved · \(s)"
            case .saving:
                return "Saving…"
            case .error(let e):
                return "Error: \(e)"
            }
        }
    }

    init() {
        let r = ModelProfile.samples
        self.roster = r
        self.selectedModelID = r[0].id
        self.selectedModuleID = r[0].modules[0].id
        load()
    }

    // MARK: - Selection

    var current: ModelProfile {
        get { roster.first(where: { $0.id == selectedModelID }) ?? roster[0] }
        set {
            guard let i = roster.firstIndex(where: { $0.id == newValue.id }) else { return }
            roster[i] = newValue
            markDirty()
        }
    }

    var currentModule: ProfileModule {
        get {
            current.modules.first(where: { $0.id == selectedModuleID }) ?? current.modules[0]
        }
    }

    func select(model id: ModelProfile.ID) {
        selectedModelID = id
        if let m = roster.first(where: { $0.id == id })?.modules.first {
            selectedModuleID = m.id
        }
    }

    func select(module id: ProfileModule.ID) { selectedModuleID = id }

    // MARK: - Mutations

    func updateCurrent(_ mutate: (inout ModelProfile) -> Void) {
        guard let i = roster.firstIndex(where: { $0.id == selectedModelID }) else { return }
        mutate(&roster[i])
        markDirty()
    }

    func toggleModule(_ id: ProfileModule.ID) {
        updateCurrent { p in
            if let mi = p.modules.firstIndex(where: { $0.id == id }) {
                p.modules[mi].enabled.toggle()
            }
        }
    }

    func moveModules(from source: IndexSet, to destination: Int) {
        updateCurrent { p in
            p.modules.move(fromOffsets: source, toOffset: destination)
        }
    }

    func addNewModel() {
        let p = ModelProfile(
            id: UUID(),
            stageName: "Untitled model",
            pronouns: "",
            tagline: "Tagline goes here.",
            bioShort: "",
            bioLong: "",
            homeBase: "",
            languages: "",
            ctaText: "Send a brief",
            bookingEmail: "",
            themeID: "velvet-noir",
            modules: ProfileModule.defaults.map { var m = $0; m.id = UUID(); return m },
            status: .draft
        )
        roster.append(p)
        selectedModelID = p.id
        selectedModuleID = p.modules[0].id
        markDirty()
    }

    func publish() {
        updateCurrent { $0.status = .published }
    }

    // MARK: - Persistence

    private var saveTask: Task<Void, Never>? = nil

    private func markDirty() {
        saveState = .saving
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            if Task.isCancelled { return }
            self.save()
            self.saveState = .saved(date: Date())
        }
    }

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("roster.json")
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(roster)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            saveState = .error(error.localizedDescription)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([ModelProfile].self, from: data),
              !decoded.isEmpty else { return }
        roster = decoded
        if let first = decoded.first {
            selectedModelID = first.id
            if let m = first.modules.first { selectedModuleID = m.id }
        }
    }
}
