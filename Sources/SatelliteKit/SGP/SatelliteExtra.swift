/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SatelliteExtra.swift                                                                    DemosKit ║
  ║ Created by Gavin Eadie on Feb17/19 ... Copyright 2017-20 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#else
    import Cocoa
#endif

import SatelliteKit

// MARK: -

public func ep1950DaysNow() -> Double {
    return julianDaysNow() - JD.epoch1950
}

public func julianDaysNow() -> Double {
    return JD.appleZero + Date().timeIntervalSinceReferenceDate * TimeConstants.sec2day
}

// MARK: -

public extension Satellite {

    var daysAfterEpoch: Double {
        return (ep1950DaysNow() - t₀Days1950)
    }

    var hoursAfterEpoch: Double {
        return (ep1950DaysNow() - t₀Days1950) * 24.0
    }

    var minsAfterEpoch: Double {
        return (ep1950DaysNow() - t₀Days1950) * 1440.0
    }

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
