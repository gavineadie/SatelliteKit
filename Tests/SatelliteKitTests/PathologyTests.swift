/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ PathologyTests.swift                                                                             ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Dec07/18     Copyright 2018-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable line_length
// swiftlint:disable identifier_name

import XCTest
@testable import SatelliteKit

class PathologyTests: XCTestCase {

    override func setUp() {    }

    override func tearDown() {    }

    class Pathology: XCTestCase {

        // # check error code 4 (0.0 ... 150.0 ... 5.00)
        func test33333() {

            do {
                let tle = try Elements("",
                                  "1 33333U 05037B   05333.02012661  .25992681  00000-0  24476-3 0  1534",
                                  "2 33333  96.4736 157.9986 9950000 244.0492 110.6523  4.00004038 10708")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("      5.0      836.362     3131.219    27739.125    0.806969   -0.303613    1.495581 <-- Vallado")
                let     pv = try propagator.getPVCoordinates(minsAfterEpoch: 5.0)
                print(String(format: " %8.1f %@ <-- SatKit", 5.0, pv.debugDescription()))

                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 0.0, through: 150.0, by: 5.0) {
                    let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)
                    print(String(format: " %8.1f %@", mins, pv.debugDescription()))
                }

            } 
            catch SatKitError.TLE(let error) { prettyError(error); return }
            catch SatKitError.SGP(let error) { prettyError(error); return }
            catch { prettyError(error.localizedDescription) }
        }

        // # try and check error code 2 but this ... ( 0.0->1440.0 [1.00])
        func test33334() {

            do {
                let tle = try Elements("",
                                  "1 33334U 78066F   06174.85818871  .00000620  00000-0  10000-3 0  6809",
                                  "2 33334  68.4714 236.1303 5602877 123.7484 302.5767  0.00001000 67521")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("      0.0    23876.970   -37275.653    -8113.951    0.589108   -0.767768   -0.260380 <-- Vallado")
                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 0.0, through: 1440.0, by: 1.0) {
                    let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)
                    print(String(format: " %8.1f %@", mins, pv.debugDescription()))
                }

            } 
            catch SatKitError.TLE(let error) { prettyError(error); return }
            catch SatKitError.SGP(let error) { prettyError(error); return }
            catch { prettyError(error.localizedDescription) }
        }

        // # try to check error code 3 looks like ep never goes below zero,
        // # tied close to ecc (0.0->1440.0 [20.00])
        func test33335() {

            do {
                let tle = try Elements("",
                                  "1 33335U 05008A   06176.46683397 -.00000205  00000-0  10000-3 0  2190",
                                  "2 33335   0.0019 286.9433 0000004  13.7918  55.6504  1.00270176  4891")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("      0.0    42081.344    -2649.185        0.818    0.193185    3.068627    0.000438 <-- Vallado")
                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 0.0, through: 1440.0, by: 20.0) {
                    let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)
                    print(String(format: " %8.1f %@", mins, pv.debugDescription()))
                }

            } 
            catch SatKitError.TLE(let error) { prettyError(error); return }
            catch SatKitError.SGP(let error) { prettyError(error); return }
            catch { prettyError(error.localizedDescription) }
        }

        // # Shows Lyddane choice at 1860 and 4700 min (  1844000.0   1845100.0        5.00)
        func test20413() {

            do {
                let tle = try Elements("",
                                  "1 20413U 83020D   05363.79166667  .00000000  00000-0  00000+0 0  7041",
                                  "2 20413  12.3514 187.4253 7864447 196.3027 356.5478  0.24690082  7978")
                let propagator = selectPropagator(tle: tle)

                print(String(format: "\n%5d", tle.noradIndex))
                print("  epoch+s       r[x]         r[y]         r[z]       v[x]        v[y]        v[z]")

                for mins in stride(from: 1844000.0, through: 1845100.0, by: 5.0) {
                    let     pv = try propagator.getPVCoordinates(minsAfterEpoch: mins)

                    let     string = String(format: " %8.1f %12.3f %12.3f %12.3f %11.6f %11.6f %11.6f", mins,
                                            (pv.position.x)/1000.0, (pv.position.y)/1000.0, (pv.position.z)/1000.0,
                                            (pv.velocity.x)/1000.0, (pv.velocity.y)/1000.0, (pv.velocity.z)/1000.0)
                    print(string)
                }

            } 
            catch SatKitError.TLE(let error) { prettyError(error); return }
            catch SatKitError.SGP(let error) { prettyError(error); return }
            catch { prettyError(error.localizedDescription) }
        }
    }

    func testIssue2() {
        let sl30 = Satellite("0 STARLINK-30",
                             "1 44244U 19029K   20287.12291165  .47180237  12426-4  22139-2 0  9995",
                             "2 44244  52.9708 332.0356 0003711 120.7278 242.0157 16.43170483 77756")
        print(sl30.tle.debugDescription())

        for time in stride(from: 600.0, to: 660.0, by: 5.0) {
            do {
                print(sl30.geoPosition(minsAfterEpoch: time))
            }
        }
    }

    // JWST is not in Earth orbit ..

    func testJWST() {
        let jwst = Satellite("0 JWST",
                             "1 50463U 21130A   21362.00000000  .00000000  00000-0  00000-0 0  9999",
                             "2 50463   4.6198  89.0659 9884983 192.3200  17.4027  0.01958082    27")

        print(jwst.tle.debugDescription())

        do {
            let _ = jwst.geoPosition(minsAfterEpoch: 0)
        }
    }

}

func prettyError(_ errorText: String) {

    print("""

        ╔═════════════════════════════════════════════════════════════════════
        ║ »»» \(errorText) «««
        ╚═════════════════════════════════════════════════════════════════════

        """)
}
