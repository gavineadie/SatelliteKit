/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ DeepSDP4.swift                                                                            SatKit ║
  ║ Created by Gavin Eadie on 5/24/17.         Copyright © 2017-19 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable shorthand_operator
// swiftlint:disable file_length
// swiftlint:disable line_length

class DeepSDP4: SDP4 {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  c o n s t a n t s                                                                               │
  │     znSolar ≈ 2π ÷ (solar orbit - year in days) ÷ minutes per day                                │
  │     znLunar ≈ 2π ÷ (lunar orbit - month in days) ÷ minutes per day                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private let zeSolar  =  0.01675                     // mean eccentricity of the sun's 'orbit'
    private let zeLunar  =  0.05490                     // mean eccentricity of the moon's orbit

    private let znSolar  =  1.19459E-5                  // d(solar mean anomaly)/dt .. rads/min
    private let znLunar  =  1.5835218E-4                // d(lunar mean anomaly)/dt .. rads/min

    private let THDT     =  4.3752691E-3                // angular velocity of the earth (rads/min)
    private let C1SS     =  2.9864797E-6
    private let C1L      =  4.7968065E-7

    private let SECULAR_INTEGRATION_STEP  = 720.0       // Integration step (seconds)

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  i n t e r m e d i a t e   v a l u e s                                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private var gmst = 0.0
    private var xnq = 0.0                               // mean motion (rad/min)
    private var zmol = 0.0
    private var zmos = 0.0
    private var savtsn = 0.0

    private var ee2 = 0.0
    private var e3 = 0.0
    private var xi2 = 0.0
    private var xi3 = 0.0
    private var xl2 = 0.0
    private var xl3 = 0.0
    private var xl4 = 0.0
    private var xgh2 = 0.0
    private var xgh3 = 0.0
    private var xgh4 = 0.0
    private var xh2 = 0.0
    private var xh3 = 0.0

    private var d2201 = 0.0
    private var d2211 = 0.0
    private var d3210 = 0.0
    private var d3222 = 0.0
    private var d4410 = 0.0
    private var d4422 = 0.0
    private var d5220 = 0.0
    private var d5232 = 0.0
    private var d5421 = 0.0
    private var d5433 = 0.0
    private var xlamo = 0.0

    private var sse = 0.0
    private var ssi = 0.0
    private var ssl = 0.0
    private var ssh = 0.0
    private var ssg = 0.0
    private var se2 = 0.0
    private var si2 = 0.0
    private var sl2 = 0.0
    private var sgh2 = 0.0
    private var sh2 = 0.0
    private var se3 = 0.0
    private var si3 = 0.0
    private var sl3 = 0.0
    private var sgh3 = 0.0
    private var sh3 = 0.0
    private var sl4 = 0.0
    private var sgh4 = 0.0

    private var del1 = 0.0
    private var del2 = 0.0
    private var del3 = 0.0
    private var xfact = 0.0
    private var xli = 0.0
    private var xni = 0.0
    private var atime = 0.0

    private var derivs0 = 0.0
    private var derivs1 = 0.0

    private var resonant = false                    // for resonant orbits.
    private var synchronous = false                 // for synchronous orbits.
    private var isDundeeCompliant = true            // for compliance with Dundee modifications.

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Computes luni - solar terms from initial coordinates and epoch.                                 │
  │                          [Orekit] .. exception OrekitException when UTC time steps can't be read │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func luniSolarTermsComputation() throws {

        let sinq = sin(super.tle.Ω₀)
        let cosq = cos(super.tle.Ω₀)
        let aqnv = 1.0 / super.tle.a₀

        var cc = C1SS
        var ze = zeSolar
        var zn = znSolar

        gmst = zeroMeanSiderealTime(julianDate: super.tle.t₀ + JD.epoch1950) * deg2rad
        xnq = super.tle.n₀
//      omegaq = super.tle.ω₀

        let days₁₉₀₀ = super.tle.t₀ + (JD.epoch1950 - JD.epoch1900)    // Compute days since 1900

        let lunar_asc_node = 4.5236020 - 9.2422029e-4 * days₁₉₀₀
        let stem = sin(lunar_asc_node)
        let ctem = cos(lunar_asc_node)
        let c_minus_gam = 0.228027132 * days₁₉₀₀ - 1.1151842
        let gam = 5.8351514 + 0.0019443680 * days₁₉₀₀                   // longitude of lunar perigee (rads)

