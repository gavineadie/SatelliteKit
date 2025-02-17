/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ MathTests.swift                                                                                  ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Dec07/18     Copyright 2018-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable comma

import XCTest
@testable import SatelliteKit

class MathTests: XCTestCase {

    override func setUp() {    }

    override func tearDown() {    }

    class MathsTest: XCTestCase {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  │               |                                                                                  │
  │       +,-     |    +,+                                                                           │
  │               |                                                                                  │
  │               |                                                                                  │
  │     ----------+----------                                                                        │
  │               |                                                                                  │
  │               |                                                                                  │
  │       -,-     |    -,+                                                                           │
  │               |                                                                                  │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        func testTrig() {

            XCTAssertEqual((atan2pi(+1.0, +1.0) * rad2deg),  45.0)
            XCTAssertEqual((atan2pi(+1.0, -1.0) * rad2deg), 135.0)
            XCTAssertEqual((atan2pi(-1.0, -1.0) * rad2deg), 225.0)
            XCTAssertEqual((atan2pi(-1.0, +1.0) * rad2deg), 315.0)

        }

        func testAlmost() {

            XCTAssertTrue (almostEqual(10.0, 10.000000000000001), "10.0 ≈ 10.000000000000001")
            XCTAssertTrue (almostEqual(10.0,  9.999999999999999), "10.0 ≈  9.999999999999999")

            XCTAssertTrue (almostEqual(10.0, 10.000000000000002), "10.0 ≈ 10.000000000000002")
            XCTAssertTrue (almostEqual(10.0,  9.999999999999998), "10.0 ≈  9.999999999999998")

            XCTAssertFalse (almostEqual(10.0, 10.000000000000005), "10.0 ≈ 10.000000000000003")
            XCTAssertFalse (almostEqual(10.0,  9.999999999999995), "10.0 ≈  9.999999999999997")

            XCTAssertFalse (almostEqual(10.0, 10.00000000000001),  "10.0 ≉ 10.00000000000001")
            XCTAssertFalse (almostEqual(10.0,  9.99999999999999),  "10.0 ≉  9.99999999999999")

            XCTAssertFalse (almostEqual(1e-200, 1e-201), "1e-200 ≉ 1e-201")

            XCTAssertTrue (10.0 ≈ 10.000000000000001, "10.0 ≈ 10.000000000000001")
            XCTAssertTrue (10.0 ≈  9.999999999999999, "10.0 ≈  9.999999999999999")

            XCTAssertFalse (10.0 ≈ 10.00000000000001,  "10.0 ≉ 10.00000000000001")
            XCTAssertFalse (10.0 ≈  9.99999999999999,  "10.0 ≉  9.99999999999999")

            XCTAssertFalse (1e-200 ≈ 1e-201, "1e-200 ≉ 1e-201")
       }

        func testDotProduct() {

            var v1 = Vector()
            var v2 = Vector()

            XCTAssertEqual (v1 • v2, 0.0, "(0.0, 0.0, 0.0) • (0.0, 0.0, 0.0))")

            v1 = Vector(1.0, 0.0, 0.0)
            v2 = Vector(1.0, 0.0, 0.0)
            XCTAssertEqual (v1 • v2, 1.0, "(1.0, 0.0, 0.0) • (1.0, 0.0, 0.0))")

            v1 = Vector(1.0, 3.0, -5.0)
            v2 = Vector(4.0, -2.0, -1.0)
            XCTAssertEqual (v1 • v2, 3.0, "(1.0, 0.0, 0.0) • (0.0, 1.0, 0.0))")

        }

        func testCrossProduct() {

            var v1 = Vector(1.0, 0.0, 0.0)
            var v2 = Vector(0.0, 1.0, 0.0)

            XCTAssertEqual (v1 ⨯ v2, Vector(0.0, 0.0, +1.0), "(1.0, 0.0, 0.0) ⨯ (0.0, 1.0, 0.0) == (0.0, 0.0, +1.0)")
            XCTAssertEqual (v2 ⨯ v1, Vector(0.0, 0.0, -1.0), "(0.0, 1.0, 0.0) ⨯ (1.0, 0.0, 0.0) == (0.0, 0.0, -1.0)")

            v1 = Vector(0.0, 0.0, 1.0)
            v2 = Vector(0.0, 1.0, 0.0)

            XCTAssertEqual (v2 ⨯ v1, Vector(1.0, 0.0, 0.0), "(0.0, 1.0, 0.0) ⨯ (0.0, 0.0, 1.0) == (0.0, 0.0, +1.0)")

        }

        func testLimits() {
            XCTAssertEqual(limit180(180.0), 180.0)
            XCTAssertEqual(limit180(120.0), 120.0)
            XCTAssertEqual(limit180(60.0), 60.0)
            XCTAssertEqual(limit180(0.0), 0.0)
            XCTAssertEqual(limit180(-60.0), -60.0)
            XCTAssertEqual(limit180(-120.0), -120.0)
            XCTAssertEqual(limit180(-180.0), -180.0)
            XCTAssertEqual(limit180(-240.0), 120.0)

            XCTAssertEqual(limit360(420.0), 60.0)
            XCTAssertEqual(limit360(360.0), 360.0)
            XCTAssertEqual(limit360(300.0), 300.0)
            XCTAssertEqual(limit360(240.0), 240.0)
            XCTAssertEqual(limit360(180.0), 180.0)
            XCTAssertEqual(limit360(120.0), 120.0)
            XCTAssertEqual(limit360(60.0), 60.0)
            XCTAssertEqual(limit360(0.0), 0.0)
            XCTAssertEqual(limit360(-60.0), 300.0)
            XCTAssertEqual(limit360(-120.0), 240.0)
            XCTAssertEqual(limit360(-180.0), 180.0)
            XCTAssertEqual(limit360(-240.0), 120.0)

            XCTAssertEqual(limit360(360.00001),   0.00001, accuracy: 0.0000000001)
            XCTAssertEqual(limit360(360.00000), 360.0)
            XCTAssertEqual(limit360(359.99999), 359.99999, accuracy: 0.0000000001)

        }

        func testnormalizeAngle() {

            for angle in stride(from: -400.0, to: +400.0, by: 20.0) {
                print("   \(angle) : \((fmod2pi_0(angle*deg2rad)*rad2deg).roundTo6Places())")
            }

        }

//        @available(OSX 10.12, *)
//        func testUnits() {
//            let degrees = Measurement<UnitAngle>(value: 1.0, unit: .degrees)
//            print(degrees.description)
//
//            let radians = Measurement<UnitAngle>(value: 1.0, unit: .radians)
//            print(radians.description)
//        }

//        func testPerformanceLimit180() {
//
//            self.measure {
//                for angle in stride(from: -400.0, to: +400.0, by: 20.0) {
//                    _ = limit180(angle)
//                }
//            }
//
//        }
//
//        func testPerformanceLimit360() {
//
//            self.measure {
//                for angle in stride(from: -220.0, to: +580.0, by: 20.0) {
//                    _ = limit360(angle)
//                }
//            }
//
//        }

    }

}
