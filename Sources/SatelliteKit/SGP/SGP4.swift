/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SGP4.swift                                                                                SatKit ║
  ║ Created by Gavin Eadie on May24/17         Copyright © 2017-25 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable shorthand_operator

public struct SGP4Propagator: Propagable {
    
    private let data: PropagatorData
    private var state: PropagatorState
    
    // SGP4-specific properties
    private let ΔM₀³: Double
    private let d₂: Double
    private let d₃: Double
    private let d₄: Double
    private let t₃cof: Double
    private let t₄cof: Double
    private let t₅cof: Double
    private let omgcof: Double
    private let xmcof: Double
    private let c₅: Double
    
    public var tle: Elements { data.tle }
    public var e: Double { state.e }
    public var i: Double { state.i }
    public var ω: Double { state.ω }
    public var Ω: Double { state.Ω }
    
    public init(_ initialTLE: Elements) {
        self.data = createPropagatorData(initialTLE)
        self.state = PropagatorState(
            e: 0.0,
            i: 0.0,
            ω: 0.0,
            Ω: 0.0,
            a: 0.0,
            xl: 0.0
        )
        
        if data.perigee > 220 {
            let ΔM₀ = 1.0 + data.η * cos(data.tle.M₀)
            self.ΔM₀³ = ΔM₀ * ΔM₀ * ΔM₀

            let c₁² = data.c₁ * data.c₁
            self.d₂ = 4.0 * data.tle.a₀ * data.ξ * c₁²
            let temp = d₂ * data.ξ * data.c₁ / 3.0
            self.d₃ = (17.0 * data.tle.a₀ + data.s) * temp
            self.d₄ = 0.5 * temp * data.tle.a₀ * data.ξ * (221.0 * data.tle.a₀ + 31.0 * data.s) * data.c₁
            self.t₃cof = d₂ + 2.0 * c₁²
            self.t₄cof = 0.25 * (3.0 * d₃ + data.c₁ * (12.0 * d₂ + 10.0 * c₁²))
            self.t₅cof = 0.2  * (3.0 * d₄ + 12.0 * data.c₁ * d₃ + 6.0 * d₂ * d₂ + 15.0 * c₁² * (2.0 * d₂ + c₁²))

            if data.tle.e₀ > 1e-4 {
                let c₃ = data.coef * data.ξ * EarthConstants.J₃OVK₂ * data.tle.n₀ * data.sini₀ / data.tle.e₀
                self.xmcof = -⅔ * data.coef * data.tle.dragCoeff / data.eeta
                self.omgcof = data.tle.dragCoeff * c₃ * cos(data.tle.ω₀)
            } else {
                self.xmcof = 0.0
                self.omgcof = 0.0
            }
        } else {
            self.ΔM₀³ = 0.0
            self.d₂ = 0.0
            self.d₃ = 0.0
            self.d₄ = 0.0
            self.t₃cof = 0.0
            self.t₄cof = 0.0
            self.t₅cof = 0.0
            self.omgcof = 0.0
            self.xmcof = 0.0
        }

        self.c₅ = 2 * data.coef1 * data.tle.a₀ * data.β₀² *
                                        (1 + 2.75 * (data.η² + data.eeta) + data.eeta * data.η²)
    }

    public func getPVCoordinates(minsAfterEpoch: Double) throws -> PVCoordinates {
        var newState = state
        try sxpPropagate(minsAfterEpoch: minsAfterEpoch, data: data, state: &newState,
                        ΔM₀³: ΔM₀³, d₂: d₂, d₃: d₃, d₄: d₄, t₃cof: t₃cof, t₄cof: t₄cof, t₅cof: t₅cof,
                        omgcof: omgcof, xmcof: xmcof, c₅: c₅)
        return try computePVCoordinates(data: data, state: newState)
    }

    public func getPVCoordinates(_ date: Date) throws -> PVCoordinates {
        return try getPVCoordinates(minsAfterEpoch: date.timeIntervalSince(Date(ds1950: data.tle.t₀)) / 60.0)
    }

    private func sxpPropagate(minsAfterEpoch: Double, data: PropagatorData, state: inout PropagatorState,
                             ΔM₀³: Double, d₂: Double, d₃: Double, d₄: Double,
                             t₃cof: Double, t₄cof: Double, t₅cof: Double,
                             omgcof: Double, xmcof: Double, c₅: Double) throws {
        
        state.ω = data.tle.ω₀ + data.ω_dot * minsAfterEpoch
        let xnoddf = data.tle.Ω₀ + data.Ω_dot * minsAfterEpoch
        let anomdf = data.tle.M₀ + data.M_dot * minsAfterEpoch
        var xmp = anomdf
        let minsAfterEpoch² = minsAfterEpoch * minsAfterEpoch
        state.Ω = xnoddf + data.xnodcf * minsAfterEpoch²
        var tempa = 1.0 - data.c₁ * minsAfterEpoch
        var tempe = data.tle.dragCoeff * data.c₄ * minsAfterEpoch
        var templ = data.t2cof * minsAfterEpoch²

        if data.perigee > 220 {
            let Δomg = omgcof * minsAfterEpoch
            var Δm = 1.0 + data.η * cos(anomdf)
            Δm = xmcof * (Δm * Δm * Δm - ΔM₀³)
            let temp = Δomg + Δm
            xmp = anomdf + temp
            state.ω -= temp
            let minsAfterEpoch³ = minsAfterEpoch² * minsAfterEpoch
            let minsAfterEpoch⁴ = minsAfterEpoch³ * minsAfterEpoch
            tempa = tempa - d₂ * minsAfterEpoch² - d₃ * minsAfterEpoch³ - d₄ * minsAfterEpoch⁴
            tempe = tempe + data.tle.dragCoeff * c₅ * (sin(xmp) - sin(data.tle.M₀))
            templ = templ + t₃cof * minsAfterEpoch³ + minsAfterEpoch⁴ * (t₄cof + minsAfterEpoch * t₅cof)
        }

        state.a = data.tle.a₀ * tempa * tempa
        state.e = data.tle.e₀ - tempe

        if state.e >= 1.0 || state.e < -0.001 {
            throw SatKitError.SGP(sgpError: "1: eccentricity out of range 0...1")
        }

        if state.e < 1e-6 { state.e = 1e-6 }

        state.xl = xmp + state.ω + state.Ω + data.tle.n₀ * templ
        state.i = data.tle.i₀
    }
}

