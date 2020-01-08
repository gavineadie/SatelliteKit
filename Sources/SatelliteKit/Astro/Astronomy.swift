/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Astronomy.swift                                                                           SatKit ║
  ║ Created by Gavin Eadie on Jul06/15.    Copyright 2015-20 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable identifier_name

import Foundation

public struct EarthConstants {

     public static let Rₑ = 6378.135                        // Earth radius (Km)

     public static let rotationₑ = 1.00273790934            // Earth sidereal rotations per UT day

    private static let flatteningₑ = (1.0 / 298.26)
            static let e2 = (flatteningₑ * (2.0 - flatteningₑ))

}

public struct LatLonAlt {
    public var lat: Double                                  // latitude (degrees)
    public var lon: Double                                  // longitude (degrees)
    public var alt: Double                                  // altitude

    public init(lat: Double, lon: Double, alt: Double) {
        self.lat = lat
        self.lon = lon
        self.alt = alt
    }
}

public struct AziEleDst {
    public var azim: Double                                 // azimuth (degrees)
    public var elev: Double                                 // elevation (degrees)
    public var dist: Double                                 // distance/range

    public init(azim: Double, elev: Double, dist: Double) {
        self.azim = azim
        self.elev = elev
        self.dist = dist
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ References: The 1992 Astronomical Almanac, page B6.                                              ┃
  ┃             http://celestrak.com/columns/v02n02/ and http://aa.usno.navy.mil/faq/docs/GAST.php   ┃
  ┃                                                                                                  ┃
  ┃   check at: http://www.jgiesen.de/SiderealTimeClock/index.html                                   ┃
  ┃                                                                                                  ┃
  ┃ returns sidereal time in degrees ... (also "GHA Aries") ... the IAU 1982 GMST-UT1 model          ┃
  ┃                                                                                                  ┃
  ┃ Sidereal time is a system of timekeeping based on the rotation of the Earth with respect to the  ┃
  ┃ fixed stars in the sky. Specifically, it is the measure of the hour angle of the vernal equinox. ┃
  ┃ When the measurements are made with respect to the meridian at Greenwich, the times are referred ┃
  ┃ to as Greenwich mean sidereal time (GMST).                                                       ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func zeroMeanSiderealTime(julianDate: Double) -> Double {
    let     fractionalDay = fmod(julianDate + 0.5, 1.0)     // fractional part of JD + half a day
    let     adjustedJD = julianDate - fractionalDay
    let     timespanCenturies = (adjustedJD - JD.epoch2000) / TimeConstants.daysPerCentury
    var     greenwichSiderealSeconds = 24110.54841 +        // Greenwich Mean Sidereal Time (secs)
                    timespanCenturies * (8640184.812866 +
                        timespanCenturies * (0.093104 -
                            timespanCenturies * 0.0000062))
    greenwichSiderealSeconds =
        fmod(greenwichSiderealSeconds +
            fractionalDay * EarthConstants.rotationₑ * TimeConstants.day2sec, TimeConstants.day2sec)

    return fmod((360.0 * greenwichSiderealSeconds * TimeConstants.sec2day) + 360.0, 360.0)
}

public func siteMeanSiderealTime(julianDate: Double, _ siteLongitude: Double) -> Double {
    return fmod(zeroMeanSiderealTime(julianDate: julianDate) + siteLongitude + 360.0, 360.0)
}

public func zeroMeanSiderealTime(date: Date) -> Double {
    return zeroMeanSiderealTime(julianDate: date.julianDate)
}

public func siteMeanSiderealTime(date: Date, _ siteLongitude: Double) -> Double {
    return siteMeanSiderealTime(julianDate: date.julianDate, siteLongitude)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ http://aa.usno.navy.mil/faq/docs/SunApprox.php                                                   ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func solarCel(julianDays: Double) -> Vector {
    let     daysSinceJD2000 = julianDays - JD.epoch2000

    let     eclipticInclin =  (23.439 - 0.00000036 * daysSinceJD2000) * deg2rad
    let     solarMeanAnom = (357.529 + 0.98560028 * daysSinceJD2000) * deg2rad
    let     aberration = 1.915 * sin(1.0 * solarMeanAnom) + 0.020 * sin(2.0 * solarMeanAnom)
    let     solarEclpLong = ((280.459 + 0.98564736 * daysSinceJD2000) + aberration) * deg2rad

    return Vector(cos(solarEclpLong),
                  sin(solarEclpLong) * cos(eclipticInclin),
                  sin(solarEclpLong) * sin(eclipticInclin))
}

//  Declination (delta) and Right Ascension (alpha) are returned as decimal degrees.

public func solarGeo(julianDays: Double) -> (Double, Double) {
    let     solarVector: Vector = solarCel(julianDays: julianDays)

    return (asin(solarVector.z) * rad2deg,
            atan2pi(solarVector.y, solarVector.x) * rad2deg)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Low precision formulae for the moon, from:                                                       ┃
  ┃                            AN ALTERNATIVE LUNAR EPHEMERIS MODEL FOR ON-BOARD FLIGHT SOFTWARE USE ┃
  ┃                                                                by: David G. Simpson (NASA, GSFC) ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

public func lunarCel(julianDays: Double) -> Vector {
    let     centsSinceJD2000 = ( julianDays - JD.epoch2000 ) / 36525.0

    let moonX1 = 383.0e3 * sin( 8399.685 * centsSinceJD2000 + 5.381) +
                  31.5e3 * sin(   70.990 * centsSinceJD2000 + 6.169) +
                  10.6e3 * sin(16728.377 * centsSinceJD2000 + 1.453) +
                   6.2e3 * sin( 1185.622 * centsSinceJD2000 + 0.481) +
                   3.2e3 * sin( 7143.070 * centsSinceJD2000 + 5.017) +
                   2.3e3 * sin(15613.745 * centsSinceJD2000 + 0.857) +
                   0.8e3 * sin( 8467.263 * centsSinceJD2000 + 1.010)

    let moonY1 = 351.0e3 * sin( 8399.687 * centsSinceJD2000 + 3.811) +
                  28.9e3 * sin(   70.997 * centsSinceJD2000 + 4.596) +
                  13.7e3 * sin( 8433.466 * centsSinceJD2000 + 4.766) +
                   9.7e3 * sin(16728.380 * centsSinceJD2000 + 6.165) +
                   5.7e3 * sin( 1185.667 * centsSinceJD2000 + 5.164) +
                   2.9e3 * sin( 7143.058 * centsSinceJD2000 + 0.300) +
                   2.1e3 * sin(15613.755 * centsSinceJD2000 + 5.565)

    let moonZ1 = 153.2e3 * sin( 8399.672 * centsSinceJD2000 + 3.807) +
                  31.5e3 * sin( 8433.464 * centsSinceJD2000 + 1.629) +
                  12.5e3 * sin(   70.996 * centsSinceJD2000 + 4.595) +
                   4.2e3 * sin(16728.364 * centsSinceJD2000 + 6.162) +
                   2.5e3 * sin( 1185.645 * centsSinceJD2000 + 5.167) +
                   3.0e3 * sin(  104.881 * centsSinceJD2000 + 2.555) +
                   1.8e3 * sin( 8399.116 * centsSinceJD2000 + 6.248)

    return Vector(moonX1, moonY1, moonZ1)
}

//  (Declination, Right_Ascension) are returned as decimal degrees.

public func lunarGeo (julianDays: Double) -> (Double, Double) {
    let     lunarVector: Vector = lunarCel(julianDays: julianDays)

    return (asin(lunarVector.z / sqrt(lunarVector.x * lunarVector.x +
                                      lunarVector.y * lunarVector.y +
                                      lunarVector.z * lunarVector.z)) * rad2deg,
            atan2pi(lunarVector.y, lunarVector.x) * rad2deg)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Date, (lat°, lon°), (ra°, dec°) -> (alt°, azi°)                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func azel(time: Date,
                 site: (Double, Double),
                 cele: (Double, Double)) -> (alt: Double, azi: Double) {

    let hourAngle = (siteMeanSiderealTime(date: time, site.1) - cele.0) * deg2rad

    let lat = site.0 * deg2rad
    let dec = cele.1 * deg2rad

    let elev = asin(sin(lat) * sin(dec) + cos(lat) * cos(dec) * cos(hourAngle))
    let azim = atan2pi(sin(hourAngle), cos(hourAngle) * sin(lat) - tan(dec) * cos(lat))

    return (fmod(elev * rad2deg, 360.0),
            fmod(azim * rad2deg + 540.0, 360.0))
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ Reference: The 1992 Astronomical Almanac, page K12.                                              ┃
  ┃                                                                                                  ┃
  ┃ Procedure eci2geo() will calculate the geodetic (lat, lon, alt) position of an object given the  ┃
  ┃ time and its ECI position.  It is intended to be used to determine the satellite ground track.   ┃
  ┃ The calculations assume the earth to be oblate. If the time is negative, treat as zero.          ┃
  ┃                                                                                                  ┃
  ┃ geodetic : latitude (degrees)                                                                    ┃
  ┃          : longitude (degrees)                                                                   ┃
  ┃          : altitude (Kms above geoid)                                                            ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func eci2geo(julianDays: Double, celestial: Vector) -> LatLonAlt {

    let     positionXY = sqrt(celestial.x*celestial.x + celestial.y*celestial.y)
    var     newLatRads = atan2(celestial.z, positionXY)

    var     oldLatRads: Double
    var     correction: Double

    repeat {
        let sinLatitude = sin(newLatRads)
        correction = TLEConstants.Rₑ / sqrt(1.0 - (EarthConstants.e2 * sinLatitude*sinLatitude))
        oldLatRads = newLatRads
        newLatRads = atan2(celestial.z + correction * EarthConstants.e2 * sinLatitude, positionXY)
    } while (fabs(newLatRads - oldLatRads) > 0.0001)

    return LatLonAlt(lat: newLatRads * rad2deg,
                     lon: fmod(360.0 + atan2pi(celestial.y, celestial.x) *
                        rad2deg - ((julianDays < 0.0) ? 0.0 :
                            zeroMeanSiderealTime(julianDate: julianDays)), 360.0),
                     alt: positionXY / cos(newLatRads) - correction)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ geo2eci .. JD, (lat°, lon°, alt) -> (x, y, z,)                                            OBLATE ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func geo2eci(julianDays: Double, geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = siteMeanSiderealTime(julianDate: julianDays, geodetic.lon) * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    let     c = TLEConstants.Rₑ / sqrt(1.0 + EarthConstants.e2 * sinLatitude * sinLatitude)
    let     s = (1 - EarthConstants.e2) * c
    let     achcp = (c + geodetic.alt) * cosLatitude

    return Vector(achcp * cosSidereal,
                  achcp * sinSidereal,
                  (geodetic.alt+s) * sinLatitude)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ geo2eci .. (lat°, lon°, alt) -> (x, y, z,)                         OBLATE - NO SIDEREAL ROTATION ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func geo2eci(geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = geodetic.lon * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    let flatteningₑ = (1.0 / 298.26)
    let e2 = (flatteningₑ * (2.0 - flatteningₑ))

    let     c = TLEConstants.Rₑ / sqrt(1.0 + e2 * sinLatitude * sinLatitude)
    let     s = (1 - e2) * c
    let     achcp = (c + geodetic.alt) * cosLatitude

    return Vector(achcp * cosSidereal,
                  achcp * sinSidereal,
                  (geodetic.alt+s) * sinLatitude)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ geo2xyz .. JD, (lat°, lon°, alt) -> (x, y, z,)                                         SPHERICAL ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func geo2xyz(julianDays: Double, geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = siteMeanSiderealTime(julianDate: julianDays, geodetic.lon) * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    return Vector((geodetic.alt+TLEConstants.Rₑ) * cosLatitude * cosSidereal,
                  (geodetic.alt+TLEConstants.Rₑ) * cosLatitude * sinSidereal,
                  (geodetic.alt+TLEConstants.Rₑ) * sinLatitude)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ geo2xyz .. (lat°, lon°, alt) -> (x, y, z,)                      SPHERICAL - NO SIDEREAL ROTATION ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func geo2xyz(geodetic: LatLonAlt) -> Vector {
    let     latitudeRads = geodetic.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = geodetic.lon * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    return Vector((geodetic.alt+TLEConstants.Rₑ) * cosLatitude * cosSidereal,
                  (geodetic.alt+TLEConstants.Rₑ) * cosLatitude * sinSidereal,
                  (geodetic.alt+TLEConstants.Rₑ) * sinLatitude)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ eci2top .. JD, sat(x, y, z), obs(lat°, lon°, alt) -> (x, y, z)                                   ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func eci2top(julianDays: Double, satVector: Vector, geoVector: LatLonAlt) -> Vector {
    let     latitudeRads = geoVector.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let obsVector = geo2eci(julianDays: julianDays, geodetic: geoVector)
    let obs2sat = satVector - obsVector

    let     siderealRads = siteMeanSiderealTime(julianDate: julianDays, obsVector.y) * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    let topS = +sinLatitude * cosSidereal * obs2sat.x +
                sinLatitude * sinSidereal * obs2sat.y -
                cosLatitude * obs2sat.z

    let topE = -sinSidereal * obs2sat.x +
                cosSidereal * obs2sat.y

    let topZ = +cosLatitude * cosSidereal * obs2sat.x +
                cosLatitude * sinSidereal * obs2sat.y +
                sinLatitude * obs2sat.z

    return Vector(topS, topE, topZ)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func cel2top(julianDays: Double, satVector: Vector, obsVector: Vector) -> Vector {
    let obsLLA = eci2geo(julianDays: julianDays, celestial: obsVector)

    let     latitudeRads = obsLLA.lat * deg2rad
    let     sinLatitude = sin(latitudeRads)
    let     cosLatitude = cos(latitudeRads)

    let     siderealRads = siteMeanSiderealTime(julianDate: julianDays, obsLLA.lon) * deg2rad
    let     sinSidereal = sin(siderealRads)
    let     cosSidereal = cos(siderealRads)

    let obs2sat = Vector(satVector.x - obsVector.x,
                         satVector.y - obsVector.y,
                         satVector.z - obsVector.z)

    return Vector(
        obs2sat.x*(+sinLatitude * cosSidereal) + obs2sat.y*(+sinLatitude * sinSidereal) + obs2sat.z*(-cosLatitude),
        obs2sat.x*(-sinSidereal) + obs2sat.y*(+cosSidereal) + obs2sat.z*0.0,
        obs2sat.x*(+cosLatitude * cosSidereal) + obs2sat.y*(+cosLatitude * sinSidereal) + obs2sat.z*(+sinLatitude)
    )
}
