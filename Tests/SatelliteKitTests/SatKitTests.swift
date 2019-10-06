/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SatKitTests.swift                                                                                ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jan07/17 ... Copyright 2017-19 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint statement_position

import XCTest
@testable import SatelliteKit

extension Satellite {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialize Satellite with a string holding the folded lines of a three line element set         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(withString tle3: String) {
        let splitTLE = tle3.components(separatedBy: CharacterSet(charactersIn: "\n"))
        guard splitTLE.count == 3 else { fatalError("Satellite.init failure ..") }

        self.init(splitTLE[0], splitTLE[1], splitTLE[2])
    }

}

class SwiftTests: XCTestCase {

    func testProp() {

        do {
            let tle = try TLE("ISS (ZARYA)",
                              "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
                              "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577")

            print(Satellite(withTLE: tle).debugDescription())

            print("mean altitude    (Kms): \((tle.a₀ - 1.0) * TLEConstants.Rₑ)")

            let propagator = selectPropagator(tle: tle)

            let pv1 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0)
            print(pv1.debugDescription())
            print(String(format: "radius1 %10.1f", pv1.position.magnitude()))

            let pv2 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0 + 1.0/60.0)
            print(pv2.debugDescription())
            print(String(format: "radius2 %10.1f", pv2.position.magnitude()))
            print(String(format: "r2 - r1 %10.1f", (pv2.position - pv1.position).magnitude()))

            let pv3 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0 + 2.0/60.0)
            print(pv3.debugDescription())
            print(String(format: "radius3 %10.1f", pv3.position.magnitude()))
            print(String(format: "r3 - r2 %10.1f", (pv3.position - pv2.position).magnitude()))

        } catch {

            print(error)

        }

    }

    func testAzEl() {

        let jdate = Date().julianDate
        print("  Julian Ddate: \(jdate)")

        let moonCele = lunarGeo(julianDays: jdate)
        print(" Moon (Dec/RA): \(moonCele)°")

        let azelx = azel(time: Date(), site: (+42.0, -84.0), cele: (moonCele.1, moonCele.0))
        print("       (Az/El): \(azelx)°")

    }

    func testConversion() {

        let sat = Satellite(withString: """
            ISS (ZARYA)
            1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999
            2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577
            """)

        XCTAssertEqual(JD.epoch2000,
                       sat.minsAfterEpoch(sat.julianDay(JD.epoch2000)),
                       accuracy: 1e-7)

        XCTAssertEqual(999.9,
                       sat.julianDay(sat.minsAfterEpoch(999.9)),
                       accuracy: 1e-10)

    }

}
