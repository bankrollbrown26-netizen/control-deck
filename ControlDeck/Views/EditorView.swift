//
//  EditorView.swift
//
//  Right column. Renders fields appropriate to the selected module
//  (Hero gets stage name/tagline/bio, Booking gets CTA + email, etc.)
//  plus the theme grid (reachable from any module) and a sticky
//  publish bar at the bottom.
//

import SwiftUI

struct EditorView: View {
    @Environment(AppStore.self) private var store
    @Binding var showAIPanel: Bool
    @Binding var showPreview: Bool
    @State private var aiResultInline: AIResult? = nil
    @State private var pendingTask: AITask? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Editor title
                    HStack(alignment: .firstTextBaseline) {
                        Text(store.currentModule.name)
                            .font(.system(size: 26, weight: .medium, design: .serif))
                            .italic()
                        Text(store.currentModule.subtitle.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    moduleFields
                        .padding(.horizontal)

                    if let result = aiResultInline {
                        AIInlineResult(result: result, onAccept: applyAI, onReroll: { rerunPending() }, onDismiss: { aiResultInline = nil })
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Theme grid is always visible — switching theme is the most common action.
                    ThemeGrid()
                        .padding(.horizontal)

                    Spacer(minLength: 100) // pad so the publish bar doesn't cover content
                }
            }
            .scrollIndicators(.hidden)

            PublishBar(showPreview: $showPreview)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAIPanel = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                        Text("AI")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(LinearGradient.brandAI, in: Capsule())
                    .foregroundStyle(.white)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showPreview = true } label: { Label("Open public preview", systemImage: "safari") }
                    Button { } label: { Label("Duplicate model", systemImage: "doc.on.doc") }
                    Button { } label: { Label("Export JSON", systemImage: "square.and.arrow.up") }
                    Divider()
                    Picker("Appearance", selection: Binding(
                        get: { store.appearance },
                        set: { store.appearance = $0 }
                    )) {
                        ForEach(Appearance.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .navigationTitle(store.current.stageName)
        .navigationBarTitleDisplayMode(.inline)
        .animation(.smooth(duration: 0.32), value: aiResultInline)
        .animation(.smooth(duration: 0.32), value: store.selectedModuleID)
    }

    // MARK: - Module-specific fields

    @ViewBuilder
    private var moduleFields: some View {
        let key = store.currentModule.key
        switch key {
        case "hero":      heroFields
        case "vibe":      vibeFields
        case "stats":     stubFields(text: "Stat values are pulled from your performance log. Connect a source under Settings → Integrations.")
        case "gallery":   stubFields(text: "Manage gallery images in the Media library. Captions can be generated from the AI panel.")
        case "nights":    stubFields(text: "Featured Nights are pulled from your booking history. Tap a row in the Library to feature.")
        case "moodboard": stubFields(text: "Moodboard ingests from your saved palette. Edit the palette under Vibe.")
        case "quote":     quoteFields
        case "booking":   bookingFields
        case "social":    socialFields
        case "footer":    stubFields(text: "Footer is auto-generated from your workspace settings.")
        default:          stubFields(text: "Editor not implemented yet for this module.")
        }
    }

    // Hero ----------------------------------------------------------------
    private var heroFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                FormField(label: "Stage name") {
                    TextField("Stage name", text: bind(\.stageName))
                        .textFieldStyle(.fieldBg)
                }
                FormField(label: "Pronouns", hint: "optional") {
                    TextField("e.g. she/her", text: bind(\.pronouns))
                        .textFieldStyle(.fieldBg)
                }
            }

            FormField(label: "Tagline", aiTask: .tagline, runAI: runAI) {
                TextField("A magnetic single line", text: bind(\.tagline))
                    .textFieldStyle(.fieldBg)
            }