        let zcosil = 0.91375164 - 0.03568096 * ctem
        let zsinil = sqrt(1.0 - zcosil * zcosil)
        let zsinhl = 0.089683511 * stem / zsinil
        let zcoshl = sqrt(1.0 - zsinhl * zsinhl)

        zmol = fmod2pi_π(c_minus_gam)

        var zx = 0.39785416 * stem / zsinil
        let zy = zcoshl * ctem + 0.91744867 * zsinhl * stem
        zx = atan2(zx, zy) + gam - lunar_asc_node
        let zcosgl = cos(zx)
        let zsingl = sin(zx)
        zmos = fmod2pi_π(6.2565837 + 0.017201977 * days₁₉₀₀)

        savtsn = 1e20                       // do solar terms

        var zsing = -0.98088458             // sin of -78.779197 degrees
        var zcosg =  0.1945905              // cos   ..   ..   ..
        var zsinh = sinq
        var zcosh = cosq
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ obliquity of earth's orbit = 23.444100 degrees ..  matches obliquity in 1963                     ┆
  ┆                                                        probably just a slightly inaccurate value ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var zsini =  0.39785416             // sin of 23.444100 degrees
        var zcosi =  0.91744867             // cos   ..   ..   ..

        var se = 0.0
        var sgh = 0.0
        var sh = 0.0
        var si = 0.0
        var sl = 0.0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ There was previously some convoluted logic here, but it boils down to this: we compute the solar ┆
  ┆ terms,  then the lunar terms. On a second pass,  we recompute the solar terms, taking advantage  ┆
  ┆ of the improved data that resulted from computing lunar terms.                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        for iteration in 0...1 {
            let a1 =  zcosg * zcosh + zsing * zcosi * zsinh
            let a3 = -zsing * zcosh + zcosg * zcosi * zsinh
            let a7 = -zcosg * zsinh + zsing * zcosi * zcosh
            let a8 =  zsing * zsini
            let a9 =  zsing * zsinh + zcosg * zcosi * zcosh
            let a10 = zcosg * zsini

            let a2 =  super.cosi₀ * a7 + super.sini₀ * a8
            let a4 =  super.cosi₀ * a9 + super.sini₀ * a10
            let a5 = -super.sini₀ * a7 + super.cosi₀ * a8
            let a6 = -super.sini₀ * a9 + super.cosi₀ * a10

			let sing = sin(super.tle.ω₀)
			let cosg = cos(super.tle.ω₀)

            let x1 =  a1 * cosg + a2 * sing
            let x2 =  a3 * cosg + a4 * sing
            let x3 = -a1 * sing + a2 * cosg
            let x4 = -a3 * sing + a4 * cosg
            let x5 =  a5 * sing
            let x6 =  a6 * sing
            let x7 =  a5 * cosg
            let x8 =  a6 * cosg

            let z31 = 12.0 * x1 * x1 - 3.0 * x3 * x3
            let z32 = 24.0 * x1 * x2 - 6.0 * x3 * x4
            let z33 = 12.0 * x2 * x2 - 3.0 * x4 * x4
            let z11 = -6.0 * a1 * a5 + super.e₀² * (-24.0 * x1 * x7 - 6.0 * x3 * x5)
            let z12 = -6.0 * (a1 * a6 + a3 * a5) + super.e₀² * (-24.0 * (x2 * x7 + x1 * x8) - 6.0 * (x3 * x6 + x4 * x5))
            let z13 = -6.0 * a3 * a6 + super.e₀² * (-24.0 * x2 * x8 - 6.0 * x4 * x6)
            let z21 =  6.0 * a2 * a5 + super.e₀² * (24.0 * x1 * x5 - 6.0 * x3 * x7)
            let z22 =  6.0 * (a4 * a5 + a2 * a6) + super.e₀² * (24.0 * (x2 * x5 + x1 * x6) - 6.0 * (x4 * x7 + x3 * x8))
            let z23 =  6.0 * a4 * a6 + super.e₀² * (24.0 * x2 * x6 - 6.0 * x4 * x8)

            let s3 = cc / xnq
            let s2 = -0.5 * s3 / super.β₀
            let s4 = s3 * super.β₀
            let s1 = -15.0 * tle.e₀ * s4
            let s5 = x1 * x3 + x2 * x4
            let s6 = x2 * x3 + x1 * x4
            let s7 = x2 * x4 - x1 * x3

            var z1 = 3.0 * (a1 * a1 + a2 * a2) + z31 * super.e₀²
            var z2 = 6.0 * (a1 * a3 + a2 * a4) + z32 * super.e₀²
            var z3 = 3.0 * (a3 * a3 + a4 * a4) + z33 * super.e₀²

            z1 = z1 + z1 + super.β₀² * z31
            z2 = z2 + z2 + super.β₀² * z32
            z3 = z3 + z3 + super.β₀² * z33
            se = s1 * zn * s5
            si = s2 * zn * (z11 + z13)
            sl = -zn * s3 * (z1 + z3 - 14.0 - 6.0 * super.e₀²)
            sgh = s4 * zn * (z31 + z33 - 6.0)

            sh = super.tle.i₀ < π/60 ? 0.0 : -zn * s2 * (z21 + z23)

            ee2  =   2.0 * s1 * s6
            e3   =   2.0 * s1 * s7
            xi2  =   2.0 * s2 * z12
            xi3  =   2.0 * s2 * (z13 - z11)
            xl2  =  -2.0 * s3 * z2
            xl3  =  -2.0 * s3 * (z3 - z1)
            xl4  =  -2.0 * s3 * (-21.0 - 9.0 * super.e₀²) * ze
            xgh2 =   2.0 * s4 * z32
            xgh3 =   2.0 * s4 * (z33 - z31)
            xgh4 = -18.0 * s4 * ze
            xh2  =  -2.0 * s2 * z22
            xh3  =  -2.0 * s2 * (z23 - z21)

            if iteration == 0 {                         // compute lunar terms only on the first pass
                sse = se
                ssi = si
                ssl = sl
                ssh = super.tle.i₀ < π/60 ? 0.0 : sh / super.sini₀
                ssg = sgh - super.cosi₀ * ssh
                se2 = ee2
                si2 = xi2
                sl2 = xl2
                sgh2 = xgh2
                sh2 = xh2
                se3 = e3
                si3 = xi3
                sl3 = xl3
                sgh3 = xgh3
                sh3 = xh3
                sl4 = xl4
                sgh4 = xgh4

                zcosg = zcosgl
                zsing = zsingl
                zcosi = zcosil
                zsini = zsinil
                zcosh = zsinhl * sinq + zcoshl * cosq
                zsinh = zcoshl * sinq - zsinhl * cosq
                zn = znLunar
                cc = C1L
                ze = zeLunar
            }
        } // end of solar - lunar - solar terms computation

