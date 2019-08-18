/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TimeTests.swift                                                                                  ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Mar31/19        Copyright 2019 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/// swiftlint:disable comma

import XCTest
@testable import SatelliteKit

class TimeTests: XCTestCase {

    override func setUp() {    }

    override func tearDown() {    }

    func testDate() {

        XCTAssertTrue(String(describing: TimeConstants.tleEpochReferenceDate) == "1949-12-31 00:00:00 +0000")

        XCTAssertTrue(String(describing: Date(year: 1951, month: 1, day: 10)) == "1951-01-10 00:00:00 +0000")
        XCTAssertTrue(String(describing: Date(year: 2018, month: 4, day: 23)) == "2018-04-23 00:00:00 +0000")
        XCTAssertTrue(String(describing: Date(year: 2034, month: 12, day: 1)) == "2034-12-01 00:00:00 +0000")

    }

    func testSidereal() {

        print(String(format: "GMT MeanSiderealTime: %.2f°", zeroMeanSiderealTime(date: Date())))
        print(stringHMS(hms: deg2hms(decimalDegrees: zeroMeanSiderealTime(date: Date()))))

        print(String(format: "+30 MeanSiderealTime: %.2f°", siteMeanSiderealTime(date: Date(), +30.0)))
        print(String(format: "-30 MeanSiderealTime: %.2f°", siteMeanSiderealTime(date: Date(), -30.0)))

        print(String(format: "-30 MeanSiderealTime: %.2f°", siteMeanSiderealTime(date: Date(), -83.75)))
        print(stringHMS(hms: deg2hms(decimalDegrees: siteMeanSiderealTime(date: Date(), -83.75))))

    }

    func testJulian() {

        print(Date(julianDate: 2433281.5).julianDate)
        print(Date(julianDate: 10.0).julianDate)
        print(Date(julianDate: 4321432.1).julianDate)

    }

    func testHMS() {

        print(deg2hms(decimalDegrees: 45.0))
        print(deg2hms(decimalDegrees: 0.0))
        print(deg2hms(decimalDegrees: -45.0))
        print(deg2hms(decimalDegrees: 360.0))
        print(deg2hms(decimalDegrees: 720.0))

        print(stringHMS(hms: deg2hms(decimalDegrees: 123.456)))

    }

    func testDeg2hms() {

        print(stringHMS(hms: deg2hms(decimalDegrees: 179.5)))
        print(stringHMS(hms: deg2hms(decimalDegrees: 180.0)))
        print(stringHMS(hms: deg2hms(decimalDegrees: 180.1)))
        print(stringHMS(hms: deg2hms(decimalDegrees: 180.5)))
        print(stringHMS(hms: deg2hms(decimalDegrees: 180.555555)))

        print(hms2deg(hms: deg2hms(decimalDegrees: 123.456)))

    }

    func testConstants() {

        print(TimeConstants.tleEpochReferenceDate)
        print(Date(daysSince1950: 0.0))

    }

    func testEpochTime() {

        print(epochDays(year: 1950, days: 1.0))
        print(Date(daysSince1950: epochDays(year: 1950, days: 1.0)))

        print(epochDays(year: 1957, days: 1.0))
        print(Date(daysSince1950: epochDays(year: 1957, days: 1.0)))

        print(epochDays(year: 2056, days: 1.0))
        print(Date(daysSince1950: epochDays(year: 2056, days: 1.0)))

    }

}
