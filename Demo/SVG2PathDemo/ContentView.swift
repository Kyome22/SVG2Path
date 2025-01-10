//
//  ContentView.swift
//  SVG2PathDemo
//
//  Created by Takuto Nakamura on 2022/09/01.
//

import SwiftUI
import SVG2Path

struct ContentView: View {
    @State var size = CGSize.zero
    @State var paths = [Path]()
    @State var importerPresented = false
    private let svg2Path = SVG2Path()

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if paths.isEmpty {
                    Image(systemName: "cube")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(Color.primary)
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
            .padding()
            ScrollView {
                if !paths.isEmpty {
                    VStack(spacing: 16) {
                        ForEach(paths, id: \.description) { path in
                            Text(path.codeString())
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
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
}

#Preview {
    ContentView()
}