        sse += se
        ssi += si
        ssl += sl
        ssg += sgh - (super.tle.i₀ < π/60 ? 0 : sh * super.cosi₀ / super.sini₀)
        ssh +=        super.tle.i₀ < π/60 ? 0 : sh               / super.sini₀

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Start the resonant-synchronous tests and initialization                                          ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        var bfact = 0.0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if mean motion is 1.893053 to 2.117652 revs/day, and eccentricity >= 0.5,                        ┆
  ┆ start of the 12-hour orbit, e > 0.5 section                                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if xnq >= 1.893053 * π/720 && xnq <= 2.117652 * π/720 && super.tle.e₀ >= 0.5 {

            resonant = true             // it is resonant...
            synchronous = false         // but it's not synchronous

            let sini₀² = super.sini₀ * super.sini₀

            let g201 = -0.306 - (super.tle.e₀ - 0.64) * 0.440
            let f220 = 0.75 * (1.0 + 2.0 * super.cosi₀ + super.θ²)
            let f221 = 1.5 * sini₀²
            let f321 =  1.875 * super.sini₀ * (1.0 - 2.0 * super.cosi₀ - 3.0 * super.θ²)
            let f322 = -1.875 * super.sini₀ * (1.0 + 2.0 * super.cosi₀ - 3.0 * super.θ²)
            let f441 = 35.0 * sini₀² * f220
            let f442 = 39.3750 * sini₀² * sini₀²
            let f522 = 9.84375 * super.sini₀ * (sini₀² * (1.0 - 2.0 * super.cosi₀ - 5.0 * super.θ²) +
                                            ⅓ * (-2.0 + 4.0 * super.cosi₀ + 6.0 * super.θ²))
            let f523 = super.sini₀ * (4.92187512 * sini₀² * (-2.0 - 4.0 * super.cosi₀ + 10.0 * super.θ²) +
                                            6.56250012 * (1.0 + 2.0 * super.cosi₀ - 3.0 * super.θ²))
            let f542 = 29.53125 * super.sini₀ * ( 2.0 - 8.0 * super.cosi₀ + super.θ² * (-12.0 + 8.0 * super.cosi₀ + 10.0 * super.θ²))
            let f543 = 29.53125 * super.sini₀ * (-2.0 - 8.0 * super.cosi₀ + super.θ² * ( 12.0 + 8.0 * super.cosi₀ - 10.0 * super.θ²))

            do {
                var g211: Double
                var g310: Double
                var g322: Double
                var g410: Double
                var g422: Double
                var g520: Double

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Geopotential resonance initialization for 12 hour orbits ..                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
//              let e₀³ = super.tle.e₀ * super.e₀²
                if super.tle.e₀ <= 0.65 {

//                  g211 =    3.616  -   13.247  * super.tle.e₀ +   16.290  * super.e₀²
//                  g310 =  -19.302  +  117.390  * super.tle.e₀ -  228.419  * super.e₀² +  156.591  * e₀³
//                  g322 =  -18.9068 +  109.7927 * super.tle.e₀ -  214.6334 * super.e₀² +  146.5816 * e₀³
//                  g410 =  -41.122  +  242.694  * super.tle.e₀ -  471.094  * super.e₀² +  313.953  * e₀³
//                  g422 = -146.407  +  841.880  * super.tle.e₀ - 1629.014  * super.e₀² + 1083.435  * e₀³
//                  g520 = -532.114  + 3017.977  * super.tle.e₀ - 5740.032  * super.e₀² + 3708.276  * e₀³

                    g211 = cubicPoly(tle.e₀, p⁰:    3.616,  p¹:  -13.247,  p²:   +16.290,  p³:    0.0)
                    g310 = cubicPoly(tle.e₀, p⁰:  -19.302,  p¹:  117.390,  p²:  -228.419,  p³:  156.591)
                    g322 = cubicPoly(tle.e₀, p⁰:  -18.9068, p¹:  109.7927, p²:  -214.6334, p³:  146.5816)
                    g410 = cubicPoly(tle.e₀, p⁰:  -41.122,  p¹:  242.694,  p²:  -471.094,  p³:  313.953)
                    g422 = cubicPoly(tle.e₀, p⁰: -146.407,  p¹:  841.880,  p²: -1629.014,  p³: 1083.435)
                    g520 = cubicPoly(tle.e₀, p⁰: -532.114,  p¹: 3017.977,  p²: -5740.032,  p³: 3708.276)

                } else {

//                  g211 =   -72.099 +   331.819 * super.tle.e₀ -   508.738 * super.e₀² +   266.724 * e₀³
//                  g310 =  -346.844 +  1582.851 * super.tle.e₀ -  2415.925 * super.e₀² +  1246.113 * e₀³
//                  g322 =  -342.585 +  1554.908 * super.tle.e₀ -  2366.899 * super.e₀² +  1215.972 * e₀³
//                  g410 = -1052.797 +  4758.686 * super.tle.e₀ -  7193.992 * super.e₀² +  3651.957 * e₀³
//                  g422 = -3581.69  + 16178.11  * super.tle.e₀ -  24462.77 * super.e₀² + 12422.52  * e₀³
//                  if super.tle.e₀ <= 0.715 {
//                      g520 =  1464.74 -  4664.75 * super.tle.e₀ +  3763.64 * super.e₀²
//                  } else {
//                      g520 = -5149.66 + 29936.92 * super.tle.e₀ - 54087.36 * super.e₀² + 31324.56 * e₀³
//                  }

                    g211 = cubicPoly(tle.e₀, p⁰:   -72.099, p¹:  331.819, p²:  -508.738, p³:  266.724)
                    g310 = cubicPoly(tle.e₀, p⁰:  -346.844, p¹: 1582.851, p²: -2415.925, p³: 1246.113)
                    g322 = cubicPoly(tle.e₀, p⁰:  -342.585, p¹: 1554.908, p²: -2366.899, p³: 1215.972)
                    g410 = cubicPoly(tle.e₀, p⁰: -1052.797, p¹: 4758.686, p²: -7193.992, p³: 3651.957)
                    g422 = cubicPoly(tle.e₀, p⁰: -3581.69,  p¹: 16178.11, p²: -24462.77, p³: 12422.52)

                    g520 = tle.e₀ <= 0.715 ? cubicPoly(tle.e₀, p⁰:  1464.74, p¹: -4664.75, p²:   3763.64, p³:     0.0)
                                           : cubicPoly(tle.e₀, p⁰: -5149.66, p¹: 29936.92, p²: -54087.36, p³: 31324.56)

                }

                do {

//                  let g521 = tle.e₀ < 0.7 ? -822.71072 + 4568.6173 * super.tle.e₀ - 8491.4146 * super.e₀² + 5337.524  * e₀³
//                                          : -51752.104 + 218913.95 * super.tle.e₀ - 309468.16 * super.e₀² + 146349.42 * e₀³
//                  let g532 = tle.e₀ < 0.7 ? -853.666   + 4690.25   * super.tle.e₀ - 8624.77   * super.e₀² + 5341.4    * e₀³
//                                          : -40023.88  + 170470.89 * super.tle.e₀ - 242699.48 * super.e₀² + 115605.82 * e₀³
//                  let g533 = tle.e₀ < 0.7 ? -919.2277  + 4988.61   * super.tle.e₀ - 9064.77   * super.e₀² + 5542.21   * e₀³
//                                          : -37995.78  + 161616.52 * super.tle.e₀ - 229838.2  * super.e₀² + 109377.94 * e₀³

                    let g521 = tle.e₀ < 0.7 ? cubicPoly(tle.e₀, p⁰:   -822.71072, p¹:   4568.6173, p²:   -8491.4146, p³:   5337.524)
                                            : cubicPoly(tle.e₀, p⁰: -51752.104,   p¹: 218913.95,   p²: -309468.16,   p³: 146349.42)
                    let g532 = tle.e₀ < 0.7 ? cubicPoly(tle.e₀, p⁰:   -853.666,   p¹:   4690.25,   p²:   -8624.77,   p³:   5341.4)
                                            : cubicPoly(tle.e₀, p⁰: -40023.88,    p¹: 170470.89,   p²: -242699.48,   p³: 115605.82)
                    let g533 = tle.e₀ < 0.7 ? cubicPoly(tle.e₀, p⁰:   -919.2277,  p¹:   4988.61,   p²:   -9064.77,   p³:   5542.21)
                                            : cubicPoly(tle.e₀, p⁰: -37995.78,    p¹: 161616.52,   p²: -229838.2,    p³: 109377.94)

                    let ROOT22   =  1.7891679E-6
                    let ROOT32   =  3.7393792E-7
                    let ROOT44   =  7.3636953E-9
                    let ROOT52   =  1.1428639E-7
                    let ROOT54   =  2.1765803E-9

                    do {
                        var temp1 = 3.0 * xnq * xnq * aqnv * aqnv
                        var temp = temp1 * ROOT22
                        d2201 = temp * f220 * g201
                        d2211 = temp * f221 * g211
                        temp1 *= aqnv
                        temp = temp1 * ROOT32
                        d3210 = temp * f321 * g310
                        d3222 = temp * f322 * g322
                        temp1 *= aqnv
                        temp = 2.0 * temp1 * ROOT44
                        d4410 = temp * f441 * g410
                        d4422 = temp * f442 * g422
                        temp1 *= aqnv
                        temp = temp1 * ROOT52
                        d5220 = temp * f522 * g520
                        d5232 = temp * f523 * g532
                        temp = 2.0 * temp1 * ROOT54
                        d5421 = temp * f542 * g521
                        d5433 = temp * f543 * g533
                    }
                }
            }

            xlamo = super.tle.M₀ + super.tle.Ω₀ + super.tle.Ω₀ - gmst - gmst
            bfact = super.M_dot + super.Ω_dot + super.Ω_dot - THDT - THDT
            bfact += ssl + ssh + ssh
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if mean motion is .8 to 1.2 revs/day : (geosynch)   1 rev/day = 2π/24/60 = (π/720.0) rad/min ..  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        else if xnq > 0.8 * π/720 && xnq < 1.2 * π/720 {

            resonant = true
            synchronous = true

            let Q22      =  1.7891679E-6
            let Q31      =  2.1460748E-6
            let Q33      =  2.2123015E-7

            do {
                let cosio_plus_1 = 1.0 + super.cosi₀
                let g200 = 1.0 + super.e₀² * (-2.5 + 0.8125  * super.e₀²)
                let g300 = 1.0 + super.e₀² * (-6.0 + 6.60937 * super.e₀²)
                let f311 = 0.9375 * super.sini₀ * super.sini₀ *
                                                (1.0 + 3.0 * super.cosi₀) - 0.75 * cosio_plus_1
                let g310 = 1.0 + 2.0 * super.e₀²
                let f220 = 0.75 * cosio_plus_1 * cosio_plus_1
                let f330 = 2.5 * f220 * cosio_plus_1
                // Synchronous resonance terms initialization
                del1 = 3.0 * xnq * xnq * aqnv * aqnv
                del2 = 2.0 * del1 * f220 * g200 * Q22
                del3 = 3.0 * del1 * f330 * g300 * Q33 * aqnv
                del1 = del1 * f311 * g310 * Q31 * aqnv
            }
            xlamo = super.tle.M₀ + super.tle.Ω₀ + super.tle.ω₀ - gmst
            bfact = super.M_dot + super.ω_dot + super.Ω_dot - THDT
            bfact += ssl + ssg + ssh
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ it's neither a high-e 12-hours orbit nor a geosynchronous:                                       ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        else {
            resonant = false
            synchronous = false
        }

        if resonant {
            xfact = bfact - xnq

            // Initialize integrator
            xli   = xlamo
            xni   = xnq
            atime = 0
        }

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Computes secular terms from current coordinates and epoch.                                      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func deepSecularEffects(minutesFromEphoch mins: Double) {

        super.xll   += ssl * mins
        super.Ω     += ssh * mins
        super.ω_new += ssg * mins
        super.e_new  = super.tle.e₀ + sse * mins
        super.i_new  = super.tle.i₀ + ssi * mins

        if resonant {
/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ If we're closer to t = 0 than to the currently-stored data from the previous call to this        ┆
  ┆ function, then we're better off "restarting",  going back to the initial data. The Dundee code   ┆
  ┆ rigs things up to _always_ take 720-minute steps from epoch to end time, except for the final    ┆
  ┆ step. Easiest way to arrange similar behavior in this code is just to always do a restart,       ┆
  ┆ if we're in Dundee-compliant mode.                                                               ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            if abs(mins) < abs(mins - atime) || isDundeeCompliant {
                atime = 0.0                     // Epoch restart
                xni = xnq
                xli = xlamo
            }

            var lastIntegrationStep = false
            while !lastIntegrationStep {        // if |step|>|step max| then do one step at step max
                var delt = mins - atime
                if delt > SECULAR_INTEGRATION_STEP {
                    delt = SECULAR_INTEGRATION_STEP
                } else if delt < -SECULAR_INTEGRATION_STEP {
                    delt = -SECULAR_INTEGRATION_STEP
                } else {
                    lastIntegrationStep = true
                }

                computeSecularDerivs()

                let xldot = xni + xfact

                var xlpow = 1.0
                xli += delt * xldot
                xni += delt * derivs0
                var delt_factor = delt

                xlpow *= xldot
                derivs1 *= xlpow
                delt_factor *= delt / 2.0
                xli += delt_factor * derivs0
                xni += delt_factor * derivs1

                atime += delt
            }

            super.n_new = xni
            let temp = -super.Ω + gmst + mins * THDT
            super.xll = xli + temp + (synchronous ? -ω_new : temp)
        }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Computes periodic terms from current coordinates and epoch.                             [dpper] │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func deepPeriodicEffects(minutesFromEphoch mins: Double) {

        var pe = 0.0
        var pinc = 0.0
        var pl = 0.0
        var pgh = 0.0
        var ph = 0.0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ If the time didn't change by more than 30 minutes, there's no good reason to recompute the       ┆
  ┆ perturbations they don't change enough over so short a time span. However, the Dundee code       ┆
  ┆ _always_ recomputes, so if we're attempting to replicate its results, we've gotta recompute      ┆
  ┆ everything, too.                                                                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if (abs(savtsn - mins) >= 30.0) || isDundeeCompliant {

            savtsn = mins

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update solar perturbations for time T                                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            var zm = zmos + znSolar * mins
            var zf = zm + 2.0 * zeSolar * sin(zm)
            var sinzf = sin(zf)
            var f2 = 0.5 * sinzf * sinzf - 0.25
            var f3 = -0.5 * sinzf * cos(zf)
            let seSolar = se2 * f2 + se3 * f3
            let siSolar = si2 * f2 + si3 * f3
            let slSolar = sl2 * f2 + sl3 * f3 + sl4 * sinzf
            let sgSolar = sgh2 * f2 + sgh3 * f3 + sgh4 * sinzf
            let shSolar = sh2 * f2 + sh3 * f3

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update lunar perturbations for time T                                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            zm = zmol + znLunar * mins
            zf = zm + 2.0 * zeLunar * sin(zm)
            sinzf = sin(zf)
            f2 =  0.5 * sinzf * sinzf - 0.25
            f3 = -0.5 * sinzf * cos(zf)
            let seLunar = ee2 * f2 + e3 * f3
            let siLunar = xi2 * f2 + xi3 * f3
            let slLunar = xl2 * f2 + xl3 * f3 + xl4 * sinzf
            let sgLunar = xgh2 * f2 + xgh3 * f3 + xgh4 * sinzf
            let shLunar = xh2 * f2 + xh3 * f3

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Sum the solar and lunar contributions                                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            pe   = seSolar + seLunar
            pinc = siSolar + siLunar
            pl   = slSolar + slLunar
            pgh  = sgSolar + sgLunar
            ph   = shSolar + shLunar
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  Add solar/lunar perturbation correction to eccentricity ..                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        e_new += pe
        xll   += pl
        ω_new += pgh
        i_new += pinc
        i_new  = fmod2pi_0(i_new)

        let sinis = sin(i_new)
        let cosis = cos(i_new)

        if abs(i_new) >= 0.2 {                  // Apply periodics directly
            let temp_val = ph / sinis
            ω_new -= cosis * temp_val
            super.Ω += temp_val
        } else {                                // Apply periodics with Lyddane modification
            let sinok = sin(super.Ω)
            let cosok = cos(super.Ω)
            let alfdp =  ph * cosok + (pinc * cosis + sinis) * sinok
            let betdp = -ph * sinok + (pinc * cosis + sinis) * cosok
            let Δxnode = fmod2pi_0(atan2(alfdp, betdp) - super.Ω)
            let dls = -super.Ω * sinis * pinc
            ω_new += dls - cosis * Δxnode
            super.Ω += Δxnode
        }
    }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆  Computes internal secular derivs ..                                                             ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
    private func computeSecularDerivs() {

        let sin_li = sin(xli)
        let cos_li = cos(xli)
        let sin_2li = 2.0 * sin_li * cos_li
        let cos_2li = 2.0 * cos_li * cos_li - 1.0

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Dot terms calculated, using a lot of trig add/subtract identities to reduce the computational    ┆
  ┆ load .. at the cost of making the code somewhat hard to follow:                                  ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/

        if synchronous {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ const double fasx2 = 0.1313091 radians =   7.523456 degrees                                      ┆
  ┆ const double fasx4 = 2.8843198 radians = 165.259351 degrees                                      ┆
  ┆ const double fasx6 = 0.3744809 radians =  21.456173 degrees                                      ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let C_FASX2  =  0.99139134268488593             // cos(fasx2)
            let S_FASX2  =  0.13093206501640101
            let C_2FASX4 =  0.87051638752972937             // cos(2×fasx4)
            let S_2FASX4 = -0.49213943048915526
            let C_3FASX6 =  0.43258117585763334             // cos(3×fasx6)
            let S_3FASX6 =  0.90159499016666422

            let sin_3li = sin_2li * cos_li + cos_2li * sin_li
            let cos_3li = cos_2li * cos_li - sin_2li * sin_li

            let term1a =       del1 * (sin_li  * C_FASX2  - cos_li  * S_FASX2)
            let term2a =       del2 * (sin_2li * C_2FASX4 - cos_2li * S_2FASX4)
            let term3a =       del3 * (sin_3li * C_3FASX6 - cos_3li * S_3FASX6)

            let term1b =       del1 * (cos_li  * C_FASX2  + sin_li  * S_FASX2)
            let term2b = 2.0 * del2 * (cos_2li * C_2FASX4 + sin_2li * S_2FASX4)
            let term3b = 3.0 * del3 * (cos_3li * C_3FASX6 + sin_3li * S_3FASX6)

            derivs0 = term1a + term2a + term3a
            derivs1 = term1b + term2b + term3b

        } else {                                // orbit is a 12-hour resonant one

            let xomi = super.tle.ω₀ + super.ω_dot * atime
            let sin_omi = sin(xomi)
            let cos_omi = cos(xomi)
            let sin_li_m_omi = sin_li * cos_omi - sin_omi * cos_li
            let sin_li_p_omi = sin_li * cos_omi + sin_omi * cos_li
            let cos_li_m_omi = cos_li * cos_omi + sin_omi * sin_li
            let cos_li_p_omi = cos_li * cos_omi - sin_omi * sin_li
            let sin_2omi = 2.0 * sin_omi * cos_omi
            let cos_2omi = 2.0 * cos_omi * cos_omi - 1.0
            let sin_2li_m_omi = sin_2li * cos_omi - sin_omi * cos_2li
            let sin_2li_p_omi = sin_2li * cos_omi + sin_omi * cos_2li
            let cos_2li_m_omi = cos_2li * cos_omi + sin_omi * sin_2li
            let cos_2li_p_omi = cos_2li * cos_omi - sin_omi * sin_2li
            let sin_2li_p_2omi = sin_2li * cos_2omi + sin_2omi * cos_2li
            let cos_2li_p_2omi = cos_2li * cos_2omi - sin_2omi * sin_2li
            let sin_2omi_p_li = sin_li * cos_2omi + sin_2omi * cos_li
            let cos_2omi_p_li = cos_li * cos_2omi - sin_2omi * sin_li

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ const double g22 =  5.7686396                                                                    ┆
  ┆ const double g32 =  0.95240898                                                                   ┆
  ┆ const double g44 =  1.8014998                                                                    ┆
  ┆ const double g52 =  1.0508330                                                                    ┆
  ┆ const double g54 =  4.4108898                                                                    ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
            let C_G22    =  0.87051638752972937
            let S_G22    = -0.49213943048915526
            let C_G32    =  0.57972190187001149
            let S_G32    =  0.81481440616389245
            let C_G44    = -0.22866241528815548
            let S_G44    =  0.97350577801807991
            let C_G52    =  0.49684831179884198
            let S_G52    =  0.86783740128127729
            let C_G54    = -0.29695209575316894
            let S_G54    = -0.95489237761529999

            let term1a = d2201 * (sin_2omi_p_li * C_G22 - cos_2omi_p_li * S_G22) +
                         d2211 * (sin_li * C_G22 - cos_li * S_G22) +
                         d3210 * (sin_li_p_omi * C_G32 - cos_li_p_omi * S_G32) +
                         d3222 * (sin_li_m_omi * C_G32 - cos_li_m_omi * S_G32) +
                         d5220 * (sin_li_p_omi * C_G52 - cos_li_p_omi * S_G52) +
                         d5232 * (sin_li_m_omi * C_G52 - cos_li_m_omi * S_G52)
            let term2a = d4410 * (sin_2li_p_2omi * C_G44 - cos_2li_p_2omi * S_G44) +
                         d4422 * (sin_2li * C_G44 - cos_2li * S_G44) +
                         d5421 * (sin_2li_p_omi * C_G54 - cos_2li_p_omi * S_G54) +
                         d5433 * (sin_2li_m_omi * C_G54 - cos_2li_m_omi * S_G54)
            let term1b = d2201 * (cos_2omi_p_li * C_G22 + sin_2omi_p_li * S_G22) +
                         d2211 * (cos_li * C_G22 + sin_li * S_G22) +
                         d3210 * (cos_li_p_omi * C_G32 + sin_li_p_omi * S_G32) +
                         d3222 * (cos_li_m_omi * C_G32 + sin_li_m_omi * S_G32) +
                         d5220 * (cos_li_p_omi * C_G52 + sin_li_p_omi * S_G52) +
                         d5232 * (cos_li_m_omi * C_G52 + sin_li_m_omi * S_G52)
            let term2b = 2.0 * (d4410 * (cos_2li_p_2omi * C_G44 + sin_2li_p_2omi * S_G44) +
                                d4422 * (cos_2li * C_G44 + sin_2li * S_G44) +
                                d5421 * (cos_2li_p_omi * C_G54 + sin_2li_p_omi * S_G54) +
                                d5433 * (cos_2li_m_omi * C_G54 + sin_2li_m_omi * S_G54))

            derivs0 = term1a + term2a
            derivs1 = term1b + term2b
        }
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ example:  g211 =    3.616  -   13.247  * super.tle.e₀ +   16.290  * super.e₀²                    ┃
  ┃           g211 = cubicPoly(x: super.tle.e₀, p⁰: 3.616, p¹: -13.247, p²: +16.290, p³: 0.0)        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
private func cubicPoly(_ x: Double, p⁰: Double, p¹: Double, p²: Double, p³: Double) -> Double {
    return p⁰ + x * (p¹ + x * (p² + x * p³))
}
