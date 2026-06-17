//
//  ContentView.swift
//  SVG2PathDemo
//
//  Created by Takuto Nakamura on 2022/09/01.
//

import AppKit
import SwiftUI
import SVG2Path

struct ContentView: View {
    @State var size = CGSize.zero
    @State var paths = [Path]()
    @State var importerPresented = false
    private let svg2Path = SVG2Path()

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                if paths.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("No Paths")
                        } icon: {
                            Image(systemName: "cube")
                        }
                    }
                    .fixedSize()
                } else {
                    ForEach(paths, id: \.description) { path in
                        path.stroke(Color.primary)
                            .frame(width: size.width, height: size.height)
                    }
                }
            }
            .padding()
            Button {
                importerPresented = true
            } label: {
                Text("Load SVG File")
            }
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(paths, id: \.description) { path in
                        let code = path.codeString()
                        Text(code)
                            .multilineTextAlignment(.leading)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    copyToClipboard(code)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                }
                                .buttonStyle(.borderless)
                                .help("Copy to Clipboard")
                            }
                    }
                    if paths.isEmpty {
                        Spacer().frame(maxWidth: .infinity)
                    }
                }
                .padding(8)
            }
            .border(Color(.separatorColor))
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .fileImporter(
            isPresented: $importerPresented,
            allowedContentTypes: [.svg],
            onCompletion: { result in
                switch result {
                case let .success(url):
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    guard let text = try? String(contentsOf: url, encoding: .utf8),
                          let result = svg2Path.extractPath(text: text) else {
                        return
                    }
                    size = result.size
                    paths = result.paths
                case let .failure(error):
                    Swift.print(error.localizedDescription)
                }
            }
        )
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

#Preview {
    ContentView()
}