            FormField(label: "Short bio", aiTask: .bioShort, runAI: runAI) {
                TextEditor(text: bind(\.bioShort))
                    .frame(minHeight: 84)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.separator))
            }

            FormField(label: "Long bio", aiTask: .bioLong, runAI: runAI) {
                TextEditor(text: bind(\.bioLong))
                    .frame(minHeight: 130)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.separator))
            }

            HStack(spacing: 12) {
                FormField(label: "Home base") {
                    TextField("e.g. Miami × Lisbon", text: bind(\.homeBase))
                        .textFieldStyle(.fieldBg)
                }
                FormField(label: "Languages") {
                    TextField("e.g. EN · PT · ES", text: bind(\.languages))
                        .textFieldStyle(.fieldBg)
                }
            }
        }
    }

    // Vibe ----------------------------------------------------------------
    private var vibeFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            FormField(label: "Signature line", aiTask: .tagline, runAI: runAI) {
                TextField("e.g. Vinyl, velvet, and a slow dawn.", text: bind(\.tagline))
                    .textFieldStyle(.fieldBg)
            }
            Text("The Vibe section reads from your selected theme. Change the theme below to see the palette swatches update live.")
                .font(.system(size: 12.5))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
    }

    // Quote ---------------------------------------------------------------
    private var quoteFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            FormField(label: "Pull quote") {
                TextEditor(text: bind(\.bioShort))
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.separator))
            }
        }
    }

    // Booking -------------------------------------------------------------
    private var bookingFields: some View {
        HStack(spacing: 12) {
            FormField(label: "Booking CTA", aiTask: .ctaRewrite, runAI: runAI) {
                TextField("e.g. Request the deck", text: bind(\.ctaText))
                    .textFieldStyle(.fieldBg)
            }
            FormField(label: "Booking email") {
                TextField("you@studio.com", text: bind(\.bookingEmail))
                    .textFieldStyle(.fieldBg)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
        }
    }

    // Social --------------------------------------------------------------
    private var socialFields: some View {
        Text("Social links are managed under the model's connected accounts. Tap a tile in the public preview to test.")
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func stubFields(text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    // MARK: - AI runner

    private func runAI(_ task: AITask) {
        pendingTask = task
        aiResultInline = nil
        Task {
            let result = await AIService.shared.generate(task, for: store.current)
            withAnimation { aiResultInline = result }
        }
    }

    private func rerunPending() {
        guard let t = pendingTask else { return }
        runAI(t)
    }

    private func applyAI(_ result: AIResult) {
        store.updateCurrent { p in
            switch result.task {
            case .tagline:         p.tagline = result.text
            case .bioShort:        p.bioShort = result.text
            case .bioLong:         p.bioLong = result.text
            case .ctaRewrite:
                let firstLine = result.text
                    .components(separatedBy: "\n")
                    .first
                    .map { $0.replacingOccurrences(of: #"^\d+\.\s*"#, with: "", options: .regularExpression) }
                    ?? result.text
                p.ctaText = firstLine
            case .galleryCaptions, .themeSuggest:
                break // these don't auto-apply, they're informational
            }
        }
        withAnimation { aiResultInline = nil }
    }

    // MARK: - Convenience

    private func bind<T>(_ keyPath: WritableKeyPath<ModelProfile, T>) -> Binding<T> {
        Binding(
            get: { store.current[keyPath: keyPath] },
            set: { newValue in store.updateCurrent { $0[keyPath: keyPath] = newValue } }
        )
    }
}

// MARK: - Form field shell

struct FormField<Content: View>: View {
    var label: String
    var hint: String? = nil
    var aiTask: AITask? = nil
    var runAI: ((AITask) -> Void)? = nil
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Text(label.uppercased())
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(0.6)
                    .foregroundStyle(.secondary)

                if let hint {
                    Text("— \(hint)")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                if let aiTask, let runAI {
                    Button {
                        runAI(aiTask)
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "sparkles")
                            Text("Generate")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.brandAISoft, in: Capsule())
                        .foregroundStyle(Color.brandAI)
                    }
                    .buttonStyle(.plain)
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Field background style

struct FieldBgStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.separator, lineWidth: 1)
            )
            .font(.system(size: 14))
    }
}
extension TextFieldStyle where Self == FieldBgStyle {
    static var fieldBg: FieldBgStyle { FieldBgStyle() }
}

// MARK: - Inline AI result card

struct AIInlineResult: View {
    let result: AIResult
    let onAccept: (AIResult) -> Void
    let onReroll: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").foregroundStyle(.white)
                Text(result.task.label.uppercased())
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(LinearGradient.brandAI)

            Text(result.text)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .textSelection(.enabled)

            HStack(spacing: 8) {
                Button {
                    onAccept(result)
                } label: {
                    Label("Accept", systemImage: "checkmark")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .foregroundStyle(.white)
                        .background(Color.brandAI, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    onReroll()
                } label: {
                    Label("Re-roll", systemImage: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.thinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
            }
            .padding(12)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.brandAI.opacity(0.35), lineWidth: 1)
        )
    }
}
