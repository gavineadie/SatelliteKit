/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ThreeLineElementTests.swift                                                                      ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on May05/19     Copyright 2019-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Testing
import Foundation
@testable import SatelliteKit

struct ThreeLineElementTests {

    @Test
    func twoLines() {
        
        do {
            let tle = try Elements("",
                                   "1 00005U 58002B   22281.98988747  .00000306  00000-0  37162-3 0  9996",
                                   "2 00005  34.2463 149.5009 1846449 188.6184 167.7916 10.85017843296875")
            
            print(tle.debugDescription())
            
        } catch {
            print(error)
        }
    }
    
    @Test
    func nullLine0() {
        do {
            let tle = try Elements("",
                                   "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                                   "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(tle.debugDescription())

            #expect(tle.t₀ == 17533.000)                          // the TLE t=0 time (days from 1950)

            #expect(tle.e₀ == 0.0)                                // TLE .. eccentricity
            #expect(tle.M₀ == 0.0)                                // Mean anomaly (rad).
            #expect(abs(tle.n₀ - 0.06536024527421205) < 1e-12)    // Mean motion (rads/min)  << [un'Kozai'd]

            print("mean altitude    (Kms): \((tle.a₀ - 1.0) * EarthConstants.Rₑ)")

            #expect(tle.i₀ == 0.0)                                // TLE .. inclination (rad).
            #expect(tle.ω₀ == 0.0)                                // Argument of perigee (rad).
            #expect(tle.Ω₀ == 0.0)                                // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    @Test
    func indexedLine0() {
        do {
            let tle = try Elements("0 ZERO OBJECT",
                                   "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                                   "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(tle.debugDescription())

            #expect(tle.t₀ == 17533.000)                          // the TLE t=0 time (days from 1950)

            #expect(tle.e₀ == 0.0)                                // TLE .. eccentricity
            #expect(tle.M₀ == 0.0)                                // Mean anomaly (rad).
            #expect(abs(tle.n₀ - 0.06536024527421205) < 1e-12)    // Mean motion (rads/min)  << [un'Kozai'd]

            #expect(tle.i₀ == 0.0)                                // TLE .. inclination (rad).
            #expect(tle.ω₀ == 0.0)                                // Argument of perigee (rad).
            #expect(tle.Ω₀ == 0.0)                                // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    @Test
    func NoIndexTLE() {

        do {
            let tle = try Elements("ZERO OBJECT",
                                   "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                                   "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(tle.debugDescription())

            #expect(tle.t₀ == 17533.000)                   // the TLE t=0 time (days from 1950)

            #expect(tle.e₀ == 0.0)                         // TLE .. eccentricity
            #expect(tle.M₀ == 0.0)                         // Mean anomaly (rad).
            #expect(abs(tle.n₀ - 0.06536024527421205) < 1e-12)       // Mean motion (rads/min)  << [un'Kozai'd]

            #expect(tle.i₀ == 0.0)                         // TLE .. inclination (rad).
            #expect(tle.ω₀ == 0.0)                         // Argument of perigee (rad).
            #expect(tle.Ω₀ == 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    @Test
    func CurrentTLE() {

        do {
            let tle1 = try Elements("ISS (ZARYA)",
                                    "1 25544U 98067A   24058.53519608  .00023511  00000+0  42705-3 0  9998",
                                    "2 25544  51.6422 143.7454 0005758 300.3007 142.0288 15.49424907441399")

            print(tle1.debugDescription())

            let tle2 = try Elements("ISS (ZARYA)",
                                    "1 25544U 98067A   24056.53519608  .00023511  00000+0  42705-3 0  9998",
                                    "2 25544  51.6422 143.7454 0005758 300.3007 142.0288 15.49424907441399")

            print(tle2.debugDescription())

        } catch {
            print(error)
        }

    }

    @Test
    func SuccessFormatTLE() {

        #expect(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                         "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has no leading "1"                                                                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @Test
    func FailureFormatTLE1() {

        #expect(!formatOK("X 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                          "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has no leading "1" (blank)                                                                │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @Test
    func FailureFormatTLE2() {

        #expect(!formatOK("  25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                          "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has bad checksum                                                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @Test
    func FailureFormatTLE3() {

        #expect(!formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9991",
                          "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has bad length                                                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @Test
    func FailureFormatTLE4() {

        #expect(!formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0 9991",
                          "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has non-zero ephemeris type                                                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @Test
    func FailureNonZeroEphemType() {

        #expect(formatOK("1 44433U 19040B   19196.49919926  .00000000  00000-0  00000-0 2  5669",
                         "2 44433 052.6278 127.6338 9908875 004.4926 008.9324 00.01340565    01"))

        do {
            let tle = try Elements("Spektr-RG Booster",
                                   "1 44433U 19040B   19196.49919926  .00000000  00000-0  00000-0 2  5669",
                                   "2 44433 052.6278 127.6338 9908875 004.4926 008.9324 00.01340565    01")

            print(tle.debugDescription())
        } catch {
            print(error)
        }
    }
    
    @Test
    func TleAccess() {

        let sat = Satellite("ISS (ZARYA)",
                            "1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                            "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531")
        
        print("Mean motion:", sat.tle.n₀)

    }

    @Test
    func LongFile() {

        do {
            let contents = try String(contentsOfFile: "/Users/gavin/Library/Application Support/com.ramsaycons.tle/active.txt")
            _ = preProcessTLEs(contents)
        } catch {
            print(error)
        }

    }

    @Test
    func Base34() {
        #expect(base10ID(     "") == 0)

        #expect(alpha5ID(     "") == 0)
        #expect(alpha5ID(    "5") == 5)
        #expect(alpha5ID("10000") == 10000, "got \(alpha5ID("10000"))")

        // numerical checks

        #expect(alpha5ID("A0000") == 100000, "got \(alpha5ID("A0000"))")
        #expect(alpha5ID("H0000") == 170000, "got \(alpha5ID("H0000"))")
        #expect(alpha5ID("J0000") == 180000, "got \(alpha5ID("J0000"))")
        #expect(alpha5ID("N0000") == 220000, "got \(alpha5ID("N0000"))")
        #expect(alpha5ID("P0000") == 230000, "got \(alpha5ID("P0000"))")
        #expect(alpha5ID("Z0000") == 330000, "got \(alpha5ID("Z0000"))")
        #expect(alpha5ID("Z9999") == 339999, "got \(alpha5ID("Z9999"))")

        #expect(alpha5ID("J2931") == 182931, "got \(alpha5ID("J2931"))")
        #expect(alpha5ID("W1928") == 301928, "got \(alpha5ID("W1928"))")
        #expect(alpha5ID("E8493") == 148493, "got \(alpha5ID("E8493"))")
        #expect(alpha5ID("P4018") == 234018, "got \(alpha5ID("P4018"))")

        #expect(alpha5ID("I0000") == 0, "got \(alpha5ID("I0000"))")
        #expect(alpha5ID("0I000") == 0, "got \(alpha5ID("0I000"))")

        // lowercase

        #expect(alpha5ID("a5678") == 105678, "got \(alpha5ID("a5678"))")

        // failure modes

        #expect(alpha5ID("!0000") == 0, "got \(alpha5ID("!9999"))")
        #expect(alpha5ID("~0000") == 0, "got \(alpha5ID("~9999"))")
        #expect(alpha5ID("AAAAA") == 0, "got \(alpha5ID("AAAAA"))")
    }

    @Test 
    func Base10() {
        #expect(base10ID("") == 0)

        #expect(base10ID("5") == 5)
        #expect(base10ID("10000") == 10000, "got \(base10ID("10000"))")
        #expect(base10ID("99999") == 99999, "got \(base10ID("99999"))")
    }

}
