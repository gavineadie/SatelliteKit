/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Geography.swift                                                                           SatKit ║
  ║ Created by Gavin Eadie on Jun11/24.       Copyright 2024 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

//swiftlint:disable identifier_name

import Foundation

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public struct LatLonAlt: Equatable, Hashable, Codable, Sendable {
    public var lat: Double                                  // latitude (degrees)
    public var lon: Double                                  // longitude (degrees)
    public var alt: Double                                  // altitude (Kms above geoid)

    public init(_ lat: Double, _ lon: Double, _ alt: Double) {
        self.lat = lat
        self.lon = lon
        self.alt = alt
    }

}

/// LatLon: latitude and longitude only
public struct LatLon: Equatable, Hashable, Codable, Sendable {
    public var lat: Double
    public var lon: Double

    public init(_ lat: Double, _ lon: Double) {
        self.lat = lat
        self.lon = lon
    }

    public init(_ lla: LatLonAlt) {
        self.lat = lla.lat
        self.lon = lla.lon
    }
}

/// eci to geo [OBLATE]
///
/// Procedure eci2geo() will calculate the geodetic (lat, lon, alt) position of an object given the time and its ECI position.
/// It is intended to be used to determine the satellite ground track. The calculations assume the earth to be oblate.
/// If the time is negative, treat as zero.
///
/// Reference:
/// The 1992 Astronomical Almanac, page K12.
///
/// - Parameters:
///   - julianDays: JD of desired lat/lon
///   - celestial: ECI of object of interest
/// - Returns: geodetic (latitude [degrees], longitude [degrees], altitude [Kms above geoid])
public func eci2geo(julianDays: Double, celestial: Vector) -> LatLonAlt {

    let     positionXY = (celestial.x*celestial.x + celestial.y*celestial.y).squareRoot()
    var     newLatRads = atan2(celestial.z, positionXY)

    var     oldLatRads: Double
    var     correction: Double

    repeat {
        let sinLatitude = sin(newLatRads)
        correction = EarthConstants.Rₑ /
                            (1.0 - EarthConstants.e2 * sinLatitude*sinLatitude).squareRoot()
        oldLatRads = newLatRads
        newLatRads = atan2(celestial.z + correction * EarthConstants.e2 * sinLatitude, positionXY)
    } while (fabs(newLatRads - oldLatRads) > 0.0001)

    return LatLonAlt(newLatRads * rad2deg,
                     fmod(360.0 + atan2pi(celestial.y, celestial.x) *
                          rad2deg - ((julianDays < 0.0) ? 0.0 :
                                        zeroMeanSiderealTime(julianDate: julianDays)), 360.0),
                     positionXY / cos(newLatRads) - correction)
}

/// geo2eci [OBLATE]
/// - Parameters:
///   - julianDays: JD
///   - geodetic: (lat°, lon°, alt)
/// - Returns: (x, y, z,)
public func geo2eci(julianDays: Double, geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = siteMeanSiderealTime(julianDate: julianDays, geodetic.lon) * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    let     correction = EarthConstants.Rₑ /
                            (1.0 + EarthConstants.e2 * sinLatitude*sinLatitude).squareRoot()
    let     s = (1 - EarthConstants.e2) * correction
    let     achcp = (correction + geodetic.alt) * cosLatitude

    return Vector(achcp * cosSidereal,
                  achcp * sinSidereal,
                  (geodetic.alt+s) * sinLatitude)
}

/// geo2eci  [OBLATE - NO SIDEREAL ROTATION]
/// - Parameter geodetic: (lat°, lon°, alt)
/// - Returns: (x, y, z,)
public func geo2eci(geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = geodetic.lon * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    let     correction = EarthConstants.Rₑ /
                            (1.0 + EarthConstants.e2 * sinLatitude*sinLatitude).squareRoot()
    let     s = (1 - EarthConstants.e2) * correction
    let     achcp = (correction + geodetic.alt) * cosLatitude

    return Vector(achcp * cosSidereal,
                  achcp * sinSidereal,
                  (geodetic.alt+s) * sinLatitude)
}

/// geo2xyz [SPHERICAL]
/// - Parameters:
///   - julianDays: JD
///   - geodetic: (lat°, lon°, alt)
/// - Returns: (x, y, z,)
public func geo2xyz(julianDays: Double, geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = siteMeanSiderealTime(julianDate: julianDays, geodetic.lon) * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    return Vector((geodetic.alt+EarthConstants.Rₑ) * cosLatitude * cosSidereal,
                  (geodetic.alt+EarthConstants.Rₑ) * cosLatitude * sinSidereal,
                  (geodetic.alt+EarthConstants.Rₑ) * sinLatitude)
}

