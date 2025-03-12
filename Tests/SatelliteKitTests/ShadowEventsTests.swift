import Testing
import Foundation

@testable import SatelliteKit

struct Test {

    
    // Old test results may be outdated
    @Test
    func calculateShadowEventsTest_ShouldReturnCorrectTime() async throws {
        let TLE = (
            line0: "",
            line1: "1 25544U 98067A   25071.47094811  .00014495  00000-0  26208-3 0  9993",
            line2: "2 25544  51.6351  66.0638 0006419  13.0256 347.0898 15.49921961500167"
        )
        let elements = try Elements(TLE.0, TLE.1, TLE.2)
        let satellite = Satellite(elements: elements)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Paris")

        let riseTime = dateFormatter.date(from: "2025-03-21T20:58:00")!
        let setTime = dateFormatter.date(from: "2025-03-21T21:07:00")!
        
        let observer = LatLonAlt(48.8589, 2.32, 0)
        
        let shadowTime = try await ShadowEvents.calculateShadowEvents(
            satellite: satellite,
            riseTime: riseTime,
            setTime: setTime,
            observer: observer
        )
        
        let expectedMin = dateFormatter.date(from: "2025-03-21T21:05:00")!
        let expectedMax = dateFormatter.date(from: "2025-03-21T21:06:00")!
        
        print("shadow time is \(shadowTime)", terminator: "\n")
        
        #expect(shadowTime.entry ?? .now >= expectedMin && shadowTime.exit ?? .now <= expectedMax)

    }

}
