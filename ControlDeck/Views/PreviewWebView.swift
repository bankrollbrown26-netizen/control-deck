//
//  PreviewWebView.swift
//
//  Loads the bundled `profile-demo.html` from the app's Resources folder
//  inside a WKWebView. Theme switching is driven by injecting a JS call
//  that sets `document.documentElement.dataset.theme`. The HTML file
//  is the same one that ships on the web — re-using it keeps preview
//  100% faithful to production.
//

import SwiftUI
import UIKit
@preconcurrency import WebKit

struct PreviewSheet: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var device: PreviewDevice = .desktop

    enum PreviewDevice: String, CaseIterable, Identifiable {
        case desktop, mobile
        var id: String { rawValue }
        var label: String { rawValue.capitalized }
        var symbol: String { self == .desktop ? "macbook" : "iphone" }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Device", selection: $device) {
                    ForEach(PreviewDevice.allCases) { d in
                        Label(d.label, systemImage: d.symbol).tag(d)
                    }
                }
                .pickerStyle(.segmented)
                .padding(12)

                GeometryReader { geo in
                    let isMobile = device == .mobile
                    let containerW = geo.size.width
                    let containerH = geo.size.height
                    let frameW: CGFloat = isMobile ? min(360, containerW - 32) : containerW - 24
                    let frameH: CGFloat = isMobile ? min(720, containerH - 24) : containerH - 24

                    HStack {
                        Spacer()
                        DeviceFrame(isMobile: isMobile) {
                            ProfileWebView(themeID: store.current.themeID)
                                .clipShape(RoundedRectangle(cornerRadius: isMobile ? 30 : 8))
                        }
                        .frame(width: frameW, height: frameH)
                        Spacer()
                    }
                    .frame(width: containerW, height: containerH)
                }
                .background(
                    LinearGradient(
                        colors: [Color(.systemGray6), Color(.systemGray5)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            }
            .navigationTitle("Live Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("/preview/\(store.current.slug)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.thinMaterial, in: Capsule())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Device chrome

struct DeviceFrame<Content: View>: View {
    let isMobile: Bool
    @ViewBuilder var content: Content

    var body: some View {
        ZStack(alignment: .top) {
            if isMobile {
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .fill(Color.black)
                    .overlay(
                        // Notch
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.black)
                            .frame(width: 110, height: 24)
                            .offset(y: 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .zIndex(2),
                        alignment: .top
                    )
                    .shadow(color: .black.opacity(0.3), radius: 24, y: 12)
                content
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                    .padding(.bottom, 4)
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.hex("1a1a1f"))
                    .shadow(color: .black.opacity(0.25), radius: 18, y: 10)
                VStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                        Circle().fill(Color.yellow).frame(width: 8, height: 8)
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    content
                        .padding(.horizontal, 4)
                        .padding(.bottom, 4)
                }
            }
        }
    }
}

// MARK: - WKWebView wrapper

struct ProfileWebView: UIViewRepresentable {
    let themeID: String

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.preferences.javaScriptCanOpenWindowsAutomatically = false
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.isOpaque = false
        wv.backgroundColor = .black
        wv.scrollView.backgroundColor = .black
        wv.scrollView.bounces = false
        wv.navigationDelegate = context.coordinator
        loadProfile(into: wv)
        return wv
    }

    func updateUIView(_ wv: WKWebView, context: Context) {
        // Swap theme on the document root.
        let js = "document.documentElement.setAttribute('data-theme','\(themeID)');"
        wv.evaluateJavaScript(js, completionHandler: nil)
    }

    func makeCoordinator() -> Coordinator { Coordinator(themeID: themeID) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var themeID: String
        init(themeID: String) { self.themeID = themeID }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let js = "document.documentElement.setAttribute('data-theme','\(themeID)');"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    private func loadProfile(into webView: WKWebView) {
        guard let url = Bundle.main.url(forResource: "profile-demo", withExtension: "html") else {
            webView.loadHTMLString(fallbackHTML, baseURL: nil)
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    private var fallbackHTML: String {
        """
        <html><body style="background:#0d0d12;color:#fff;font-family:system-ui;padding:40px;text-align:center">
        <p>Couldn't load profile-demo.html.</p>
        <p>Make sure it's added to Copy Bundle Resources in your target.</p>
        </body></html>
        """
    }
}
