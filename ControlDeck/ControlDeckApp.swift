//
//  ControlDeckApp.swift
//  Calling Card — Control Deck
//
//  The entry point. Wires up the @Observable AppStore and hands it
//  to the root view. iOS 17+ for @Observable + NavigationSplitView.
//

import SwiftUI

@main
struct ControlDeckApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(store.appearance.colorScheme)
        }
    }
}
