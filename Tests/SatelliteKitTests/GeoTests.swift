/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ GeoTests.swift                                                                                   ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jun22/24        Copyright 2024 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Testing
import Foundation
@testable import SatelliteKit

struct GeoTests {

    let JD = 2_458_965.464_745_4

    @Test func Astro() {

        let topVectorA = eci2top(julianDays: 2458905.0,
                                 satCel: Vector(10000.0, 10000.0, 0.0),
                                 obsLLA: LatLonAlt(0.0, 0.0, 0.0))

        let topVectorB = cel2top(julianDays: 2458905.0,
                                 satCel: Vector(10000.0, 10000.0, 0.0),
                                 obsCel: geo2xyz(julianDays: 2458905.0,
                                                 geodetic: LatLonAlt(0.0, 0.0, 0.0)))

        #expect(topVectorA == topVectorB)

        let topVectorC = topPosition(julianDays: 2458905.0,
                                     satCel: Vector(10000.0, 10000.0, 0.0),
                                     obsLLA: LatLonAlt(0.0, 0.0, 0.0))
        print(topVectorC)

    }

    @Test func ECI_GEO() {
        let geo = eci2geo(julianDays: JD, celestial: Vector(10000.0, 10000.0, 0.0))
        let eci = geo2eci(julianDays: JD, geodetic: geo)

        #expect(abs(10000.0 - eci.x) < 0.000001)
        #expect(abs(10000.0 - eci.y) < 0.000001)
        #expect(abs(0.0 - eci.z) < 0.000001)

        print(eci)
    }

    @Test func ECI_TOP() {
        let top = eci2top(julianDays: JD, satCel: Vector(10000.0, 10000.0, 0.0),
                          obsLLA: LatLonAlt(0.0, 0.0, 0.0))
        //        let eci = top2eci(julianDays: JD, sar: top)
        print(top)
    }

    @Test func AzEl() {
        let azEl = azel(time: Date(), site: (45.0, -90.0), cele: (0.0, 0.0))
        print(azEl)
    }

    @Test func llaTest() {
        let _ = LatLonAlt(30.0, -90.0, 500.0)
    }

    @Test func aedTest() {
        let _ = AziEleDst(90.0, 45.0, 2000.0)
    }

}
