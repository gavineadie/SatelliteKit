/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Satellite.swift                                                                           SatKit ║
  ║ Created by Gavin Eadie on Sep07/15 ... Copyright 2015-19 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import Foundation

public struct Satellite {

    let propagator: TLEPropagator

    public let commonName: String
    public let noradIdent: String
    public let t₀Days1950: Double                       // TLE t=0 (days since 1950)

    public var e: Double { return propagator.e }        //### these vary slowly over time ..
    public var i: Double { return propagator.i }        //###
    public var ω: Double { return propagator.ω }        //###
    public var Ω: Double { return propagator.Ω }        //###

    public var extraInfo = [String: AnyObject]()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialize Satellite with the three lines of a three line element set                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(_ line0: String, _ line1: String, _ line2: String) {

        do {
            let tleSat = try TLE(line0, line1, line2)

            self.init(withTLE: tleSat)

        } catch {

            fatalError("Satellite.init failure ..")

        }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialize Satellite with TLE struct ..                                                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(withTLE tle: TLE) {

        propagator = selectPropagator(tle: tle)

        noradIdent = String(propagator.tle.noradIndex)      // convert Int to String
        commonName = propagator.tle.commonName
        t₀Days1950 = propagator.tle.t₀

    }

    public func julianDay(_ minsAfterEpoch: Double) -> Double {
        return (self.t₀Days1950 + JD.epoch1950) + minsAfterEpoch * TimeConstants.min2day
    }

    public func minsAfterEpoch(_ julianDays: Double) -> Double {
        return (julianDays - (self.t₀Days1950 + JD.epoch1950)) * TimeConstants.day2min
    }

// MARK: - inertial position and velocity

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ return satellite's earth centered inertial position (Kilometers) at minutes after TLE epoch      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    public func position(minsAfterEpoch: Double) -> Vector {
        do {
            let pv = try propagator.getPVCoordinates(minsAfterEpoch: minsAfterEpoch)
            return Vector((pv.position.x)/1000.0, (pv.position.y)/1000.0, (pv.position.z)/1000.0)
        } catch let error as NSError {
            fatalError("Satellite Position Error \(self.commonName) .. \(error.domain) (\(error.code))")
        }
    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ return satellite's earth centered inertial velocity (Kms/second) at minutes after TLE epoch      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    public func velocity(minsAfterEpoch: Double) -> Vector {
        do {
            let pv = try propagator.getPVCoordinates(minsAfterEpoch: minsAfterEpoch)
            return Vector((pv.velocity.x)/1000.0, (pv.velocity.y)/1000.0, (pv.velocity.z)/1000.0)
        } catch let error as NSError {
            fatalError("Satellite Velocity Error \(error.domain) (\(error.code))")
        }
    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ return satellite's earth centered inertial position (Kilometers) at Julian Date                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    public func position(julianDays: Double) -> Vector {
        return position(minsAfterEpoch: minsAfterEpoch(julianDays))
    }

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ return satellite's earth centered inertial velocity (Kms/second) at Julian Date                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    public func velocity(julianDays: Double) -> Vector {
        return velocity(minsAfterEpoch: minsAfterEpoch(julianDays))
    }

}
