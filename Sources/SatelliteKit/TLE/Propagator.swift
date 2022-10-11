/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Propagator.swift                                                                          SatKit ║
  ║ Created by Gavin Eadie on May24/17         Copyright © 2017-22 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable force_try
// swiftlint:disable function_body_length
// swiftlint:disable identifier_name
// swiftlint:disable statement_position

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  This class provides elements to propagate TLE's.                                                ┃
  ┃                                                                                                  ┃
  ┃  The models used are SGP4 and SDP4, initially proposed by NORAD as the unique convenient         ┃
  ┃  propagator for TLE's. Inputs and outputs of this propagator are only suited for NORAD two lines ┃
  ┃  elements sets, since it uses estimations and mean values appropriate for TLE's only.            ┃
  ┃                                                                                                  ┃
  ┃  Deep- or near- space propagator is selected internally according to NORAD recommendations so    ┃
  ┃  that the user has not to worry about the used computation methods. One instance is created for  ┃
  ┃  each TLE (this instance can only be got using {@link #selectExtrapolator(TLE)} method, and can  ┃
  ┃  compute position and velocity coordinates at any time. Maximum accuracy is guaranteed in a 24h  ┃
  ┃  range period before and after the provided TLE epoch (of course this accuracy is not really     ┃
  ┃  measurable nor predictable: according to "http://www.celestrak.com/", the precision is close to ┃
  ┃  one kilometer and error won't probably rise above 2 Km).                                        ┃
  ┃                                                                                                  ┃
  ┃  This implementation is largely inspired from the paper and source code                          ┃
  ┃                     "http://www.celestrak.com/publications/AIAA/2006-6753/"                      ┃
  ┃                                         and is fully compliant with its results and tests cases. ┃
  ┃                                                                                                  ┃
  ┃  @author Felix R. Hoots, Ronald L. Roehrich, December 1980 (original fortran)                    ┃
  ┃  @author David A. Vallado, Paul Crawford, Richard Hujsak, T.S. Kelso (C++ translation)           ┃
  ┃  @author Fabien Maussion (java translation)                                                      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public struct EarthConstants {

     public static let Rₑ = 6378.137                    // Earth radius (Km) - WGS84

     public static let rotationₑ = 1.00273790934        // Earth sidereal rotations per UT day

    private static let flatteningₑ = (1.0 / 298.25722)
            static let e2 = flatteningₑ * (2.0 - flatteningₑ)

    private static let μₑ = 398600.5                    // gravitational constant (Km³/s²)
            static let kₑ = 60.0 /
                            (EarthConstants.Rₑ*EarthConstants.Rₑ*EarthConstants.Rₑ / μₑ).squareRoot()

    private static let J₂ = +1.08262998905e-3
            static let K₂ =  0.5 * J₂

    private static let J₃ = -2.53215306e-6
            static let J₃OVK₂ = -J₃ / K₂

    private static let J₄ = -1.61098761e-6              
            static let K₄ = -0.375 * J₄

}

public class Propagator {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ c o n s t a n t s   set in init(..)                                                              │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    let tle: Elements

    let perigee: Double                     // perigee (in Kms)
    let θ²: Double                          //

    let M_dot: Double                       // common parameter for mean anomaly (M) computation.
    let ω_dot: Double                       // common parameter for perigee argument (ω) computation.
    let Ω_dot: Double                       // common parameter for raan (Ω) computation.
    let xnodcf: Double                      // common parameter for raan ( ) computation.

    let e₀²: Double                         // original eccentricity squared .. e₀²
    let β₀²: Double                         //                                1-e₀²
    let β₀: Double                          //                              √(1-e₀²)

    let ξ: Double                           // tsi from SPTRCK #3.
    let η: Double                           // eta from SPTRCK #3.
    let η²: Double                          // eta squared.
    let eeta: Double                        // original e₀ * eta.

    let coef: Double                        // coef for SGP C3 computation.
    let coef1: Double                       // coef for SGP C5 computation.

    let c₁: Double                          //  C1 from SPTRCK #3.
    let c₂: Double                          //  C2 from SPTRCK #3.
    let c₄: Double                          //  C4 from SPTRCK #3.
    let t2cof: Double                       // 3/2 * C1.

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ v a r i a b l e s                                                                                │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    var e: Double                           // final eccentricity.
    var i: Double                           // final inclination.
    var ω: Double                           // final argument of perigee.
    var Ω: Double                           // final RA of ascending node.
    var a: Double                           // final semi major axis.

    var sini₀: Double                       // sin original inclination.
    var cosi₀: Double                       // cos original inclination.
    var s: Double                           // s* new value for the contant s.
    var xl: Double                          //   L from SPTRCK #3.

    public init(_ initialTLE: Elements) {

        self.tle = initialTLE
        self.perigee = (self.tle.a₀ * (1.0 - self.tle.e₀) - 1.0) * EarthConstants.Rₑ

        self.e = 0.0                        // ECCENT
        self.i = 0.0                        // INCLIN
        self.ω = 0.0                        // ARGPER
        self.Ω = 0.0                        // RAOFAN
        self.a = 0.0                        // SEMIMA

        self.xl = 0.0                       // L from SPTRCK #3

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ For perigee below 156Km, the values of s and (q₀-s)⁴ are changed                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        switch self.perigee {
        case ..<98.0:       self.s = 20.0
        case 98.0...156.0:  self.s = self.perigee - 78.0
        default:            self.s = 78.0
        }
        let q₀_s = (120.0 - self.s) / EarthConstants.Rₑ
        self.s = self.s / EarthConstants.Rₑ + 1.0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Computation of the first commons parameters.                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        self.sini₀ = sin(self.tle.i₀)
        self.cosi₀ = cos(self.tle.i₀)                       //         cos(i₀)  ..  θ
        self.θ² = self.cosi₀ * self.cosi₀                   //        cos²(i₀)  ..  θ²

        self.e₀² = self.tle.e₀ * self.tle.e₀                //             e₀²
        self.β₀² = 1.0 - self.e₀²                           //          (1-e₀²)
        self.β₀ = (self.β₀²).squareRoot()                   //         √(1-e₀²) ..  β₀

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        self.ξ = 1.0 / (self.tle.a₀ - s)                    //          1/(a₀ʺ-s) .. ξ
        self.η = self.tle.a₀ * self.tle.e₀ * self.ξ         //             a₀ʺ×e×ξ .. η
        self.η² = self.η * self.η
        self.eeta = self.tle.e₀ * self.η                    //                 e×η

        self.coef = q₀_s * q₀_s * q₀_s * q₀_s *
                    self.ξ * self.ξ * self.ξ * self.ξ       //             (q₀-s)⁴ξ⁴
        let ψ² = abs(1.0 - self.η²)                         //                 1-η²
        self.coef1 = self.coef / pow(ψ², 3.5)

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ C2 and C1 coefficients computation :                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let x3thm1 = 3.0 * self.θ² - 1.0                    //      3×cos²(i₀) - 1
        self.c₂ = self.coef1 * self.tle.n₀ *                //            (q₀-s)⁴ξ⁴η₀ʺ(1-η²) ** 7/2 *
                        (self.tle.a₀ * (1.0 + 1.5 * self.η² + self.eeta * (4.0 + self.η²)) +
                         0.75 * EarthConstants.K₂ * self.ξ / ψ² * x3thm1 * (8.0 + 3.0 * self.η² * (8.0 + self.η²)))
        self.c₁ = self.tle.dragCoeff * self.c₂

        let x1mth2 = 1.0 - self.θ²

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ C4 coefficient computation :                                                                     ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        self.c₄ = 2.0 * self.tle.n₀ * self.coef1 * self.tle.a₀ * self.β₀² * (self.η * (2.0 + 0.5 * self.η²) +
            self.tle.e₀ * (0.5 + 2.0 * self.η²) - 2.0 * EarthConstants.K₂ * self.ξ / (self.tle.a₀ * ψ²) *
            (-3.0 * x3thm1 * (1.0 - 2.0 * self.eeta + self.η² * (1.5 - 0.5 * self.eeta)) +
                0.75 * x1mth2 * (2.0 * self.η² - self.eeta * (1.0 + self.η²)) * cos(2.0 * self.tle.ω₀)))

        do {
            let pinv = 1.0 / (self.tle.a₀ * self.β₀²)
            let pinv² = pinv * pinv

            let temp1 =   3.0 * EarthConstants.K₂ * pinv² * self.tle.n₀
            let temp2 = temp1 * EarthConstants.K₂ * pinv²
            let temp3 =  1.25 * EarthConstants.K₄ * pinv² * pinv² * self.tle.n₀

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ atmospheric and gravitation coefs :(Mdf and OMEGAdf)                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            do {
                let θ⁴ = self.θ² * self.θ²
                self.M_dot = self.tle.n₀ + 0.5 * temp1 * self.β₀ * x3thm1 +
                                       0.0625 * temp2 * self.β₀ * (13.0 - 78.0 * self.θ² + 137.0 * θ⁴)

                let x1m5θ² = 1.0 - 5.0 * self.θ²                    //              1-5θ²

                self.ω_dot = -0.5 * temp1 * x1m5θ² + 0.0625 * temp2 * (7.0 - 114.0 * self.θ² + 395.0 * θ⁴) +
                                                              temp3 * (3.0 -  36.0 * self.θ² +  49.0 * θ⁴)
            }

            let xhdot1 = -temp1 * self.cosi₀

            self.Ω_dot = xhdot1 + (0.5 * temp2 * (4.0 - 19.0 * self.θ²) +
                                     2.0 * temp3 * (3.0 - 7.0 * self.θ²)) * self.cosi₀
            self.xnodcf = 3.5 * self.β₀² * xhdot1 * self.c₁
        }
        self.t2cof = 1.5 * self.c₁

        try! sxpInitialize()

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Get the extrapolated position and velocity from an initial TLE, given minutes after epoch.       │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func getPVCoordinates(minsAfterEpoch: Double) throws -> PVCoordinates {

        try sxpPropagate(minsAfterEpoch: minsAfterEpoch)

        return try computePVCoordinates()       // Compute PV with previous calculated parameters

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Get the extrapolated position and velocity from an initial TLE, given a Date.                    │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public func getPVCoordinates(_ date: Date) throws -> PVCoordinates {

        try sxpPropagate(minsAfterEpoch: date.timeIntervalSince(Date(daysSince1950: self.tle.t₀)) / 60.0)

        return try computePVCoordinates()       // Compute PV with previous calculated parameters

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ ** Retrieves the position and velocity.                                                          │
  │  * @return the computed PVCoordinates.                                                           │
  │  * @exception OrekitException if current orbit is out of supported range                         │
  │  * (too large eccentricity, too low perigee ...)                                                 │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private func computePVCoordinates() throws -> PVCoordinates {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ long period periodics                                                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let axn = self.e * cos(self.ω)
        var temp = 1.0 / (self.a * (1.0 - self.e * self.e))
        let xlcof = 0.125 * EarthConstants.J₃OVK₂ * self.sini₀ *
                                                (3.0 + 5.0 * self.cosi₀) / (1.0 + self.cosi₀)
        let aycof = 0.250 * EarthConstants.J₃OVK₂ * self.sini₀
        let aynl = temp * aycof
        let xlt = xl + temp * xlcof * axn
        let ayn = self.e * sin(self.ω) + aynl
        let elsq = axn * axn + ayn * ayn

        if elsq > 1.0 { throw SatKitError.SGP(sgpError: "4: semi-latus rectum < 0.0") }

        let capu = fmod2pi_π(xlt - self.Ω)           // normalize an angle between 0 and 2π

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Dundee changes:  items dependent on cosio get recomputed:                                        ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let cosθ² = self.cosi₀ * self.cosi₀
        let x3thm1 = 3.0 * cosθ² - 1.0
        let x1mth2 = 1.0 - cosθ²
        let x7thm1 = 7.0 * cosθ² - 1.0

        if self.e > (1 - 1e-6) { throw SatKitError.SGP(sgpError: "1: eccentricity too close to 1.0") }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Solve Kepler's Equation ..                                                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var epw = capu
        var sinEPW = 0.0
        var cosEPW = 0.0
        var ecosE = 0.0
        var esinE = 0.0

        let newtonRaphsonEpsilon = 1e-12
        for j in 0...10 {
            var doSecondOrderNewtonRaphson = true

            sinEPW = sin(epw)
            cosEPW = cos(epw)
            ecosE = axn * cosEPW + ayn * sinEPW
            esinE = axn * sinEPW - ayn * cosEPW
            let f = capu - epw + esinE
            if abs(f) < newtonRaphsonEpsilon { break }

            let fdot = 1.0 - ecosE
            var Δepw = f / fdot
            if j == 0 {
                let maxNewtonRaphson = 1.25 * abs(e)
                doSecondOrderNewtonRaphson = false
                if Δepw > maxNewtonRaphson { Δepw = maxNewtonRaphson }
                else if Δepw < -maxNewtonRaphson { Δepw = -maxNewtonRaphson }
                else { doSecondOrderNewtonRaphson = true }
            }
            if doSecondOrderNewtonRaphson {
                Δepw = f / (fdot + 0.5 * esinE * Δepw)
            }
            epw += Δepw
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Short period preliminary quantities                                                              ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        temp = 1.0 - elsq
        let pl = self.a * temp
        let r = self.a * (1.0 - ecosE)
        var temp2 = a / r
        let betal = temp.squareRoot()
        temp = esinE / (1.0 + betal)
        let cosu = temp2 * (cosEPW - axn + ayn * temp)
        let sinu = temp2 * (sinEPW - ayn - axn * temp)
        let u = atan2(sinu, cosu)
        let sin2u = 2.0 * sinu * cosu
        let cos2u = 2.0 * cosu * cosu - 1.0
        let temp1 = EarthConstants.K₂ / pl
        temp2 = temp1 / pl

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update for short periodics                                                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        let rk = r * (1.0 - 1.5 * temp2 * betal * x3thm1) + 0.5 * temp1 * x1mth2 * cos2u

        if rk < 1 { throw SatKitError.SGP(sgpError: "ERROR 6: decay condition .. radius < 1.0 ") }

        let uk = u - 0.25 * temp2 * x7thm1 * sin2u
        let xnodek = self.Ω + 1.5 * temp2 * self.cosi₀ * sin2u
        let xinck = self.i + 1.5 * temp2 * self.cosi₀ * self.sini₀ * cos2u

        // Orientation vectors
        let sinuk = sin(uk)
        let cosuk = cos(uk)
        let sinik = sin(xinck)
        let cosik = cos(xinck)
        let sinnok = sin(xnodek)
        let cosnok = cos(xnodek)
        let xmx = -sinnok * cosik
        let xmy =  cosnok * cosik
        let ux = xmx * sinuk + cosnok * cosuk
        let uy = xmy * sinuk + sinnok * cosuk
        let uz = sinik * sinuk

        // Position and velocity
        let cr = 1000.0 * rk * EarthConstants.Rₑ
        let pos = Vector(cr * ux, cr * uy, cr * uz)

        let rdot   = EarthConstants.kₑ * √a * esinE / r
        let rfdot  = EarthConstants.kₑ * √pl / r
        let xn     = EarthConstants.kₑ / (a * √a)
        let rdotk  = rdot - xn * temp1 * x1mth2 * sin2u
        let rfdotk = rfdot + xn * temp1 * (x1mth2 * cos2u + 1.5 * x3thm1)
        let vx     = xmx * cosuk - cosnok * sinuk
        let vy     = xmy * cosuk - sinnok * sinuk
        let vz     = sinik * cosuk

        let cv = 1000.0 * EarthConstants.Rₑ / 60.0
        let vel = Vector(cv * (rdotk * ux + rfdotk * vx),
                         cv * (rdotk * uy + rfdotk * vy),
                         cv * (rdotk * uz + rfdotk * vz))

        if (cv * (rdotk * ux + rfdotk * vx)).isNaN { throw SatKitError.SGP(sgpError: "nan") }

        return PVCoordinates(position: pos, velocity: vel)

    }

    func sxpInitialize() throws {
        preconditionFailure("'Propagator.sxpInitialize' must be overridden")
    }

    func sxpPropagate(minsAfterEpoch: Double) throws {
        preconditionFailure(" 'Propagator.sxpPropagate' must be overridden")
    }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Period >= 225 minutes is deep space                                                              │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public func selectPropagator(tle: Elements) -> Propagator {

    if tle.ephemType == 2 { return SGP4(tle) }
    else if tle.ephemType == 3 { return DeepSDP4(tle) }
    else { return (π*2) / (tle.n₀ * TimeConstants.day2min) < (1.0 / 6.4) ? SGP4(tle) : DeepSDP4(tle) }

}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Period >= 225 minutes is deep space                                                              │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public func selectPropagator(_ elements: Elements) -> Propagator {

    if elements.ephemType == 2 { return SGP4(elements) }
    else if elements.ephemType == 3 { return DeepSDP4(elements) }
    else { return (π*2) / (elements.n₀ * TimeConstants.day2min) < (1.0 / 6.4) ?
                                                            SGP4(elements) : DeepSDP4(elements) }

}
