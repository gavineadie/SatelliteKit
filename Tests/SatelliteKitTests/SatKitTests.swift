/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SatKitTests.swift                                                                                ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Jan07/17 ... Copyright 2017-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint statement_position

import Testing
import Foundation
@testable import SatelliteKit

struct SwiftTests {

    @Test func version() {
        print(SatelliteKit.version)
    }

    @Test func prop1() {

        do {
            let elements = try Elements("ISS (ZARYA)",
                                        "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
                                        "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577")

            print(elements.debugDescription())

            print("mean altitude    (Kms): \((elements.a₀ - 1.0) * EarthConstants.Rₑ)")

            let propagator = selectPropagator(tle: elements)

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

    @Test func prop2() {

        do {
            let tle = try Elements("INTELSAT 39 (IS-39)",
                                   "1 44476U 19049B   19348.07175972  .00000049  00000-0  00000+0 0  9993",
                                   "2 44476   0.0178 355.6330 0000615 323.6584 210.9460  1.00270455  1345")

            print(tle.debugDescription())

            print("mean altitude    (Kms): \((tle.a₀ - 1.0) * EarthConstants.Rₑ)")

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

    @Test func azEl() {

        let jdate = Date().julianDate
        print("  Julian Ddate: \(jdate)")

        let moonCele = lunarGeo(julianDays: jdate)
        print(" Moon (Dec/RA): \(moonCele)°")

        let azelx = azel(time: Date(), site: (+42.0, -84.0), cele: (moonCele.1, moonCele.0))
        print("       (Az/El): \(azelx)°")

    }

    @Test func conversion() {
        let sat = Satellite(
            "ISS (ZARYA)",
            "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
            "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577")

        #expect(abs(JD.epoch2000 - sat.minsAfterEpoch(sat.julianDay(JD.epoch2000))) < 1e-7)
        #expect(abs(999.9 - sat.julianDay(sat.minsAfterEpoch(999.9))) < 1e-10)
    }

}
