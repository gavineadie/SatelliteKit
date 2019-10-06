/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TLE.swift                                                                                 SatKit ║
  ║ Created by Gavin Eadie on 5/24/17.         Copyright © 2017-19 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable force_try
// swiftlint:disable identifier_name
// swiftlint:disable function_body_length

enum SatKitError: Error {
    case TLE(String)
    case SGP(String)
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ An epoch of 98001.00000000 corresponds to 0000 UT on 1998 January 01 — in other words, midnight  │
  │ between 1997 December 31 and 1998 January 01. An epoch of 98000.00000000 would actually          │
  │ correspond to the beginning of 1997 December 31. Note that the epoch day starts at UT midnight   │
  │ (not noon) and that all times are measured mean solar rather than sidereal time units.           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func epochDays(year: Int, days: Double) -> Double {
    return Double(year-1950)*365.0 + Double((year-1949)/4) + days
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃                                                                                                  ┃
  ┃                                                                                                  ┃
  ┃                                                               MemoryLayout<TLE>.size = 200 bytes ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public struct TLE {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Information derived directly from the Two Line Elements ..                                       ┆
  ┆                                               .. and un'Kozai'd mean motion and semi major axis. ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    public let commonName: String                       // line zero name (if any)
    public let noradIndex: Int                          // The satellite number.
    public let launchName: String                       // International designation
    public let t₀: Double                               // the TLE t=0 time (days from 1950)
    public let e₀: Double                               // TLE .. eccentricity
    public let i₀: Double                               // TLE .. inclination (rad).
    public let ω₀: Double                               // Argument of perigee (rad).
    public let Ω₀: Double                               // Right Ascension of the Ascending node (rad).
    public let M₀: Double                               // Mean anomaly (rad).
    public let n₀: Double                               // Mean motion (rads/min)  << [un'Kozai'd]
    public let a₀: Double                               // semi-major axis (Eᵣ)    << [un'Kozai'd]
    public let dragCoeff: Double                        // Ballistic coefficient.

    private let launchYear: Int                         // Launch year.
    private let launchSequ: Int                         // Launch number.
    private let launchPart: String                      // Piece of launch (from "A" to "ZZZ").

    public let ephemType: Int                           // Type of ephemeris.
    private let tleClass: Character                     // Classification (U for unclassified).
    public let tleNumber: Int                           // Element number.
    public let revNumber: Int                           // Revolution number at epoch.

    internal let apogee: Double                         // TLE apogee altitude, expressed in Kms.
    internal let perigee: Double                        // TLE perigee altitude, expressed in Kms.

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(_ line0: String, _ line1: String, _ line2: String) throws {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆                                                                                                  ┆
  ┆ 0         1         2         3         4         5         6         7                          ┆
  ┆ 01234567890123456789012345678901234567890123456789012345678901234567890                          ┆
  ┆                                                                                                  ┆
  ┆                                                                                                  ┆
  ┆ AAAAAAAAAAAAAAAAAAAAAAAA                                                                         ┆
  ┆ ISS (ZARYA)                                                           optional leading "0 "      ┆
  ┆ ------------------------                                              < 24 char name             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        commonName = line0.hasPrefix("0 ") ? String(line0.dropFirst().dropFirst()) : line0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ 1 NNNNNU NNNNNAAA NNNNN.NNNNNNNN ±.NNNNNNNN ±NNNNN-N ±NNNNN-N N NNNNN                            ┆
  ┆ 1 25544U 98067A   08246.53160505  .00005208  00000-0  43781-4 0  1753                            ┆
  ┆ 1 25544U 98067A   08246.53160505  .00005208 .00000-0 .43781-4 0  1753   [zero index]             ┆
  ┆   -----                                                               < [02-06] satellite #      ┆
  ┆        U                                                              < [   07] classification   ┆
  ┆          .-                                                           < [09-10] ID (year)        ┆
  ┆            ---                                                        < [11-13] ID (launch #)    ┆
  ┆               ---                                                     < [14-16] ID (fragment)    ┆
  ┆                   --                                                  < [18-19] epoch year       ┆
  ┆                     ------------                                      < [20-31] epoch day        ┆
  ┆                                  ----------           [not used SGP4] < [33-42] Mean Motion/s    ┆
  ┆                                             .-----    [not used SGP4] < [44-                     ┆
  ┆                                                   --  [not used SGP4] <    -51] Mean Motion/s/s  ┆
  ┆                                                      .-----           < [53-                     ┆
  ┆                                                            --         < [  -60] BSTAR drag term  ┆
  ┆                                                               -       < [   62] ephemeris type   ┆
  ┆                                                                 ----  < [64-67] element number   ┆
  ┆                                                                     - < [   68] checksum         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        let lineOneBytes: [UInt8] = Array(line1.utf8)

        var stringlet = String(bytes: lineOneBytes[2...6], encoding: .utf8)!
        self.noradIndex = base34ID(stringlet.trimmingCharacters(in: .whitespaces))

        stringlet = String(bytes: lineOneBytes[7...7], encoding: .utf8)!
        self.tleClass = Character(stringlet)
        if self.tleClass != "U" { print("self.tleClass is not 'U'") }

        stringlet = String(bytes: lineOneBytes[9...10], encoding: .utf8)!
        self.launchYear = Int(stringlet) ?? 99

        stringlet = String(bytes: lineOneBytes[11...13], encoding: .utf8)!
        self.launchSequ = Int(stringlet) ?? 999

        stringlet = String(bytes: lineOneBytes[14...16], encoding: .utf8)!
        self.launchPart = stringlet.trimmingCharacters(in: .whitespaces)

        stringlet = String(bytes: lineOneBytes[9...16], encoding: .utf8)!
        self.launchName = stringlet.trimmingCharacters(in: .whitespaces)

        stringlet = String(bytes: lineOneBytes[18...19], encoding: .utf8)!
        let epochYear = Int(stringlet)!

        stringlet = String(bytes: lineOneBytes[20...31], encoding: .utf8)!
        self.t₀ = epochDays(year: (epochYear < 57 ? 2000 : 1900) + epochYear, days: Double(stringlet)!)

        stringlet = (lineOneBytes[53] == 32 ||
                     lineOneBytes[53] == 43 ? "+" : "-") + "." +
                    String(bytes: lineOneBytes[54...54], encoding: .utf8)! +
                    String(bytes: lineOneBytes[55...58], encoding: .utf8)! + "e" +
                    String(bytes: lineOneBytes[59...60], encoding: .utf8)!
        self.dragCoeff = Double(stringlet)!

        stringlet = String(bytes: lineOneBytes[62...62], encoding: .utf8)!
        self.ephemType = Int(stringlet) ?? 0

        stringlet = String(bytes: lineOneBytes[64...67], encoding: .utf8)!
        self.tleNumber = Int(stringlet.trimmingCharacters(in: .whitespaces))!

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ 2 NNNNN NNN.NNNN NNN.NNNN NNNNNNN NNN.NNNN NNN.NNNN NN.NNNNNNNNNNNNNN                            ┆
  ┆ 2 25544  51.6437 339.5511 0006673  73.4733  44.7326 15.71870125560705                            ┆
  ┆ 2 25544  51.6437 339.5511.0006673  73.4733  44.7326 15.71870125560705   [zero index]             ┆
  ┆   -----                                                               < [02-06] satellite #      ┆
  ┆         --------                                                      < [08-15] inclination      ┆
  ┆                  --------                                             < [17-24] RAAN             ┆
  ┆                          .-------                                     < [26-32] eccentricity     ┆
  ┆                                   --------                            < [34-41] Arg of Perigee   ┆
  ┆                                            --------                   < [43-50] Mean Anomaly     ┆
  ┆                                                     -----------       < [52-62] Mean Motion      ┆
  ┆                                                                -----  < [63-67] revolution #     ┆
  ┆                                                                     - < [   68] checksum         ┆
  ┆                                                                                                  ┆
  ┆ The reference frame of the Earth-centered inertial (ECI) coordinates produced by the SGP4/SDP4   ┆
  ┆ orbital model is true equator, mean equinox (TEME) of epoch.                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        let lineTwoBytes: [UInt8] = Array(line2.utf8)

        stringlet = String(bytes: lineTwoBytes[2...6], encoding: .utf8)!
        let line2SatNumber = base34ID(stringlet.trimmingCharacters(in: .whitespaces))

        guard self.noradIndex == line2SatNumber else {
            throw SatKitError.TLE("Line1 and Line2 NORAD IDs don't match ..")
        }

        stringlet = String(bytes: lineTwoBytes[8...15], encoding: .utf8)!
        self.i₀ = Double(stringlet.trimmingCharacters(in: .whitespaces))! * deg2rad

        stringlet = String(bytes: lineTwoBytes[17...24], encoding: .utf8)!
        self.Ω₀ = Double(stringlet.trimmingCharacters(in: .whitespaces))! * deg2rad

        stringlet = "." + String(bytes: lineTwoBytes[26...32], encoding: .utf8)!
        self.e₀ = Double(stringlet.replacingOccurrences(of: " ", with: "0"))!

        stringlet = String(bytes: lineTwoBytes[34...41], encoding: .utf8)!
        self.ω₀ = Double(stringlet.trimmingCharacters(in: .whitespaces))! * deg2rad

        stringlet = String(bytes: lineTwoBytes[43...50], encoding: .utf8)!
        self.M₀ = Double(stringlet.trimmingCharacters(in: .whitespaces))! * deg2rad

        stringlet = String(bytes: lineTwoBytes[52...62], encoding: .utf8)!
        let n₀ʹ = Double(stringlet.trimmingCharacters(in: .whitespaces))! * (π/720.0)

        stringlet = String(bytes: lineTwoBytes[63...67], encoding: .utf8)!
        self.revNumber = Int(stringlet.trimmingCharacters(in: .whitespaces))!

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ recover (un'Kozai) original mean motion and semi-major axis from the input elements for SGP4x.   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        do {
            let θ = cos(self.i₀)                                    //         cos(i₀)  ..  θ
            let x3thm1 = 3.0 * θ * θ - 1.0                          //      3×cos²(i₀) - 1
            let β₀ = (1.0 - self.e₀ * self.e₀).squareRoot()         //         √(1-e₀²) ..  β₀
            let temp = 1.5 * TLEConstants.K₂ * x3thm1 / (β₀ * β₀ * β₀)

            let a₀ʹ = pow(TLEConstants.kₑ / n₀ʹ, ⅔)
            let δ₁ = temp / (a₀ʹ * a₀ʹ)
            let a₁ = a₀ʹ * (1.0 - δ₁ * (⅓ + δ₁ * (1.0 + 134.0 / 81.0 * δ₁)))
            let δ₀ = temp / (a₁ * a₁)

            self.n₀ = n₀ʹ / (1.0 + δ₀)                               //             n₀
            self.a₀ = a₁  / (1.0 - δ₀)                               //             a₀
        }

        self.apogee = (self.a₀ * (1.0 + self.e₀) - 1.0) * TLEConstants.Rₑ
        self.perigee = (self.a₀ * (1.0 - self.e₀) - 1.0) * TLEConstants.Rₑ

        guard (self.ephemType == 0 || self.ephemType == 2 || self.ephemType == 3) else {
            throw SatKitError.TLE("Line1 ephemerisType ≠ 0, 2 or 3 .. [\(self.ephemType)]")
        }
    }
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Check the lines format validity.                                                                 │
  │            Return true if lines are 69 characters long, format is valid, and checksums are good. │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public func formatOK(_ line1: String, _ line2: String) -> Bool {

    guard line1.lengthOfBytes(using: .utf8) == 69 else {
        print("line1 length ≠ 69: '\(line1)'"); return false
    }
    guard line2.lengthOfBytes(using: .utf8) == 69 else {
        print("line2 length ≠ 69: '\(line2)'"); return false
    }

    let lineOneRegEx = try!
        NSRegularExpression(pattern:
            "1 [ 0-9]{5}[A-Z] [ 0-9]{5}[ A-Z]{3} [ 0-9]{5}[.][ 0-9]{8} (?:(?:[ 0+-][.][ 0-9]{8})|(?: " +
            "[ +-][.][ 0-9]{7})) [ +-][ 0-9]{5}[+-][ 0-9] [ +-][ 0-9]{5}[+-][ 0-9] [ 0-9] [ 0-9]{4}[ 0-9]",
                            options: .caseInsensitive)

    guard lineOneRegEx.numberOfMatches(in: line1,
                                       range: NSRange(location: 0, length: 69)) == 1 else {
        print("line1 format bad: '\(line1)'"); return false
    }

    let lineTwoRegEx = try!
        NSRegularExpression(pattern:
            "2 [ 0-9]{5} [ 0-9]{3}[.][ 0-9]{4} [ 0-9]{3}[.][ 0-9]{4} [ 0-9]{7} [ 0-9]{3}[.][ 0-9]{4} " +
            "[ 0-9]{3}[.][ 0-9]{4} [ 0-9]{2}[.][ 0-9]{13}[ 0-9]",
                            options: .caseInsensitive)

    guard lineTwoRegEx.numberOfMatches(in: line2,
                                       range: NSRange(location: 0, length: 69)) == 1 else {
        print("line2 format bad: '\(line2)'"); return false
    }

    guard checkSumGood(line1) else { print("line1 checksum fail: '\(line1)'"); return false }
    guard checkSumGood(line2) else { print("line2 checksum fail: '\(line2)'"); return false }

    return true
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Do the checksum check on a TLE line ("0"..."9" are 0...9; "-" is 1; last digit is checksum).     │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
private func checkSumGood(_ tleLine: String) -> Bool {
    var     checkSum: UInt8 = 0
    let     bytes = [UInt8](tleLine.utf8)

    for arrayIndex in 0..<68 {
        let byte = bytes[arrayIndex]
        if 48...57 ~= byte { checkSum += (byte - 48) }      // "0"..."9" -> 0...9
        if byte == 45 { checkSum += 1 }                     //    "-"    ->   1
        checkSum %= 10
    }

    guard checkSum == bytes[68] - 48 else {
        print("TLE checksum failed: wanted '\(Character(Unicode.Scalar(bytes[68])))' and " +
                                      "got '\(Character(Unicode.Scalar(checkSum + 48)))'")
        return false
    }
    return true
}

func base10ID(_ noradID: String) -> Int {
    guard let value = Int(noradID) else { return 0 }
    return value
}

//MARK: - Extra Fun !
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Convert silly NORAD ID ("B1234") into an integer .. "B" * 10000 + 1234, where "B" is base-34 ..  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
func base34ID(_ noradID: String) -> Int {               //      "B1234"      "5"
    let lastFive = ("00000" + noradID.uppercased())     // "00000B1234  "000005"
                                            .suffix(5)  //      "B1234"  "00005"
    let byte1 = (lastFive.first)!
    if let seqNo = Int(lastFive.dropFirst()) {

        switch String(byte1) {
        case ..<"0":
            return 0
        case "0"..."9":
            return Int(byte1.asciiValue!-48)*10000 + seqNo
        case "A"..."H":
            return Int(byte1.asciiValue!-55)*10000 + seqNo
        case "J"..."N":
            return Int(byte1.asciiValue!-56)*10000 + seqNo
        case "P"..."Z":
            return Int(byte1.asciiValue!-57)*10000 + seqNo
        default:
            return 0
        }

    }

    return 0
}
