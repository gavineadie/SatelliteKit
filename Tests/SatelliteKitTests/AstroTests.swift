/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AstroTests.swift                                                                                 ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb25/20     Copyright 2020-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable comma

import XCTest
@testable import SatelliteKit

class AstroTests: XCTestCase {

    override func setUp() {    }

    override func tearDown() {    }

    func TestDs1950() {
        let s1 = solarCel(ds1950: 0.0)
        let s2 = solarCel(julianDays: 2433281.5)

        XCTAssertEqual(s1.x, s2.x)
        XCTAssertEqual(s1.y, s2.y)
        XCTAssertEqual(s1.z, s2.z)
    }

    func testSolar() {
        var baseJD: Double
        if #available(macOS 12, *) {
            baseJD = Date.now.julianDate
        } else {
            baseJD = Date().julianDate
        }
        for hour in 0...24 {
            let hourJD = baseJD + Double(hour)/24.0
            let v = solarCel(julianDays: hourJD)
            let hourAngle = siteMeanSiderealTime(julianDate: hourJD, -80.0)
            print(hour, hourJD, hourAngle, v)
        }
    }
}
