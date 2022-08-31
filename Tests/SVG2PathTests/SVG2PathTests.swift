import XCTest
@testable import SVG2Path

final class SVG2PathTests: XCTestCase {
    let svg2Path = SVG2Path()

    func testPath() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <path d="M10.7223,33.32578s-8.33087-6.22693-1.9602-11.12744,7.46966-7.31466,6.61569-10.5361
          c-1.65447-6.24117,4.63253-8.781,7.93746-5.35877,3.31674,3.43446-.9272,6.70584,.88346,10.01426
          c3.18866,5.82627,5.14207,4.25976,8.08584,8.16665,3.01216,3.99765,1.33227,11.86664-8.4825,10.60925
          c-7.01454-.89865-3.80205-11.03237-3.80205-11.03237"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 10.7223, y: 33.3258))
        path.addCurve(to: CGPoint(x: 8.7621, y: 22.1983),
                      control1: CGPoint(x: 10.7223, y: 33.3258),
                      control2: CGPoint(x: 2.3914, y: 27.0989))
        path.addCurve(to: CGPoint(x: 15.3778, y: 11.6622),
                      control1: CGPoint(x: 15.1328, y: 17.2978),
                      control2: CGPoint(x: 16.2318, y: 14.8837))
        path.addCurve(to: CGPoint(x: 23.3152, y: 6.3035),
                      control1: CGPoint(x: 13.7233, y: 5.4211),
                      control2: CGPoint(x: 20.0103, y: 2.8812))
        path.addCurve(to: CGPoint(x: 24.1987, y: 16.3177),
                      control1: CGPoint(x: 26.6320, y: 9.7379),
                      control2: CGPoint(x: 22.3880, y: 13.0093))
        path.addCurve(to: CGPoint(x: 32.2845, y: 24.4844),
                      control1: CGPoint(x: 27.3874, y: 22.1440),
                      control2: CGPoint(x: 29.3408, y: 20.5775))
        path.addCurve(to: CGPoint(x: 23.8020, y: 35.0936),
                      control1: CGPoint(x: 35.2967, y: 28.4820),
                      control2: CGPoint(x: 33.6168, y: 36.3510))
        path.addCurve(to: CGPoint(x: 20.0000, y: 24.0613),
                      control1: CGPoint(x: 16.7875, y: 34.1950),
                      control2: CGPoint(x: 20.0000, y: 24.0613))
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testRect() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <rect x="46" y="9" width="28" height="22"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 46.0000, y: 9.0000))
        path.addLine(to: CGPoint(x: 74.0000, y: 9.0000))
        path.addLine(to: CGPoint(x: 74.0000, y: 31.0000))
        path.addLine(to: CGPoint(x: 46.0000, y: 31.0000))
        path.closeSubpath()
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testCircle() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <circle cx="100" cy="20" r="15"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 115.0000, y: 20.0000))
        path.addCurve(to: CGPoint(x: 100.0000, y: 35.0000),
                      control1: CGPoint(x: 115.0000, y: 28.2843),
                      control2: CGPoint(x: 108.2843, y: 35.0000))
        path.addCurve(to: CGPoint(x: 85.0000, y: 20.0000),
                      control1: CGPoint(x: 91.7157, y: 35.0000),
                      control2: CGPoint(x: 85.0000, y: 28.2843))
        path.addCurve(to: CGPoint(x: 100.0000, y: 5.0000),
                      control1: CGPoint(x: 85.0000, y: 11.7157),
                      control2: CGPoint(x: 91.7157, y: 5.0000))
        path.addCurve(to: CGPoint(x: 115.0000, y: 20.0000),
                      control1: CGPoint(x: 108.2843, y: 5.0000),
                      control2: CGPoint(x: 115.0000, y: 11.7157))
        path.closeSubpath()
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testEllipse() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <ellipse cx="140" cy="20" rx="10.05677" ry="16.5"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 150.0568, y: 20.0000))
        path.addCurve(to: CGPoint(x: 140.0000, y: 36.5000),
                      control1: CGPoint(x: 150.0568, y: 29.1127),
                      control2: CGPoint(x: 145.5542, y: 36.5000))
        path.addCurve(to: CGPoint(x: 129.9432, y: 20.0000),
                      control1: CGPoint(x: 134.4458, y: 36.5000),
                      control2: CGPoint(x: 129.9432, y: 29.1127))
        path.addCurve(to: CGPoint(x: 140.0000, y: 3.5000),
                      control1: CGPoint(x: 129.9432, y: 10.8873),
                      control2: CGPoint(x: 134.4458, y: 3.5000))
        path.addCurve(to: CGPoint(x: 150.0568, y: 20.0000),
                      control1: CGPoint(x: 145.5542, y: 3.5000),
                      control2: CGPoint(x: 150.0568, y: 10.8873))
        path.closeSubpath()
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testLine() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <line x1="167.02532" y1="10.92827" x2="192.97468" y2="29.07173"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 167.0253, y: 10.9283))
        path.addLine(to: CGPoint(x: 192.9747, y: 29.0717))
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testPolyline() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <polyline points="207.02532 4.91561 225.16878 4.91561 234.24051 20.32911 220.63291 35.08439 205.75949 21.58228"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 207.0253, y: 4.9156))
        path.addLine(to: CGPoint(x: 225.1688, y: 4.9156))
        path.addLine(to: CGPoint(x: 234.2405, y: 20.3291))
        path.addLine(to: CGPoint(x: 220.6329, y: 35.0844))
        path.addLine(to: CGPoint(x: 205.7595, y: 21.5823))
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testPolygon() throws {
        let text = """
        <svg viewBox="0 0 280 40">
        <polygon points="257.45308 6.47422 246.91717 19.48498 256.03536 33.52578 272.20664 29.19271 273.08283 12.47392 257.45308 6.47422"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 280.0)
        XCTAssertEqual(actual.height, 40.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 257.4531, y: 6.4742))
        path.addLine(to: CGPoint(x: 246.9172, y: 19.4850))
        path.addLine(to: CGPoint(x: 256.0354, y: 33.5258))
        path.addLine(to: CGPoint(x: 272.2066, y: 29.1927))
        path.addLine(to: CGPoint(x: 273.0828, y: 12.4739))
        path.addLine(to: CGPoint(x: 257.4531, y: 6.4742))
        path.closeSubpath()
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testTransformMatrix() throws {
        let text = """
        <svg viewBox="0 0 260 80">
        <rect x="16" y="29" width="28" height="22" transform="matrix(0.9659 -0.2588 0.2588 0.9659 -9.3305 9.1275)"/>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 260.0)
        XCTAssertEqual(actual.height, 80.0)
        XCTAssertEqual(actual.paths.count, 1)
        let expect = """
        path.move(to: CGPoint(x: 13.6291, y: 32.9978))
        path.addLine(to: CGPoint(x: 40.6743, y: 25.7514))
        path.addLine(to: CGPoint(x: 46.3679, y: 47.0012))
        path.addLine(to: CGPoint(x: 19.3227, y: 54.2476))
        path.closeSubpath()
        """
        XCTAssertEqual(actual.paths[0].codeString(), expect)
    }

    func testTransformTranslate() throws {
        try XCTContext.runActivity(named: "only tx", block: { _ in
            let text = """
            <svg viewBox="0 0 280 40">
            <rect x="46" y="9" width="28" height="22" transform="translate(10)"/>
            </svg>
            """
            let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
            XCTAssertEqual(actual.width, 280.0)
            XCTAssertEqual(actual.height, 40.0)
            XCTAssertEqual(actual.paths.count, 1)
            let expect = """
            path.move(to: CGPoint(x: 46.0000, y: 9.0000))
            path.addLine(to: CGPoint(x: 74.0000, y: 9.0000))
            path.addLine(to: CGPoint(x: 74.0000, y: 31.0000))
            path.addLine(to: CGPoint(x: 46.0000, y: 31.0000))
            path.closeSubpath()
            """
            XCTAssertEqual(actual.paths[0].codeString(), expect)
        })

        try XCTContext.runActivity(named: "tx & ty", block: { _ in
            let text = """
            <svg viewBox="0 0 280 40">
            <rect x="46" y="9" width="28" height="22" transform="translate(10 -5)"/>
            </svg>
            """
            let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
            XCTAssertEqual(actual.width, 280.0)
            XCTAssertEqual(actual.height, 40.0)
            XCTAssertEqual(actual.paths.count, 1)
            let expect = """
            path.move(to: CGPoint(x: 56.0000, y: 4.0000))
            path.addLine(to: CGPoint(x: 84.0000, y: 4.0000))
            path.addLine(to: CGPoint(x: 84.0000, y: 26.0000))
            path.addLine(to: CGPoint(x: 56.0000, y: 26.0000))
            path.closeSubpath()
            """
            XCTAssertEqual(actual.paths[0].codeString(), expect)
        })
    }

    func testTransformScale() throws {
        try XCTContext.runActivity(named: "only sx", block: { _ in
            let text = """
            <svg viewBox="0 0 280 40">
            <circle cx="100" cy="20" r="15" transform="scale(2)"/>
            </svg>
            """
            let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
            XCTAssertEqual(actual.width, 280.0)
            XCTAssertEqual(actual.height, 40.0)
            XCTAssertEqual(actual.paths.count, 1)
            let expect = """
            path.move(to: CGPoint(x: 230.0000, y: 40.0000))
            path.addCurve(to: CGPoint(x: 200.0000, y: 70.0000),
                          control1: CGPoint(x: 230.0000, y: 56.5685),
                          control2: CGPoint(x: 216.5685, y: 70.0000))
            path.addCurve(to: CGPoint(x: 170.0000, y: 40.0000),
                          control1: CGPoint(x: 183.4315, y: 70.0000),
                          control2: CGPoint(x: 170.0000, y: 56.5685))
            path.addCurve(to: CGPoint(x: 200.0000, y: 10.0000),
                          control1: CGPoint(x: 170.0000, y: 23.4315),
                          control2: CGPoint(x: 183.4315, y: 10.0000))
            path.addCurve(to: CGPoint(x: 230.0000, y: 40.0000),
                          control1: CGPoint(x: 216.5685, y: 10.0000),
                          control2: CGPoint(x: 230.0000, y: 23.4315))
            path.closeSubpath()
            """
            XCTAssertEqual(actual.paths[0].codeString(), expect)
        })

        try XCTContext.runActivity(named: "sx & sy", block: { _ in
            let text = """
            <svg viewBox="0 0 280 40">
            <circle cx="100" cy="20" r="15" transform="scale(2 1.5)"/>
            </svg>
            """
            let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
            XCTAssertEqual(actual.width, 280.0)
            XCTAssertEqual(actual.height, 40.0)
            XCTAssertEqual(actual.paths.count, 1)
            let expect = """
            path.move(to: CGPoint(x: 230.0000, y: 30.0000))
            path.addCurve(to: CGPoint(x: 200.0000, y: 52.5000),
                          control1: CGPoint(x: 230.0000, y: 42.4264),
                          control2: CGPoint(x: 216.5685, y: 52.5000))
            path.addCurve(to: CGPoint(x: 170.0000, y: 30.0000),
                          control1: CGPoint(x: 183.4315, y: 52.5000),
                          control2: CGPoint(x: 170.0000, y: 42.4264))
            path.addCurve(to: CGPoint(x: 200.0000, y: 7.5000),
                          control1: CGPoint(x: 170.0000, y: 17.5736),
                          control2: CGPoint(x: 183.4315, y: 7.5000))
            path.addCurve(to: CGPoint(x: 230.0000, y: 30.0000),
                          control1: CGPoint(x: 216.5685, y: 7.5000),
                          control2: CGPoint(x: 230.0000, y: 17.5736))
            path.closeSubpath()
            """
            XCTAssertEqual(actual.paths[0].codeString(), expect)
        })
    }

    func testTransformRotate() throws {
        try XCTContext.runActivity(named: "only angle", block: { _ in
            let text = """
            <svg viewBox="0 0 280 40">
            <rect x="46" y="9" width="28" height="22" transform="rotate(30)"/>
            </svg>
            """
            let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
            XCTAssertEqual(actual.width, 280.0)
            XCTAssertEqual(actual.height, 40.0)
            XCTAssertEqual(actual.paths.count, 1)
            let expect = """
            path.move(to: CGPoint(x: 35.3372, y: 30.7942))
            path.addLine(to: CGPoint(x: 59.5859, y: 44.7942))
            path.addLine(to: CGPoint(x: 48.5859, y: 63.8468))
            path.addLine(to: CGPoint(x: 24.3372, y: 49.8468))
            path.closeSubpath()
            """
            XCTAssertEqual(actual.paths[0].codeString(), expect)
        })

        try XCTContext.runActivity(named: "angle & cx & cy", block: { _ in
            let text = """
            <svg viewBox="0 0 280 40">
            <rect x="46" y="9" width="28" height="22" transform="rotate(30 20 -20)"/>
            </svg>
            """
            let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
            XCTAssertEqual(actual.width, 280.0)
            XCTAssertEqual(actual.height, 40.0)
            XCTAssertEqual(actual.paths.count, 1)
            let expect = """
            path.move(to: CGPoint(x: 28.0167, y: 18.1147))
            path.addLine(to: CGPoint(x: 52.2654, y: 32.1147))
            path.addLine(to: CGPoint(x: 41.2654, y: 51.1673))
            path.addLine(to: CGPoint(x: 17.0167, y: 37.1673))
            path.closeSubpath()
            """
            XCTAssertEqual(actual.paths[0].codeString(), expect)
        })
    }

    func testGroupedPath() throws {
        let text = """
        <svg viewBox="0 0 260 80">
        <g>
          <g transform="rotate(90 49.315 40)">
            <rect x="16" y="29" width="28" height="22" transform="matrix(0.9659 -0.2588 0.2588 0.9659 -9.3305 9.1275)"/>
            <circle class="st0" cx="70" cy="40" r="15"/>
          </g>
          <ellipse cx="110" cy="40" rx="14" ry="11.5" transform="matrix(0.9659 -0.2588 0.2588 0.9659 -6.6046 29.8328)"/>
        </g>
        <line x1="137" y1="30.9" x2="163" y2="49.1"/>
        <g transform="scale(1 2) translate(0 -20)">
          <polyline points="177,24.9 195.2,24.9 204.2,40.3 190.6,55.1 175.8,41.6"/>
          <polygon points="227.5,26.5 216.9,39.5 226,53.5 242.2,49.2 243.1,32.5"/>
        </g>
        </svg>
        """
        let actual = try XCTUnwrap(svg2Path.extractPath(text: text))
        XCTAssertEqual(actual.width, 260.0)
        XCTAssertEqual(actual.height, 80.0)
        XCTAssertEqual(actual.paths.count, 3)
        let expect1 = """
        path.move(to: CGPoint(x: 56.3172, y: 4.3141))
        path.addLine(to: CGPoint(x: 63.5636, y: 31.3593))
        path.addLine(to: CGPoint(x: 42.3138, y: 37.0529))
        path.addLine(to: CGPoint(x: 35.0674, y: 10.0077))
        path.closeSubpath()
        path.move(to: CGPoint(x: 49.3150, y: 75.6850))
        path.addCurve(to: CGPoint(x: 34.3150, y: 60.6850),
                      control1: CGPoint(x: 41.0307, y: 75.6850),
                      control2: CGPoint(x: 34.3150, y: 68.9693))
        path.addCurve(to: CGPoint(x: 49.3150, y: 45.6850),
                      control1: CGPoint(x: 34.3150, y: 52.4007),
                      control2: CGPoint(x: 41.0307, y: 45.6850))
        path.addCurve(to: CGPoint(x: 64.3150, y: 60.6850),
                      control1: CGPoint(x: 57.5993, y: 45.6850),
                      control2: CGPoint(x: 64.3150, y: 52.4007))
        path.addCurve(to: CGPoint(x: 49.3150, y: 75.6850),
                      control1: CGPoint(x: 64.3150, y: 68.9693),
                      control2: CGPoint(x: 57.5993, y: 75.6850))
        path.closeSubpath()
        path.move(to: CGPoint(x: 123.5190, y: 36.3776))
        path.addCurve(to: CGPoint(x: 112.9726, y: 51.1086),
                      control1: CGPoint(x: 125.1627, y: 42.5123),
                      control2: CGPoint(x: 120.4409, y: 49.1076))
        path.addCurve(to: CGPoint(x: 96.4738, y: 43.6240),
                      control1: CGPoint(x: 105.5043, y: 53.1097),
                      control2: CGPoint(x: 98.1175, y: 49.7587))
        path.addCurve(to: CGPoint(x: 107.0202, y: 28.8929),
                      control1: CGPoint(x: 94.8301, y: 37.4893),
                      control2: CGPoint(x: 99.5519, y: 30.8940))
        path.addCurve(to: CGPoint(x: 123.5190, y: 36.3776),
                      control1: CGPoint(x: 114.4885, y: 26.8919),
                      control2: CGPoint(x: 121.8753, y: 30.2429))
        path.closeSubpath()
        """
        let expect2 = """
        path.move(to: CGPoint(x: 137.0000, y: 30.9000))
        path.addLine(to: CGPoint(x: 163.0000, y: 49.1000))
        """
        let expect3 = """
        path.move(to: CGPoint(x: 177.0000, y: 9.8000))
        path.addLine(to: CGPoint(x: 195.2000, y: 9.8000))
        path.addLine(to: CGPoint(x: 204.2000, y: 40.6000))
        path.addLine(to: CGPoint(x: 190.6000, y: 70.2000))
        path.addLine(to: CGPoint(x: 175.8000, y: 43.2000))
        path.move(to: CGPoint(x: 227.5000, y: 13.0000))
        path.addLine(to: CGPoint(x: 216.9000, y: 39.0000))
        path.addLine(to: CGPoint(x: 226.0000, y: 67.0000))
        path.addLine(to: CGPoint(x: 242.2000, y: 58.4000))
        path.addLine(to: CGPoint(x: 243.1000, y: 25.0000))
        path.closeSubpath()
        """
        let results = actual.paths.map { path in
            return path.codeString()
        }
        XCTAssertEqual(results, [expect1, expect2, expect3])
    }
}
