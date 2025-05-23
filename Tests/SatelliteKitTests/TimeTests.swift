/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TimeTests.swift                                                                                  ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Mar31/19     Copyright 2019-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/// swiftlint:disable comma

import XCTest
@testable import SatelliteKit

class TimeTests: XCTestCase {

    func testDate() {
        XCTAssertTrue(String(describing: TimeConstants.tleEpochReferenceDate) == "1949-12-31 00:00:00 +0000")

        XCTAssertTrue(String(describing: Date(year: 1951, month: 1, day: 10)) == "1951-01-10 00:00:00 +0000")
        XCTAssertTrue(String(describing: Date(year: 2018, month: 4, day: 23)) == "2018-04-23 00:00:00 +0000")
        XCTAssertTrue(String(describing: Date(year: 2034, month: 12, day: 1)) == "2034-12-01 00:00:00 +0000")
    }

    func testMHS() {
        XCTAssertEqual(deg2hms(decimalDegrees: 45.0).0, 3)
        XCTAssertEqual(deg2hms(decimalDegrees: 45.00001).2, 0.002)

        print(deg2hms(decimalDegrees: 45.0))
        print(deg2hms(decimalDegrees: 45.01))
        print(deg2hms(decimalDegrees: 45.001))
        print(deg2hms(decimalDegrees: 45.0001))
        print(deg2hms(decimalDegrees: 45.00001))
        print(deg2hms(decimalDegrees: 45.000001))

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
        XCTAssertTrue(Date(julianDate: 2433281.5).julianDate == 2433281.5)
        XCTAssertTrue(Date(julianDate:      10.0).julianDate ==      10.0)
        XCTAssertTrue(Date(julianDate: 4321432.1).julianDate == 4321432.1)
        XCTAssertEqual(Date(julianDate: -4321432.1).julianDate, -4321432.1)
    }
    
    func testJD() {
        print(julianDaysNow())
    }

    func testMJD() {
        print(Date(mjd: 42338.9113))                // 1974-10-18 21:52:16 +0000
    }

    func testHMS() {
        print(deg2hms(decimalDegrees:  45.0))
        print(deg2hms(decimalDegrees:   0.0))
        print(deg2hms(decimalDegrees: -45.0))
        print(deg2hms(decimalDegrees: 360.0))
        print(deg2hms(decimalDegrees: 720.0))

        XCTAssertEqual(stringHMS(hms: deg2hms(decimalDegrees: 123.456)), "08ʰ13ᵐ49.440")
    }

    func testDeg2hms() {
        XCTAssertTrue(stringHMS(hms: deg2hms(decimalDegrees: 179.5)) == "11ʰ58ᵐ00.000")
        XCTAssertTrue(stringHMS(hms: deg2hms(decimalDegrees: 180.0)) == "12ʰ00ᵐ00.000")
        XCTAssertTrue(stringHMS(hms: deg2hms(decimalDegrees: 180.1)) == "12ʰ00ᵐ24.000")
        XCTAssertTrue(stringHMS(hms: deg2hms(decimalDegrees: 180.5)) == "12ʰ02ᵐ00.000")
        XCTAssertTrue(stringHMS(hms: deg2hms(decimalDegrees: 180.555555)) == "12ʰ02ᵐ13.333")

        XCTAssertTrue(deg2hms(decimalDegrees:  15.0) == ( 1,  0, 0.0))
        XCTAssertTrue(deg2hms(decimalDegrees: 179.5) == (11, 58, 0.0))
        XCTAssertTrue(deg2hms(decimalDegrees: 180.0) == (12, 0, 0.0))

        print(hms2deg(hms: deg2hms(decimalDegrees: 123.456)))       // 123.45599999999..
        print(hms2deg(hms: deg2hms(decimalDegrees: 345.678)))       //   0.67799999999..
    }

    func testConstants() {

        print(TimeConstants.tleEpochReferenceDate)
        print(Date(ds1950: 0.0))

    }

}
