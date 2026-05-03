//
//  SettingsSheet.swift
//
//  Workspace-level settings — appearance, AI provider key, version.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @AppStorage("anthropicAPIKey") private var apiKey: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { store.appearance },
                        set: { store.appearance = $0 }
                    )) {
                        ForEach(Appearance.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    SecureField("sk-ant-...", text: $apiKey)
                        .font(.system(size: 13, design: .monospaced))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Anthropic API key")
                } footer: {
                    Text("Used by the AI Panel for live generation. Stored on-device only.")
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0 (build 1)")
                    LabeledContent("Storage", value: "Local · Documents/")
                    Link(destination: URL(string: "https://callingcard.app")!) {
                        Label("callingcard.app", systemImage: "safari")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
