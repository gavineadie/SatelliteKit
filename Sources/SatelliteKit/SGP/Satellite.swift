/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Satellite.swift                                                                           SatKit ║
  ║ Created by Gavin Eadie on Sep07/15 ... Copyright 2015-22 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import Foundation

public struct Satellite {

    let propagator: Propagator

    public let tle: Elements                            // make TLE accessible
    public let commonName: String                       // "COSMOS .."
    public let noradIdent: String                       // "21332"
    public let t₀Days1950: Double                       // days since 1950

    public var e: Double { return propagator.e }        //### these vary slowly over time ..
    public var i: Double { return propagator.i }        //###
    public var ω: Double { return propagator.ω }        //###
    public var Ω: Double { return propagator.Ω }        //###

    public var extraInfo = [String: AnyObject]()

}

public extension Satellite {
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialize Satellite with TLE struct ..                                                         │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    init(withTLE tle: Elements) {
        propagator = selectPropagator(tle: tle)

        self.tle = tle

        self.commonName = propagator.tle.commonName
        self.noradIdent = String(propagator.tle.noradIndex)      // convert UInt to String
        self.t₀Days1950 = propagator.tle.t₀
    }

    init(elements: Elements) {
        propagator = selectPropagator(tle: elements)

        self.tle = elements

        self.commonName = propagator.tle.commonName
        self.noradIdent = String(propagator.tle.noradIndex)      // convert UInt to String
        self.t₀Days1950 = propagator.tle.t₀
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Initialize Satellite with the three lines of a three line element set                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    init(_ line0: String, _ line1: String, _ line2: String) {
        do {
            let elements = try Elements(line0, line1, line2)
            self.init(withTLE: elements)
        } catch {
            fatalError("Satellite.init failure ..")
        }
    }

}

public extension Satellite {

    func julianDay(_ minsAfterEpoch: Double) -> Double {
        (self.t₀Days1950 + JD.epoch1950) + minsAfterEpoch * TimeConstants.min2day
    }

    func minsAfterEpoch(_ julianDays: Double) -> Double {
        (julianDays - (self.t₀Days1950 + JD.epoch1950)) * TimeConstants.day2min
    }

    var daysAfterEpoch: Double {
        return (ep1950DaysNow() - t₀Days1950)
    }

    var hoursAfterEpoch: Double {
        return (ep1950DaysNow() - t₀Days1950) * 24.0
    }

    var minsAfterEpoch: Double {
        return (ep1950DaysNow() - t₀Days1950) * 1440.0
    }

}

public extension Satellite {

// MARK: - inertial position and velocity

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ return satellite's earth centered inertial position (Kilometers) at minutes after TLE epoch      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func position(minsAfterEpoch: Double) -> Vector {
        do {
            let pv = try propagator.getPVCoordinates(minsAfterEpoch: minsAfterEpoch)
            return Vector((pv.position.x)/1000.0,
                          (pv.position.y)/1000.0,
                          (pv.position.z)/1000.0)
        } catch SatKitError.SGP(let sgpError) {
            fatalError("Position for '\(self.commonName)' .. \(sgpError)")
        } catch {
            fatalError("Something else: \(error)")
        }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ return satellite's earth centered inertial velocity (Kms/second) at minutes after TLE epoch      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func velocity(minsAfterEpoch: Double) -> Vector {
        do {
            let pv = try propagator.getPVCoordinates(minsAfterEpoch: minsAfterEpoch)
            return Vector((pv.velocity.x)/1000.0,
                          (pv.velocity.y)/1000.0,
                          (pv.velocity.z)/1000.0)
        } catch SatKitError.SGP(let sgpError) {
            fatalError("Velocity for '\(self.commonName)' .. \(sgpError)")
        } catch {
            fatalError("Something else: \(error)")
        }
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ return satellite's earth centered inertial position (Kilometers) at Julian Date                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func position(julianDays: Double) -> Vector {
        position(minsAfterEpoch: minsAfterEpoch(julianDays))
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ return satellite's earth centered inertial velocity (Kms/second) at Julian Date                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func velocity(julianDays: Double) -> Vector {
        velocity(minsAfterEpoch: minsAfterEpoch(julianDays))
    }

}

public extension Satellite {

// MARK: - latitude, longitude and altitude

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  derive latitude, longitude and altitude at given time ..                                        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
    func geoPosition(minsAfterEpoch: Double) -> LatLonAlt {
        return geoPosition(julianDays: julianDay(minsAfterEpoch))
    }

    func geoPosition(julianDays: Double) -> LatLonAlt {
        return eci2geo(julianDays: julianDays, celestial: position(julianDays: julianDays))
    }

// MARK: - azimuth, elevation and range

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  return topological position (satellite's azimuth, elevation and range) at given time ..         ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
   func topPosition(minsAfterEpoch: Double, obsLatLonAlt: LatLonAlt) -> AziEleDst {
       topPosition(julianDays: minsAfterEpoch * TimeConstants.min2day +
                                               (self.t₀Days1950 + JD.epoch1950), observer: obsLatLonAlt)
   }

   func topPosition(julianDays: Double, observer: LatLonAlt) -> AziEleDst {

       let satCel = self.position(julianDays: julianDays)                  // ECI
       let obsCel = geo2eci(julianDays: julianDays, geodetic: observer)    // ECI

       let top = cel2top(julianDays: julianDays, satCel: satCel, obsCel: obsCel)

       let z = top.magnitude()

       return AziEleDst(azim: atan2pi(top.y, -top.x) * rad2deg,
                        elev: asin(top.z / z) * rad2deg, dist: z)
   }

}

public extension Satellite {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @available(*, deprecated, message: "PrettyPrint the elements from the Elements struct")
    func debugDescription() -> String {
        return tle.debugDescription()
    }

}
