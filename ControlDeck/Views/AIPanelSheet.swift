//
//  AIPanelSheet.swift
//
//  Bottom sheet — the 5 AI tasks. Tap a task → loading → result with
//  Accept / Re-roll / Edit. Mirrors what the inline "Generate" buttons
//  do but as a dedicated panel for browse-style use.
//

import SwiftUI

struct AIPanelSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var pending: AITask? = nil
    @State private var result: AIResult? = nil
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Each task uses your current model's draft as context. Accept to apply, Re-roll to try again.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 4)

                    VStack(spacing: 8) {
                        ForEach(AITask.allCases) { task in
                            AITaskRow(task: task, isLoading: pending == task) {
                                run(task)
                            }
                        }
                    }
                    .padding(.horizontal, 12)

                    if let result {
                        ResultCard(result: result, onAccept: apply, onReroll: { run(result.task) })
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("AI Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(LinearGradient.brandAI, in: RoundedRectangle(cornerRadius: 5))
                        Text("claude-sonnet")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .animation(.smooth(duration: 0.3), value: result?.id)
    }

    private func run(_ task: AITask) {
        pending = task
        result = nil
        Task {
            let r = await AIService.shared.generate(task, for: store.current)
            await MainActor.run {
                pending = nil
                result = r
            }
        }
    }

    private func apply(_ r: AIResult) {
        store.updateCurrent { p in
            switch r.task {
            case .tagline:    p.tagline  = r.text
            case .bioShort:   p.bioShort = r.text
            case .bioLong:    p.bioLong  = r.text
            case .ctaRewrite:
                let firstLine = r.text.components(separatedBy: "\n").first
                    .map { $0.replacingOccurrences(of: #"^\d+\.\s*"#, with: "", options: .regularExpression) }
                    ?? r.text
                p.ctaText = firstLine
            case .galleryCaptions, .themeSuggest: break
            }
        }
        result = nil
        dismiss()
    }
}

struct AITaskRow: View {
    let task: AITask
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    if isLoading {
                        ProgressView()
                            .tint(Color.brandAI)
                            .controlSize(.small)
                    } else {
                        Image(systemName: task.symbol)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.brandAI)
                    }
                }
                .frame(width: 28, height: 28)
                .background(Color.brandAISoft, in: RoundedRectangle(cornerRadius: 7, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(task.label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(task.subtitle)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.separator)
            )
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct ResultCard: View {
    let result: AIResult
    let onAccept: (AIResult) -> Void
    let onReroll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles").foregroundStyle(.white)
                Text(result.task.label.uppercased())
                    .font(.system(size: 10.5, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(LinearGradient.brandAI)

            Text(result.text)
                .font(.system(size: 16, weight: .regular, design: .serif))
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .textSelection(.enabled)

            HStack(spacing: 8) {
                Button { onAccept(result) } label: {
                    Label("Accept", systemImage: "checkmark")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(.white)
                        .background(Color.brandAI, in: Capsule())
                }
                .buttonStyle(.plain)

                Button { onReroll() } label: {
                    Label("Re-roll", systemImage: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)

                Spacer()
            }
            .padding(12)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.brandAI.opacity(0.4), lineWidth: 1)
        )
    }
}
