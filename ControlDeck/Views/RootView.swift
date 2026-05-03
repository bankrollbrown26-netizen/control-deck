//
//  RootView.swift
//
//  Three-column NavigationSplitView:
//    column 1 (sidebar) — RosterSidebar
//    column 2 (content) — ModuleListView
//    column 3 (detail)  — EditorView
//
//  On iPhone this collapses to a stack: tap a model → tap a module → editor.
//  On iPad you see all three at once in landscape; portrait shows two.
//

import SwiftUI

struct RootView: View {
    @Environment(AppStore.self) private var store
    @State private var visibility: NavigationSplitViewVisibility = .all
    @State private var showAIPanel = false
    @State private var showPreview = false
    @State private var showSettings = false

    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            RosterSidebar(showSettings: $showSettings)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } content: {
            ModuleListView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 360)
        } detail: {
            NavigationStack {
                EditorView(showAIPanel: $showAIPanel, showPreview: $showPreview)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showAIPanel) {
            AIPanelSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPreview) {
            PreviewSheet()
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheet()
                .presentationDetents([.medium])
        }
    }
}
