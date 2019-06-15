/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ MathTests.swift                                                                                  ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Dec07/18        Copyright 2018 Ramsay Consulting. All rights reserved. ║
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

            XCTAssertFalse(almostEqual(10.0, 10.00000000000001),  "10.0 ≉ 10.00000000000001")
            XCTAssertFalse(almostEqual(10.0,  9.99999999999999),  "10.0 ≉  9.99999999999999")

            XCTAssertFalse(almostEqual(1e-200, 1e-201), "1e-200 ≉ 1e-201")

        }

        func testnormalizeAngle() {

            for angle in stride(from: -400.0, to: +400.0, by: 20.0) {
                print("   \(angle) : \(fmod2pi_0(angle*deg2rad)*rad2deg)")
            }

        }

    }

//    func testPerformanceExample() {
//
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
