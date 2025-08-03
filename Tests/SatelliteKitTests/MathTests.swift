/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ MathTests.swift                                                                                  ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Dec07/18     Copyright 2018-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

// swiftlint:disable comma

import Testing
import Foundation
@testable import SatelliteKit

struct MathTests {

    struct MathsTest {

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                                  │
  │               |                                                                                  │
  │       +,-     |    +,+                                                                           │
  │               |                                                                                  │
  │               |                                                                                  │
  │     ----------+----------                                                                        │
  │               |                                                                                  │
  │               |                                                                                  │
  │       -,-     |    -,+                                                                           │
  │               |                                                                                  │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
        @Test func Trig() {

            #expect((atan2pi(+1.0, +1.0) * rad2deg) == 45.0)
            #expect((atan2pi(+1.0, -1.0) * rad2deg) == 135.0)
            #expect((atan2pi(-1.0, -1.0) * rad2deg) == 225.0)
            #expect((atan2pi(-1.0, +1.0) * rad2deg) == 315.0)

        }

        @Test func Almost() {

            #expect(almostEqual(10.0, 10.000000000000001))
            #expect(almostEqual(10.0,  9.999999999999999))

            #expect(almostEqual(10.0, 10.000000000000002))
            #expect(almostEqual(10.0,  9.999999999999998))

            #expect(!almostEqual(10.0, 10.000000000000005))
            #expect(!almostEqual(10.0,  9.999999999999995))

            #expect(!almostEqual(10.0, 10.00000000000001))
            #expect(!almostEqual(10.0,  9.99999999999999))

            #expect(!almostEqual(1e-200, 1e-201))

            #expect(10.0 ≈ 10.000000000000001)
            #expect(10.0 ≈  9.999999999999999)

            #expect(!(10.0 ≈ 10.00000000000001))
            #expect(!(10.0 ≈  9.99999999999999))

            #expect(!(1e-200 ≈ 1e-201))
       }

        @Test func DotProduct() {

            var v1 = Vector()
            var v2 = Vector()

            #expect((v1 • v2) == 0.0)

            v1 = Vector(1.0, 0.0, 0.0)
            v2 = Vector(1.0, 0.0, 0.0)
            #expect((v1 • v2) == 1.0)

            v1 = Vector(1.0, 3.0, -5.0)
            v2 = Vector(4.0, -2.0, -1.0)
            #expect((v1 • v2) == 3.0)

        }

        @Test func CrossProduct() {

            var v1 = Vector(1.0, 0.0, 0.0)
            var v2 = Vector(0.0, 1.0, 0.0)

            #expect((v1 ⨯ v2) == Vector(0.0, 0.0, +1.0))
            #expect((v2 ⨯ v1) == Vector(0.0, 0.0, -1.0))

            v1 = Vector(0.0, 0.0, 1.0)
            v2 = Vector(0.0, 1.0, 0.0)

            #expect((v2 ⨯ v1) == Vector(1.0, 0.0, 0.0))

        }

        @Test func Limits() {
            #expect(limit180(180.0) == 180.0)
            #expect(limit180(120.0) == 120.0)
            #expect(limit180(60.0) == 60.0)
            #expect(limit180(0.0) == 0.0)
            #expect(limit180(-60.0) == -60.0)
            #expect(limit180(-120.0) == -120.0)
            #expect(limit180(-180.0) == -180.0)
            #expect(limit180(-240.0) == 120.0)

            #expect(limit360(420.0) == 60.0)
            #expect(limit360(360.0) == 360.0)
            #expect(limit360(300.0) == 300.0)
            #expect(limit360(240.0) == 240.0)
            #expect(limit360(180.0) == 180.0)
            #expect(limit360(120.0) == 120.0)
            #expect(limit360(60.0) == 60.0)
            #expect(limit360(0.0) == 0.0)
            #expect(limit360(-60.0) == 300.0)
            #expect(limit360(-120.0) == 240.0)
            #expect(limit360(-180.0) == 180.0)
            #expect(limit360(-240.0) == 120.0)

            #expect(abs(limit360(360.00001) -   0.00001) < 0.0000000001)
            #expect(limit360(360.00000) == 360.0)
            #expect(abs(limit360(359.99999) - 359.99999) < 0.0000000001)

        }

        @Test func normalizeAngle() {

            for angle in stride(from: -400.0, to: +400.0, by: 20.0) {
                print("   \(angle) : \((fmod2pi_0(angle*deg2rad)*rad2deg).roundTo6Places())")
            }

        }

//        @available(OSX 10.12, *)
//        @Test func Units() {
//            let degrees = Measurement<UnitAngle>(value: 1.0, unit: .degrees)
//            print(degrees.description)
//
//            let radians = Measurement<UnitAngle>(value: 1.0, unit: .radians)
//            print(radians.description)
//        }

//        func testPerformanceLimit180() {
//
//            self.measure {
//                for angle in stride(from: -400.0, to: +400.0, by: 20.0) {
//                    _ = limit180(angle)
//                }
//            }
//
//        }
//
//        func testPerformanceLimit360() {
//
//            self.measure {
//                for angle in stride(from: -220.0, to: +580.0, by: 20.0) {
//                    _ = limit360(angle)
//                }
//            }
//
//        }

    }

}
