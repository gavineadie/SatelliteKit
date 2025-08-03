/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ AstroTests.swift                                                                                 ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Feb25/20     Copyright 2020-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable comma

import Testing
import Foundation
@testable import SatelliteKit

struct AstroTests {
    
    @Test
    func TestDs1950() {
        let s1 = solarCel(ds1950: 0.0)
        let s2 = solarCel(julianDays: 2433281.5)

        #expect(s1.x == s2.x)
        #expect(s1.y == s2.y)
        #expect(s1.z == s2.z)
    }

    @Test 
    func Solar() {
        var baseJD: Double
        if #available(macOS 12, *) {
            baseJD = Date.now.julianDate
        } else {
            baseJD = Date().julianDate
        }
        for hour in 0...24 {
            let hourJD = baseJD + Double(hour)/24.0
            let v = solarCel(julianDays: hourJD)
            let hourAngle = siteMeanSiderealTime(julianDate: hourJD, -80.0)
            print(hour, hourJD, hourAngle, v)
        }
    }
}
