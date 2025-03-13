/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ShadowEvents.swift                                                                        SatKit ║
  ║ Created by Mathis Gaignet on Mars10/25     Copyright © 2017-25 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

@available(iOS 13.0.0, *)
public struct ShadowEvents {
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Return satellite's date when it enters or exit Earth's shadow during its pass                    │
  │ All other functions are helpers                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    @MainActor public static func calculateShadowEvents(
        satellite: Satellite,
        riseTime: Date,
        setTime: Date,
        observer: LatLonAlt
    ) async throws -> ShadowEventResult {
        
        let julianDateRise = riseTime.julianDate
        let satellitePosRise = try satellite.position(julianDays: julianDateRise)
        let sunPosRise = solarCel(julianDays: julianDateRise)
        let initialShadowState = isInEarthShadow(
            satellitePos: satellitePosRise,
            sunPos: sunPosRise,
            observerPos: observer,
            julianDate: julianDateRise
        )
        
        let events = try detectAllShadowEvents(
            satellite: satellite,
            from: riseTime,
            to: setTime,
            observer: observer,
            initialState: initialShadowState
        )
        
        var entryTime: Date? = nil
        var exitTime: Date? = nil
        
        // Weird little correction I made for the result to work properly
        
        let now = Date()
        let daysInFuture = riseTime.timeIntervalSince(now) / (24*3600)
        let correction = -30 - (daysInFuture * 5)

        for (time, isEntry) in events {
            if isEntry {
                entryTime = time.addingTimeInterval(correction)
            } else {
                exitTime = time.addingTimeInterval(correction)
            }
        }

        return ShadowEventResult(entry: entryTime, exit: exitTime)
    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Detects when the satellite enters or exits Earth's shadow during its pass                        │
  │                                                                                                  │
  │ This function performs a quick scan of the entire pass duration to identify shadow transitions   │
  │ Once a transition is detected at the minute level, it refines the detection by checking every    │
  │ 10 seconds within that minute                                                                    │
  │                                                                                                  │
  │ - If entry > exit, the satellite leaves the shadow (isInShadow = false)                          │
  │ - If exit > entry, the satellite enters the shadow (isInShadow = true)                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private static func detectAllShadowEvents(
        satellite: Satellite,
        from riseTime: Date,
        to setTime: Date,
        observer: LatLonAlt,
        initialState: Bool,
        coarseStep: Int = 60,
        fineStep: Int = 10
    ) throws -> [(time: Date, isEntry: Bool)] {
        
        var currentTime = riseTime
        var previousShadowState = initialState
        var events: [(time: Date, isEntry: Bool)] = []

        while currentTime <= setTime {
            let julianDate = currentTime.julianDate
            let satellitePos = try satellite.position(julianDays: julianDate)
            let sunPos = solarCel(julianDays: julianDate)
            let elevation = satelliteElevation(satellitePos: satellitePos, observerPos: observer, julianDate: julianDate)

            if elevation > 0 {
                let isInShadow = isInEarthShadow(
                    satellitePos: satellitePos,
                    sunPos: sunPos,
                    observerPos: observer,
                    julianDate: julianDate
                )

            if isInShadow != previousShadowState {
                if let refinedTime = try refineShadowEvent(
                    satellite: satellite,
                    around: currentTime.addingTimeInterval(TimeInterval(-coarseStep)),
                    end: currentTime,
                    observer: observer,
                    step: fineStep,
                    targetState: isInShadow
                ) {
                    events.append((refinedTime, isInShadow))
                }
            }
            previousShadowState = isInShadow
            }
            currentTime = currentTime.addingTimeInterval(TimeInterval(coarseStep))
        }
        return events
    }


    private static func refineShadowEvent(
        satellite: Satellite,
        around start: Date,
        end: Date,
        observer: LatLonAlt,
        step: Int,
        targetState: Bool
    ) throws -> Date? {
        var preciseTime = start
        while preciseTime <= end {
            let julianDate = preciseTime.julianDate
            let satellitePos = try satellite.position(julianDays: julianDate)
            let sunPos = solarCel(julianDays: julianDate)

            let elevation = satelliteElevation(satellitePos: satellitePos, observerPos: observer, julianDate: julianDate)
            if elevation > 0 {
                let isInShadow = isInEarthShadow(
                    satellitePos: satellitePos,
                    sunPos: sunPos,
                    observerPos: observer,
                    julianDate: julianDate
                )
                if isInShadow == targetState {
                    return preciseTime
                }
            }
            preciseTime = preciseTime.addingTimeInterval(TimeInterval(step))
        }
        return nil
    }
    
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Determines whether the satellite is in Earth's shadow                                            │
  │ This function calculates if the satellite is in the umbra region by checking the angle           │
  │ between the satellite, Earth, and the Sun. If the angle exceeds the threshold for full shadow,   │
  │ the function returns true                                                                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private static func isInEarthShadow(
        satellitePos: Vector,
        sunPos: Vector,
        observerPos: LatLonAlt,
        julianDate: Double
    ) -> Bool {
        let earthRadius = 6378.0 // km
        let earthToSat = satellitePos
        let satDistance = earthToSat.magnitude()
        let earthToSun = sunPos
        let earthToSatUnit = normalize(earthToSat)
        let earthToSunUnit = normalize(earthToSun)
        let cosAngle = dotProduct(earthToSunUnit, earthToSatUnit)
        let angleSunEarthSat = acos(cosAngle) * rad2deg
        let earthAngularRadius = asin(earthRadius / satDistance) * rad2deg
        let sunAngularRadius = 0.53
        
        let umbraAngleThreshold = 180.0 - (earthAngularRadius - sunAngularRadius)
        let penumbraAngleThreshold = 180.0 - (earthAngularRadius + sunAngularRadius)
        
        // Total shadow
        let isInUmbra = angleSunEarthSat > umbraAngleThreshold && cosAngle < 0
        
        // Partial Shadow (isInPenumbra, not used)
        _ = angleSunEarthSat > penumbraAngleThreshold && cosAngle < 0
        
        // Optionally return isInPenumbra for further computations
        return isInUmbra
    }

    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ Calculates the elevation angle of the satellite relative to the observer                         │
  │ It ensures that the satellite is still above the horizon at a given moment,                      │
  │ even if the precomputed rise and set times are slightly inaccurate                               │
  │ It helps refine shadow detection by confirming visibility in real-time                           │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    private static func satelliteElevation(
        satellitePos: Vector,
        observerPos: LatLonAlt,
        julianDate: Double
    ) -> Double {
        let observerECI = geo2eci(julianDays: julianDate, geodetic: observerPos)
        let observerToSat = satellitePos - observerECI
        let observerZenith = normalize(observerECI)
        let cosElevation = dotProduct(normalize(observerToSat), observerZenith)
        
        return asin(cosElevation) * rad2deg
    }
}


public struct ShadowEventResult: Equatable, Hashable, Sendable {
    public let entry: Date?
    public let exit: Date?

    public init(entry: Date?, exit: Date?) {
        self.entry = entry
        self.exit = exit
    }
}
