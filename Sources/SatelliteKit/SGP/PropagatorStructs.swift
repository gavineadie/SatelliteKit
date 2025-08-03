/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
 ║ PropagatorStructs.swift                                                                   SatKit ║
 ║ Sendable-compliant struct implementations of propagators                                          ║
 ║──────────────────────────────────────────────────────────────────────────────────────────────────║
 ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable identifier_name
// swiftlint:disable shorthand_operator
// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
// swiftlint:disable file_length


public struct SDP4Propagator: Propagable {
    
    private let data: PropagatorData
    private var state: PropagatorState
    
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
    }
    
    public func getPVCoordinates(minsAfterEpoch: Double) throws -> PVCoordinates {
        let legacyPropagator = SDP4(data.tle)
        return try legacyPropagator.getPVCoordinates(minsAfterEpoch: minsAfterEpoch)
    }
    
    public func getPVCoordinates(_ date: Date) throws -> PVCoordinates {
        return try getPVCoordinates(minsAfterEpoch: date.timeIntervalSince(Date(ds1950: data.tle.t₀)) / 60.0)
    }
}

public struct DeepSDP4Propagator: Propagable {
    
    private let data: PropagatorData
    private var state: PropagatorState
    
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
    }
    
    public func getPVCoordinates(minsAfterEpoch: Double) throws -> PVCoordinates {
        let legacyPropagator = DeepSDP4(data.tle)
        return try legacyPropagator.getPVCoordinates(minsAfterEpoch: minsAfterEpoch)
    }
    
    public func getPVCoordinates(_ date: Date) throws -> PVCoordinates {
        return try getPVCoordinates(minsAfterEpoch: date.timeIntervalSince(Date(ds1950: data.tle.t₀)) / 60.0)
    }
}