class SGP4: Propagator {

    private var ΔM₀³ = 0.0                  // (1 + eta * cos(M₀))³

    private var d₂ = 0.0
    private var d₃ = 0.0
    private var d₄ = 0.0
    private var t₃cof = 0.0
    private var t₄cof = 0.0
    private var t₅cof = 0.0
    private var omgcof = 0.0
    private var xmcof = 0.0
    private var c₅ = 0.0

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialization proper to each propagator (SGP or SDP).                                          │
  │  .. exception OrekitException when UTC time steps can't be read                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func sxpInitialize() throws {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ For perigee less than 220 kilometers, the equations are truncated to linear variation in √a and  ┆
  ┆ quadratic variation in mean anomaly. Also, the c₃ term, the delta omega term, and the delta m    ┆
  ┆ term are dropped.                                                                                ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if self.perigee > 220 {
            let ΔM₀ = 1.0 + super.η * cos(super.tle.M₀)
            ΔM₀³ = ΔM₀ * ΔM₀ * ΔM₀

            let c₁² = super.c₁ * super.c₁
            d₂ = 4.0 * tle.a₀ * super.ξ * c₁²
            let temp = d₂ * super.ξ * super.c₁ / 3.0
            d₃ = (17.0 * tle.a₀ + super.s) * temp
            d₄ = 0.5 * temp * tle.a₀ * super.ξ * (221.0 * tle.a₀ + 31.0 * super.s) * super.c₁
            t₃cof = d₂ + 2.0 * c₁²
            t₄cof = 0.25 * (3.0 * d₃ + super.c₁ * (12.0 * d₂ + 10.0 * c₁²))
            t₅cof = 0.2  * (3.0 * d₄ + 12.0 * super.c₁ * d₃ + 6.0 * d₂ * d₂ + 15.0 * c₁² * (2.0 * d₂ + c₁²))

            if tle.e₀ > 1e-4 {
//              omgcof = 0.0; xmcof = 0.0
//          } else {
                let c₃ = super.coef * super.ξ * EarthConstants.J₃OVK₂ * tle.n₀ * super.sini₀ / tle.e₀
                xmcof = -⅔ * super.coef * tle.dragCoeff / super.eeta
                omgcof = tle.dragCoeff * c₃ * cos(tle.ω₀)
            }
        }

        c₅ = 2 * super.coef1 * tle.a₀ * super.β₀² *
                                        (1 + 2.75 * (super.η² + super.eeta) + super.eeta * super.η²)

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Propagation proper to each propagator (SGP4 or SDP4).                                           │
  │                                      .. minsAfterEpochis the offset from initial epoch (minutes) │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    override func sxpPropagate(minsAfterEpoch: Double) throws {

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ Update for secular gravity and atmospheric drag.                                                 ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
           super.ω = super.tle.ω₀ + super.ω_dot * minsAfterEpoch
        let xnoddf = super.tle.Ω₀ + super.Ω_dot * minsAfterEpoch
        let anomdf = super.tle.M₀ + super.M_dot * minsAfterEpoch
        var xmp = anomdf
        let minsAfterEpoch² = minsAfterEpoch * minsAfterEpoch
        super.Ω = xnoddf + super.xnodcf * minsAfterEpoch²
        var tempa = 1.0 - super.c₁ * minsAfterEpoch
        var tempe = super.tle.dragCoeff * super.c₄ * minsAfterEpoch
        var templ = super.t2cof * minsAfterEpoch²

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ if above 220Kms, do some more work .. adjust xmp, tempa, tempe, templ ..                         ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if self.perigee > 220 {
            let Δomg = omgcof * minsAfterEpoch
            var Δm = 1.0 + super.η * cos(anomdf)
            Δm = xmcof * (Δm * Δm * Δm - ΔM₀³)
            let temp = Δomg + Δm
            xmp = anomdf + temp
            super.ω -= temp
            let minsAfterEpoch³ = minsAfterEpoch² * minsAfterEpoch
            let minsAfterEpoch⁴ = minsAfterEpoch³ * minsAfterEpoch
            tempa = tempa - d₂ * minsAfterEpoch² - d₃ * minsAfterEpoch³ - d₄ * minsAfterEpoch⁴
            tempe = tempe + tle.dragCoeff * c₅ * (sin(xmp) - sin(tle.M₀))
            templ = templ + t₃cof * minsAfterEpoch³ + minsAfterEpoch⁴ * (t₄cof + minsAfterEpoch * t₅cof)
        }

        super.a = tle.a₀ * tempa * tempa
        super.e = tle.e₀ - tempe

        if super.e >= 1.0 || super.e < -0.001 {
            throw SatKitError.SGP(sgpError: "1: eccentricity out of range 0...1")
        }

/*╭╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╮
  ┆ A highly arbitrary lower limit on e,  of 1e-6:                                                   ┆
  ╰╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╯*/
        if super.e < 1e-6 { super.e = 1e-6 }

        super.xl = xmp + super.ω + super.Ω + tle.n₀ * templ

        super.i = tle.i₀
    }

}
