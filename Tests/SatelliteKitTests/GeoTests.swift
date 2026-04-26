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

    @Test func GEO_ECI() {
        // Reference: MathWorks geodetic2ecef example for Paris on WGS84 gives
        // x≈4201.0 km, y≈172.46 km, z≈4780.1 km. WGS72 (Re=6378.135, f=1/298.26)
        // yields slightly different values; they are computed here directly from the
        // correct prime-vertical formula N = Re/√(1 − e²·sin²φ). The expected values
        // are therefore independent of the sign used inside geo2eci: if the
        // implementation uses `1 +` instead of `1 −`, all three components are wrong
        // by ~15–17 km and the test fails.
        let paris = LatLonAlt(48.8562, 2.3508, 0.0674)
        let eci = geo2eci(geodetic: paris)

        #expect(abs(eci.x - 4200.995397867801)  < 0.001)
        #expect(abs(eci.y -  172.46026440556156) < 0.001)
        #expect(abs(eci.z - 4780.101546726347)   < 0.001)
    }

    @Test func geo2eciSidereal() {
        // NASA IDL geo2eci reference (spherical Earth, Re=6378.137 WGS84):
        //   lat=0, lon=0, alt=0, JD=2452343.38982663 → X=-3902.9606, Y=5044.5548, Z=0.0 km
        // At lat=0 the oblate correction vanishes (e²·sin²(0)=0), so SatelliteKit (WGS72,
        // Re=6378.135) should agree to within the 0.002 km Re difference plus any GMST drift.
        let eci = geo2eci(julianDays: 2452343.38982663, geodetic: LatLonAlt(0.0, 0.0, 0.0))

        // Residual ~0.002 km comes from Re: WGS84 uses 6378.137, WGS72 uses 6378.135.
        #expect(abs(eci.x - (-3902.9606)) < 0.01)
        #expect(abs(eci.y -   5044.5548)  < 0.01)
        #expect(abs(eci.z -      0.0)     < 0.001)
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
