/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SDP4.swift                                                                                SatKit ║
  ║ Created by Gavin Eadie on May26/17         Copyright © 2017-25 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable force_try
// swiftlint:disable identifier_name

class SDP4: Propagator {

    var ω_new = 0.0                                     // New arg of perigee argument.
    var n_new = 0.0                                     // New mean motion.
    var e_new = 0.0                                     // New eccentricity.
    var i_new = 0.0                                     // New inclination.
    var xll = 0.0                                       // Parameter for xl computation.

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialization proper to each propagator (SGP or SDP).                                          │
  │  .. exception OrekitException when UTC time steps can't be read                         [Orekit] │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func sxpInitialize() throws {

        try! luniSolarTermsComputation()

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Propagation proper to each propagator (SGP or SDP).                                             │
  │  .. `minsAfterEpoch` is the offset from initial epoch (minutes)                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func sxpPropagate(minsAfterEpoch: Double) throws {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update for secular gravity and atmospheric drag.                                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
             ω_new = super.tle.ω₀ + super.ω_dot * minsAfterEpoch
        let xnoddf = super.tle.Ω₀ + super.Ω_dot * minsAfterEpoch
        let minsAfterEpoch² = minsAfterEpoch * minsAfterEpoch
           super.Ω = xnoddf + super.xnodcf *  minsAfterEpoch²
             n_new = super.tle.n₀

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update for deep-space secular effects                                                            ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
               xll = super.tle.M₀ + super.M_dot * minsAfterEpoch

        deepSecularEffects(minutesFromEphoch: minsAfterEpoch)

        if n_new < 0 { throw SatKitError.SGP(sgpError: "2: mean motion less than zero") }

        let tempa = 1.0 - super.c₁ * minsAfterEpoch
        a = pow(EarthConstants.kₑ / n_new, ⅔) * tempa * tempa
        e_new -= super.tle.dragCoeff * super.c₄ * minsAfterEpoch

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update for deep-space periodic effects                                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        xll += super.tle.n₀ * super.t2cof * minsAfterEpoch²

        deepPeriodicEffects(minutesFromEphoch: minsAfterEpoch)

        xl = xll + ω_new + super.Ω

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Dundee change:  Reset cosio, sinio for new inclination                                           ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        super.e = e_new
        super.i = i_new
        super.ω = ω_new
        super.cosi₀ = cos(i_new)
        super.sini₀ = sin(i_new)             // end of calculus, go for PV computation
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Computes luni - solar terms from initial coordinates and epoch.                                 │
  │  .. exception OrekitException when UTC time steps can't be read                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func luniSolarTermsComputation() throws {

        preconditionFailure("'luniSolarTermsComputation' must be overridden")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Computes secular terms from current coordinates and epoch.                                      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func deepSecularEffects(minutesFromEphoch mins: Double) {

        preconditionFailure("'deepSecularEffects' must be overridden")

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Computes periodic terms from current coordinates and epoch.                                     │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func deepPeriodicEffects(minutesFromEphoch mins: Double) {

        preconditionFailure("'deepPeriodicEffects' must be overridden")

    }

}
