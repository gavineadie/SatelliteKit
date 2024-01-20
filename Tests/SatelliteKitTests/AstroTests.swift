/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AstroTests.swift                                                                                 ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb25/20     Copyright 2020-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable comma

import XCTest
@testable import SatelliteKit

class AstroTests: XCTestCase {

    let JD = 2_458_965.464_745_4

    override func setUp() {    }

    override func tearDown() {    }

    func testAstro() {

        let topVectorA = eci2top(julianDays: 2458905.0,
                                 satCel: Vector(10000.0, 10000.0, 0.0),
                                 obsLLA: LatLonAlt(0.0, 0.0, 0.0))

        let topVectorB = cel2top(julianDays: 2458905.0,
                                 satCel: Vector(10000.0, 10000.0, 0.0),
                                 obsCel: geo2xyz(julianDays: 2458905.0,
                                                 geodetic: LatLonAlt(0.0, 0.0, 0.0)))

        XCTAssertEqual(topVectorA, topVectorB)

        let topVectorC = topPosition(julianDays: 2458905.0,
                                     satCel: Vector(10000.0, 10000.0, 0.0),
                                     obsLLA: LatLonAlt(0.0, 0.0, 0.0))
        print(topVectorC)

    }

    func testECI_GEO() {
        let geo = eci2geo(julianDays: JD, celestial: Vector(10000.0, 10000.0, 0.0))
        let eci = geo2eci(julianDays: JD, geodetic: geo)
        
        XCTAssertEqual(10000.0, eci.x, accuracy: 0.000001)
        XCTAssertEqual(10000.0, eci.y, accuracy: 0.000001)
        XCTAssertEqual(0.0, eci.z, accuracy: 0.000001)

        print(eci)
    }

    func testECI_TOP() {
        let top = eci2top(julianDays: JD, satCel: Vector(10000.0, 10000.0, 0.0),
                          obsLLA: LatLonAlt(0.0, 0.0, 0.0))
//        let eci = top2eci(julianDays: JD, sar: top)
        print(top)
    }

    func testAzEl() {
        let azEl = azel(time: Date(), site: (45.0, -90.0), cele: (0.0, 0.0))
        print(azEl)
    }

    func llaTest() {
        let _ = LatLonAlt(30.0, -90.0, 500.0)
    }
    
    func aedTest() {
        let _ = AziEleDst(90.0, 45.0, 2000.0)
    }

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
