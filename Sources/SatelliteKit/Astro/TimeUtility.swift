/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ TimeUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on Jan07/17 ... Copyright 2017-23 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
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
  ┃                                      --------|||----------------------|---                       ┃
  ┃                                              |||                    2001                         ┃
  ┃                                          NORAD: 0 -- JD: 2433281.5    |                          ┃
  ┃                                              |||                 Apple: 0 -- JD: 2451910.5       ┃
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
extension DateFormatter {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public static let iso8601Micros: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public static let utc: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public static let rfc: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public static let local: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ DateUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on May29/17         Copyright © 2017-20 Gavin Eadie. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  some Date extensions relative to the TLE epoch origin, 1949-Dec-31 00h00m00.0s                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
extension Date {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Creates a Date from decimal days since the TLE epoch                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(ds1950: Double) {
        self = Date(timeInterval: ds1950 * TimeConstants.day2sec,    // seconds since 1950
                    since: TimeConstants.tleEpochReferenceDate)
    }

    public init(daysSince1950: Double) {
        self = Date(timeInterval: daysSince1950 * TimeConstants.day2sec,    // seconds since 1950
                    since: TimeConstants.tleEpochReferenceDate)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Seconds from TLE Epoch to the reference date, 2001-Jan-01 00h00m00.0s (CFAbsoluteTime zero)     │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    static let timeIntervalBetween1950AndReferenceDate: TimeInterval = 1_609_545_600.0

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │  Creates a Date from a given number of seconds relative to the TLE epoch ..                      │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public init(timeIntervalSince1950: TimeInterval) {
        self.init(timeIntervalSinceReferenceDate:
                                timeIntervalSince1950 - Date.timeIntervalBetween1950AndReferenceDate)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var timeIntervalSince1950: TimeInterval {
        self.timeIntervalSinceReferenceDate + Date.timeIntervalBetween1950AndReferenceDate
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to days since 1950 .. commonly "ds1950"                                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var daysSince1950: Double { julianDate - JD.epoch1950 }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var UTC: String {
        DateFormatter.utc.string(from: self)
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
    public var julianDate: Double { JD.appleZero +
                                            timeIntervalSinceReferenceDate * TimeConstants.sec2day }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ convert a Date to days since 1900 ..                                                             │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var daysSince1900: Double { julianDate - JD.epoch1900 }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ stringify a Date to current locale ..                                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    public var localDescription: String {
        DateFormatter.localizedString(from: self, dateStyle: .medium, timeStyle: .long)
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃  some angle functions hms <-> degrees ...                                                        ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func deg2hms(decimalDegrees: Double) -> (Int, Int, Double) {
    let hour = decimalDegrees.truncatingRemainder(dividingBy: 360.0) * deg2hrs
    let mins = ((hour - floor(hour)) * 60.0).roundTo6Places()
    let secs = ((mins - floor(mins)) * 60.0).roundTo3Places()

    return (Int(hour), Int(mins), secs)
}

public func hms2deg(hms: (Int, Int, Double)) -> Double {
    ((Double((hms.0*60 + hms.1)*60) + hms.2) / 240.0).roundTo3Places()
}

public func stringHMS(hms: (Int, Int, Double)) -> String {
    String(format: "%02dʰ%02dᵐ%06.3f", hms.0, hms.1, hms.2)
}

// MARK: -

/// `ep1950DaysNow` ...
/// - Returns: the current number of days since Epoch 9050
public func ep1950DaysNow() -> Double {
    julianDaysNow() - JD.epoch1950
}

/// `julianDay` calculate the JD of the time this method is executed
/// - Returns: this moment's JD
public func julianDaysNow() -> Double {
    JD.appleZero + Date().timeIntervalSinceReferenceDate * TimeConstants.sec2day
}
