/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ Astronomy.swift                                                                           SatKit ║
  ║ Created by Gavin Eadie on Jul06/15.    Copyright 2015-24 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

//swiftlint:disable identifier_name

import Foundation

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ sidereal time                                                                                    ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
/// Sidereal time is a system of timekeeping based on the rotation of the Earth with respect
/// to the fixed stars in the sky.  Specifically, it is the measure of the hour angle of the
/// vernal equinox.  When the measurements are made with respect to the meridian at Greenwich,
/// the times are referred to as Greenwich mean sidereal time (GMST).
///
/// References: The 1992 Astronomical Almanac,
///  http://celestrak.com/columns/v02n02/ and http://aa.usno.navy.mil/faq/docs/GAST.php
///  http://www.jgiesen.de/SiderealTimeClock/index.html
///
/// - Parameter julianDate: Julian Date
/// - Returns: sidereal time in degrees ... (also "GHA Aries") ... the IAU 1982 GMST-UT1 model
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

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ coordinate frames                                                                                ║
  ║                                                                                                  ║
  ║ The International Celestial Reference System (ICRS) is a higher-accuracy replacement for the old ║
  ║ J2000 reference system:                                                                          ║
  ║                                                                                                  ║
  ║     x-axis — Aims at the ascending node of the ecliptic on the mean celestial equator.           ║
  ║              Ancient astronomers called this “the first point of Ares”.                          ║
  ║     y-axis — Aims at the point 90° east of the Vernal Equinox along the celestial equator.       ║
  ║     z-axis — Aims at the North Celestial Pole.                                                   ║
  ║                                                                                                  ║
  ║                                 The spherical Right Ascension and Declination are based on this. ║
  ║                                                                                                  ║
  ║ ECI (Earth Centered Inertial): coordinates fixed in the Celestial Reference frame.               ║
  ║ CEL:                                                                                             ║
  ║                                                                                                  ║
  ║ GEO: (bad name) Right Ascension and Declination angles                                           ║
  ║                                                                                                  ║
  ║ TOP: Earth surface latitude and longitude                                                        ║
  ║                                                                                                  ║
  ║ xxx: azimuth, elevation and range from Observer's latitude and longitude                         ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ solar                                                                                            ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
/// The Sun's position in ECI (Earth Centered Inertial - ICRS) frame.
///
/// - Parameter julianDays: julianDays
/// - Returns: Solar ECI unit Vector (mag = 1)
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

public func solarCel(ds1950: Double) -> Vector { solarCel(julianDays: ds1950 + JD.epoch1950) }

/// Declination (delta) and Right Ascension (alpha) are returned as decimal degrees.
/// - Parameter julianDays: Julian days
/// - Returns: Solar Declination and Right Ascension.
public func solarGeo(julianDays: Double) -> (delta: Double, alpha: Double) {
    let     solarVector: Vector = solarCel(julianDays: julianDays)

    return (asin(solarVector.z) * rad2deg,
            atan2pi(solarVector.y, solarVector.x) * rad2deg)
}

public func solarGeo(ds1950: Double) -> (delta: Double, alpha: Double) {
    solarGeo(julianDays: ds1950 + JD.epoch1950)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ lunar                                                                                            ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
/// Low precision formulae for the Moon's ECI (Earth Centered Inertial - ICRS) frame, from:
/// AN ALTERNATIVE LUNAR EPHEMERIS MODEL FOR ON-BOARD FLIGHT SOFTWARE USE by: David G. Simpson (NASA, GSFC)
/// - Parameter julianDays: Julian Days
/// - Returns: Lunar ECI Vector
public func lunarCel(julianDays: Double) -> Vector {
    let     centsSinceJD2000 = ( julianDays - JD.epoch2000 ) / TimeConstants.daysPerCentury

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

public func lunarCel(ds1950: Double) -> Vector {
    lunarCel(julianDays: ds1950 + JD.epoch1950)
}

/// lunarGeo
/// - Parameter julianDays: Julian Days
/// - Returns: (Declination, Right Ascension) are returned as decimal degrees.
public func lunarGeo (julianDays: Double) -> (delta: Double, alpha: Double) {
    let     lunarVector: Vector = lunarCel(julianDays: julianDays)

    return (asin(lunarVector.z / (lunarVector.x * lunarVector.x +
                                  lunarVector.y * lunarVector.y +
                                  lunarVector.z * lunarVector.z).squareRoot()) * rad2deg,
            atan2pi(lunarVector.y, lunarVector.x) * rad2deg)
}

public func lunarGeo(ds1950: Double) -> (delta: Double, alpha: Double) {
    lunarGeo(julianDays: ds1950 + JD.epoch1950)
}

/// calculates `el-az`  from date, observer location (lat/log), and object coordinates (RA/Dec)
/// - Parameters:
///   - time: date
///   - site: (lat°, lon°)
///   - cele: (ra°, dec°)
/// - Returns: (alt°, azi°)
public func azel(time: Date,
                 site: (Double, Double),
                 cele: (Double, Double)) -> (alt: Double, azi: Double) {

    let hourAngle = (siteMeanSiderealTime(date: time, site.1) - cele.0) * deg2rad

    let lat = site.0 * deg2rad
    let dec = cele.1 * deg2rad

    let elev = asin(sin(lat) * sin(dec) + cos(lat) * cos(dec) * cos(hourAngle))
    let azim = atan2pi(sin(hourAngle), sin(lat) * cos(hourAngle) - cos(lat) * tan(dec))

    return (fmod(elev * rad2deg,         360.0),
            fmod(azim * rad2deg + 540.0, 360.0))
}
