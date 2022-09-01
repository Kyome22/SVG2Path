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

    var body: some View {
        VStack {
            ZStack {
                ForEach(paths, id: \.description) { path in
                    path.stroke(Color.primary)
                        .frame(width: width, height: height)
                }
            }
            .frame(minWidth: 100, minHeight: 100)
            Button {
                importerPresented = true
            } label: {
                Text("Load SVG File")
            }
            ForEach(paths, id: \.description) { path in
                Text(path.codeString())
            }
        }
        .padding()
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
