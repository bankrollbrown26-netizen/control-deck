//
//  PublishBar.swift
//
//  Sticky bar at the bottom of the editor. Save state on the left,
//  Preview + Publish actions on the right. Publish flips the model's
//  status to .published and shows a confirmation toast.
//

import SwiftUI

struct PublishBar: View {
    @Environment(AppStore.self) private var store
    @Binding var showPreview: Bool
    @State private var pulse = false
    @State private var publishedToast = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                SaveStateChip(state: store.saveState)

                Spacer()

                Button {
                    showPreview = true
                } label: {
                    Label("Preview", systemImage: "safari")
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)

                Button {
                    publish()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up")
                        Text("Publish")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .background(
                        LinearGradient(
                            colors: [.brandPub, Color.hex("059669")],
                            startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: Capsule()
                    )
                    .shadow(color: Color.brandPub.opacity(0.35), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .overlay(Rectangle().frame(height: 0.5).foregroundStyle(.separator), alignment: .top)

            if publishedToast {
                ToastBanner(text: "Published — \(store.current.stageName) is live")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func publish() {
        store.publish()
        withAnimation { publishedToast = true }
        Task {
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            withAnimation { publishedToast = false }
        }
    }
}

struct SaveStateChip: View {
    let state: AppStore.SaveState

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
                .overlay(
                    Circle()
                        .stroke(dotColor.opacity(0.3), lineWidth: 3)
                )
            Text(state.label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var dotColor: Color {
        switch state {
        case .saved:  return .brandPub
        case .saving: return .brandWarn
        case .error:  return .red
        }
    }
}

struct ToastBanner: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.brandPub)
            Text(text)
                .font(.system(size: 13, weight: .medium))
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.thickMaterial)
        .overlay(Rectangle().frame(height: 0.5).foregroundStyle(.separator), alignment: .top)
    }
}
