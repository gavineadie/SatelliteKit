/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TimeUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on Jan07/17 ... Copyright 2017-19 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable type_name
// swiftlint:disable identifier_name
// swiftlint:disable large_tuple

import Foundation

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ time scale:                                                                                      ┃
  ┃  ---|--------------------|--------------------|--------------------|---------------------|---    ┃
  ┃    - ∞                 J1900                1950                 J2000                  ...      ┃
  ┃   JD: 0           2415020.0                                 2451545.0                            ┃
  ┃                                                                                                  ┃
  ┃                                      ---------|-----------------------|---                       ┃
  ┃                                               |                     2001                         ┃
  ┃                                          NORAD: 0 -- JD: 2433281.5                               ┃
  ┃                                                                  Apple: 0 -- JD: 2451910.5       ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public struct JD {

           static let modJDZero = 2400000.5             // Modified JD (MJD) zero
           static let epoch1900 = 2415020.0             // 1900 Jan 0.5
    public static let epoch1950 = 2433281.5             // 1949-Dec-31 00h00m00.0s
           static let epochUnix = 2440587.5             // 1970-Jan-01 00h00m00.0s
    public static let epoch2000 = 2451545.0             // 2000 Jan 1.5
    public static let appleZero = 2451910.5             // 2001-Jan-01 00h00m00.0s (CFAbsoluteTime zero)

}

public struct TimeConstants {

           static let       daysPerYear = 365.25        // days in a Julian year
    public static let    daysPerCentury = 36525.0       // days in a Julian century

           static let     secondsPerDay = 86400.0       // seconds in a day
           static let    secondsPerYear = daysPerYear * secondsPerDay
           static let secondsPerCentury = daysPerCentury * secondsPerDay

    public static let    day2hrs = 24.0                 // hours in a day ..
    public static let    hrs2day = 1.0 / 24.0
    public static let    day2min = 24.0 * 60.0          // minutes in a day ..
    public static let    min2day = 1.0 / day2min
    public static let    day2sec = 24.0 * 60.0 * 60.0   // seconds in a day ..
    public static let    sec2day = 1.0 / day2sec

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ TLE base time (1949-12-31 00:00:00 UTC) as a Swift Date (seconds since 2001-01-01 00:00:00 UTC)  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    static let tleEpochReferenceDate = Date(julianDate: JD.epoch1950)
}

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public let dateFormatterUTC: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter
}()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public let dateFormatterRFC: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
public let dateFormatterLocal: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    formatter.timeZone = TimeZone.current
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ DateUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on 5/29/17.         Copyright © 2017-19 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

extension Date {

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  some Date extensions relative to the TLE epoch origin, 1949-Dec-31 00h00m00.0s                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Seconds from TLE Epoch to the reference date, 2001-Jan-01 00h00m00.0s (CFAbsoluteTime zero)     │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public static let timeIntervalBetween1950AndReferenceDate: TimeInterval = 1_609_545_600.0

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Returns a Date initialized relative to the TLE epoch by a given number of seconds ...           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(timeIntervalSince1950: TimeInterval) {
        self.init(timeIntervalSinceReferenceDate:
                                timeIntervalSince1950 - Date.timeIntervalBetween1950AndReferenceDate)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var timeIntervalSince1950: TimeInterval {
        return self.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1950AndReferenceDate
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create a Date from decimal days since the TLE epoch                                              │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(daysSince1950: Double) {
        self = Date(timeInterval: daysSince1950 * TimeConstants.day2sec,
                    since: TimeConstants.tleEpochReferenceDate)            // seconds since 1950
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to days since 1950 (TLE epoch-zero) ..                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var daysSince1950: Double { return julianDate - JD.epoch1950 }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var UTC: String {
        return dateFormatterUTC.string(from: self)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create a Date from year, month and day ..                                                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(year y: Int, month m: Int, day d: Int) {
        self = NSCalendar(identifier: .gregorian)?
                            .date(from: DateComponents(timeZone: TimeZone(secondsFromGMT: 0),
                                                       year: y, month: m, day: d)) ?? Date.distantPast
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ create a Date from a Julian date ..                                                              │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(julianDate: Double) {
        self = Date(timeIntervalSinceReferenceDate: (julianDate - JD.appleZero) * TimeConstants.day2sec)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to a Julian date ..                                                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var julianDate: Double { return JD.appleZero +
                                            timeIntervalSinceReferenceDate * TimeConstants.sec2day }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to days since 1900 ..                                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var daysSince1900: Double { return julianDate - JD.epoch1900 }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ stringify a Date to current locale ..                                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var localDescription: String {
        return DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .long)
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  some angle functions hms <-> degrees ...                                                        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func deg2hms(decimalDegrees: Double) -> (Int, Int, Double) {
    let hour = decimalDegrees.remainder(dividingBy: 360.0) * deg2hrs
    let mins = (hour - floor(hour)) * 60.0
    let secs = (mins - floor(mins)) * 60.0

    return (Int(hour), Int(mins), secs)
}

public func hms2deg(hms: (Int, Int, Double)) -> Double {
    return (Double((hms.0*60 + hms.1)*60) + hms.2) / 240.0
}

public func stringHMS(hms: (Int, Int, Double)) -> String {
    return String(format: "%02dʰ%02dᵐ%05.2f", hms.0, hms.1, hms.2)
}
