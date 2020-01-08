/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ThreeLineElementTests.swift                                                                      ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on May05/19     Copyright 2019-20 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import XCTest
@testable import SatelliteKit

class ThreeLineElementTests: XCTestCase {

    func testNullLine0() {

        do {
            let tle = try TLE("",
                              "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                              "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(Satellite(withTLE: tle).debugDescription())

            XCTAssertEqual(tle.t₀, 17533.000)                   // the TLE t=0 time (days from 1950)

            XCTAssertEqual(tle.e₀, 0.0)                         // TLE .. eccentricity
            XCTAssertEqual(tle.M₀, 0.0)                         // Mean anomaly (rad).
            XCTAssertEqual(tle.n₀, 0.0653602452742121,
                           accuracy: 1e-12)                     // Mean motion (rads/min)  << [un'Kozai'd]

            print("mean altitude    (Kms): \((tle.a₀ - 1.0) * TLEConstants.Rₑ)")

            XCTAssertEqual(tle.i₀, 0.0)                         // TLE .. inclination (rad).
            XCTAssertEqual(tle.ω₀, 0.0)                         // Argument of perigee (rad).
            XCTAssertEqual(tle.Ω₀, 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    func testIndexedLine0() {

        do {
            let tle = try TLE("0 ZERO OBJECT",
                              "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                              "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(Satellite(withTLE: tle).debugDescription())

            XCTAssertEqual(tle.t₀, 17533.000)                   // the TLE t=0 time (days from 1950)

            XCTAssertEqual(tle.e₀, 0.0)                         // TLE .. eccentricity
            XCTAssertEqual(tle.M₀, 0.0)                         // Mean anomaly (rad).
            XCTAssertEqual(tle.n₀, 0.0653602452742121,
                           accuracy: 1e-12)                     // Mean motion (rads/min)  << [un'Kozai'd]

            XCTAssertEqual(tle.i₀, 0.0)                         // TLE .. inclination (rad).
            XCTAssertEqual(tle.ω₀, 0.0)                         // Argument of perigee (rad).
            XCTAssertEqual(tle.Ω₀, 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    func testNoIndexTLE() {

        do {
            let tle = try TLE("ZERO OBJECT",
                              "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                              "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(Satellite(withTLE: tle).debugDescription())

            XCTAssertEqual(tle.t₀, 17533.000)                   // the TLE t=0 time (days from 1950)

            XCTAssertEqual(tle.e₀, 0.0)                         // TLE .. eccentricity
            XCTAssertEqual(tle.M₀, 0.0)                         // Mean anomaly (rad).
            XCTAssertEqual(tle.n₀, 0.0653602452742121,
                           accuracy: 1e-12)                     // Mean motion (rads/min)  << [un'Kozai'd]

            XCTAssertEqual(tle.i₀, 0.0)                         // TLE .. inclination (rad).
            XCTAssertEqual(tle.ω₀, 0.0)                         // Argument of perigee (rad).
            XCTAssertEqual(tle.Ω₀, 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    func testSuccessFormatTLE() {

        XCTAssertTrue(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                               "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has no leading "1"                                                                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE1() {

        XCTAssertFalse(formatOK("X 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has no leading "1" (blank)                                                                │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE2() {

        XCTAssertFalse(formatOK("  25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has bad checksum                                                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE3() {

        XCTAssertFalse(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9991",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has bad length                                                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE4() {

        XCTAssertFalse(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0 9991",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has non-zero ephemeris type                                                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureNonZeroEphemType() {

        XCTAssertTrue(formatOK("1 44433U 19040B   19196.49919926  .00000000  00000-0  00000-0 2  5669",
                               "2 44433 052.6278 127.6338 9908875 004.4926 008.9324 00.01340565    01"))

        do {
            let tle = try TLE("Spektr-RG Booster",
                              "1 44433U 19040B   19196.49919926  .00000000  00000-0  00000-0 2  5669",
                              "2 44433 052.6278 127.6338 9908875 004.4926 008.9324 00.01340565    01")

            print(Satellite(withTLE: tle).debugDescription())
        } catch {
            print(error)
        }
    }

    func testLongFile() {

        do {
            let contents = try String(contentsOfFile: "/Users/gavin/Development/sat_code/all_tle.txt")
            processTLEs(contents)
        } catch {
            print(error)
        }

    }

    func testBase34() {
        XCTAssert(base10ID(     "") == 0)

        XCTAssert(base34ID(    "5") == 5)
        XCTAssert(base34ID("10000") == 10000, "got \(base34ID("10000"))")

        // numerical checks

        XCTAssert(base34ID("A0000") == 100000, "got \(base34ID("A0000"))")
        XCTAssert(base34ID("H0000") == 170000, "got \(base34ID("H0000"))")
        XCTAssert(base34ID("J0000") == 180000, "got \(base34ID("J0000"))")
        XCTAssert(base34ID("N0000") == 220000, "got \(base34ID("N0000"))")
        XCTAssert(base34ID("P0000") == 230000, "got \(base34ID("P0000"))")
        XCTAssert(base34ID("Z0000") == 330000, "got \(base34ID("Z0000"))")
        XCTAssert(base34ID("Z9999") == 339999, "got \(base34ID("Z9999"))")

        // lowercase

        XCTAssert(base34ID("a5678") == 105678, "got \(base34ID("a5678"))")

        // failure modes

        XCTAssert(base34ID("!0000") == 0, "got \(base34ID("!9999"))")
        XCTAssert(base34ID("~0000") == 0, "got \(base34ID("~9999"))")
        XCTAssert(base34ID("AAAAA") == 0, "got \(base34ID("AAAAA"))")
    }

    func testBase10() {
        XCTAssert(base10ID("") == 0)

        XCTAssert(base10ID("5") == 5)
        XCTAssert(base10ID("10000") == 10000, "got \(base10ID("10000"))")
        XCTAssert(base10ID("99999") == 99999, "got \(base10ID("99999"))")
    }

//    func testPerformanceExample() {         // May06/19 = iOS sim average: 2.267
//
//        self.measure {
//            testLongFile()
//        }
//    }

}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ This function reads the file records and searches for a TLE-1 record with a good checksum.  If   ┃
  ┃ that is followed by a good TLE-2, then TLE-0, TLE-1 and TLE-2 are kept, else we throw the        ┃
  ┃ records away.  The candidate records used to generate a SatelliteModel to add to the collection. ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
func processTLEs(_ tleChunk: String) {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ split the TLE file text into lines, exclude those starting with "#", trim the rest ..            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    let tleLines = tleChunk.components(separatedBy: "\n")

    let filteredTLEs = tleLines.filter { !$0.hasPrefix("#") }.map {
        $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Do the checksum check on a TLE line ("0"..."9" are 0...9; "-" is 1; last digit is checksum).     │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func checkSumGood(_ tleLine: String) -> Bool {
        var     checkSum: UInt8 = 0
        let     bytes = [UInt8](tleLine.utf8)

        for arrayIndex in 0..<bytes.count-1 {
            checkSum %= 10
            let byte = bytes[arrayIndex]
            if 48...57 ~= byte { checkSum += (byte - 48) }      // "0"..."9" -> 0...9
            if byte == 45 { checkSum += 1 }                     //    "-"    ->   1
        }

        return checkSum % 10 == bytes[bytes.count-1] - 48
    }

    var line = 0
    while line < tleLines.count {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ look for TLE-1 (69 characters long, starting with "1 " and good checksum)                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        let tleLine1 = filteredTLEs[line]
        line += 1
        guard [UInt8](tleLine1.utf8).count == 69,
            tleLine1.hasPrefix("1 "),
            checkSumGood(tleLine1) else { continue }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ look for TLE-2 (69 characters long, starting with "2 " and good checksum)                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        let tleLine2 = filteredTLEs[line]
        line += 1
        guard [UInt8](tleLine2.utf8).count == 69,
            tleLine2.hasPrefix("2 "),
            checkSumGood(tleLine2) else { continue }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ got TLE-1 followed by TLE-2, so check for TLE-0 (three lines back) with, or without, a leading   │
  │ "0" .. it's also possible that we have a "two line" tle file (then, set TLE-0 to "") ..          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        let tleLine0 = filteredTLEs[line-3]

        _ = Satellite(tleLine0.hasPrefix("2 ") ? "" : tleLine0, tleLine1, tleLine2)

    }
}