/// geo2xyz [SPHERICAL - NO SIDEREAL ROTATION]
/// - Parameters
///   - geodetic: (lat°, lon°, alt)
/// - Returns: (x, y, z,)
public func geo2xyz(geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = geodetic.lon * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    return Vector((geodetic.alt+EarthConstants.Rₑ) * cosLatitude * cosSidereal,
                  (geodetic.alt+EarthConstants.Rₑ) * cosLatitude * sinSidereal,
                  (geodetic.alt+EarthConstants.Rₑ) * sinLatitude)
}

/// eci2top [obs→sat in observer topo frame]
/// - Parameters:
///   - julianDays: JD
///   - satCel: sat(x, y, z)
///   - obsLLA: obs(lat°, lon°, alt)
/// - Returns: (x, y, z)
public func eci2top(julianDays: Double, satCel: Vector, obsLLA: LatLonAlt) -> Vector {
   topoVector(julianDays: julianDays, satCel: satCel, obsLLA: obsLLA)
}

/// cel2top [vector obs→sat in observer topo frame]
/// - Parameters:
///   - julianDays: JD
///   - satCel: sat(x, y, z)
///   - obsCel: obs(x, y, z)
/// - Returns: (x, y, z)
public func cel2top(julianDays: Double, satCel: Vector, obsCel: Vector) -> Vector {
    topoVector(julianDays: julianDays, satCel: satCel,
                                       obsLLA: eci2geo(julianDays: julianDays, celestial: obsCel))
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public struct AziEleDst: Equatable, Hashable, Codable, Sendable {
    public var azim: Double                                 // azimuth (degrees)
    public var elev: Double                                 // elevation (degrees)
    public var dist: Double                                 // distance/range

    public init(_ azim: Double, _ elev: Double, _ dist: Double) {
        self.azim = azim
        self.elev = elev
        self.dist = dist
    }

}

/// AziEle: azimuth and elevation only
public struct AziEle: Equatable, Hashable, Codable, Sendable {
    public var azim: Double
    public var elev: Double

    public init(_ azim: Double, _ elev: Double) {
        self.azim = azim
        self.elev = elev
    }

    public init(_ aed: AziEleDst) {
        self.azim = aed.azim
        self.elev = aed.elev
    }
}

/// eci2aed
/// - Parameters:
///   - julianDays: JD
///   - satCel: sat(x, y, z)
///   - obsLLA: obs(lat°, lon°, alt)
/// - Returns: (azi°, ele°, dst)
public func topPosition(julianDays: Double, satCel: Vector, obsLLA: LatLonAlt) -> AziEleDst {

    let obsCel = geo2eci(julianDays: julianDays, geodetic: obsLLA)    // ECI

    let top = cel2top(julianDays: julianDays, satCel: satCel, obsCel: obsCel)

    let d = magnitude(obsCel - satCel)

    return AziEleDst(atan2pi(top.y, -top.x) * rad2deg,
                     asin(top.z / d) * rad2deg,
                     d)
}

/// utility function used in both `eci2top` and `cel2top` [obs→sat in obs topo frame]
/// - Parameters:
///   - julianDays: Julian Days
///   - satCel: ECI of target object
///   - obsLLA: observer lat/lon/alt
/// - Returns: (x, y, z)
private func topoVector(julianDays: Double, satCel: Vector, obsLLA: LatLonAlt) -> Vector {
    let latitudeRads = obsLLA.lat * deg2rad
    let sinLatitude = sin(latitudeRads)
    let cosLatitude = cos(latitudeRads)

    let siderealRads = siteMeanSiderealTime(julianDate: julianDays, obsLLA.lon) * deg2rad
    let sinSidereal = sin(siderealRads)
    let cosSidereal = cos(siderealRads)

    let obsCel = geo2eci(julianDays: julianDays, geodetic: obsLLA)    // ECI
    let obs2sat = satCel - obsCel

    return Vector(obs2sat.x*(+sinLatitude * cosSidereal) +
                  obs2sat.y*(+sinLatitude * sinSidereal) +
                  obs2sat.z*(-cosLatitude),

                  obs2sat.x*(-sinSidereal) +
                  obs2sat.y*(+cosSidereal) +
                  obs2sat.z*0.0,

                  obs2sat.x*(+cosLatitude * cosSidereal) +
                  obs2sat.y*(+cosLatitude * sinSidereal) +
                  obs2sat.z*(+sinLatitude)
    )
}
