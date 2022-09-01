//
//  ContentView.swift
//  SVG2PathDemo
//
//  Created by Takuto Nakamura on 2022/09/01.
//

import SwiftUI
import SVG2Path

struct ContentView: View {
    @State var size: CGSize = .zero
    @State var paths = [Path]()
    @State var importerPresented: Bool = false
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
                if paths.isEmpty {
                    EmptyView()
                } else {
                    ForEach(paths, id: \.description) { path in
                        Text(path.codeString())
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        .fileImporter(isPresented: $importerPresented, allowedContentTypes: [.svg], onCompletion: { result in
            switch result {
            case .success(let url):
                guard let text = try? String(contentsOf: url, encoding: .utf8),
                      let result = svg2Path.extractPath(text: text)
                else { return }
                size = result.size
                paths = result.paths
            case .failure(let error):
                Swift.print(error.localizedDescription)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
