/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AstroTests.swift                                                                                 ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb25/20        Copyright 2020 Ramsay Consulting. All rights reserved. ║
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
                                 obsLLA: LatLonAlt(lat: 0.0, lon: 0.0, alt: 0.0))
        print(topVectorA)

        let topVectorB = cel2top(julianDays: 2458905.0,
                                 satCel: Vector(10000.0, 10000.0, 0.0),
                                 obsCel: geo2xyz(julianDays: 2458905.0,
                                                 geodetic: LatLonAlt(lat: 0.0, lon: 0.0, alt: 0.0)))
        print(topVectorB)

        let topVectorC = topPosition(julianDays: 2458905.0,
                                     satCel: Vector(10000.0, 10000.0, 0.0),
                                     obsLLA: LatLonAlt(lat: 0.0, lon: 0.0, alt: 0.0))
        print(topVectorC)

        XCTAssertTrue(true)

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
                                          obsLLA: LatLonAlt(lat: 0.0, lon: 0.0, alt: 0.0))
//        let eci = top2eci(julianDays: JD, sar: top)
        print(top)
    }

    func testAzEl() {
        let azEl = azel(time: Date(), site: (45.0, -90.0), cele: (0.0, 0.0))
        print(azEl)
    }

    func llaTest() {
        let _ = LatLonAlt(lat: 30.0, lon: -90.0, alt: 500.0)
    }
    
    func aedTest() {
        let _ = AziEleDst(azim: 90.0, elev: 45.0, dist: 2000.0)
    }
    
}
