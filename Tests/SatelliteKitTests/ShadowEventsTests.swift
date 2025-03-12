import Testing
import Foundation

@testable import SatelliteKit

struct Test {

    @Test
    func calculateShadowEventsTest_ShouldReturnCorrectTime() async throws {
        let TLE = (
            line0: "",
            line1: "1 25544U 98067A   25069.48991731  .00012244  00000-0  22315-3 0  9993",
            line2: "2 25544  51.6366  75.8722 0006264   7.6024  91.8047 15.49864464499852"
        )
        let elements = try Elements(TLE.0, TLE.1, TLE.2)
        let satellite = Satellite(elements: elements)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")

        let riseTime = dateFormatter.date(from: "2025-03-10T19:50:00")!
        let setTime = dateFormatter.date(from: "2025-03-10T20:02:00")!
        
        let observer = LatLonAlt(34.0537, -118.2428, 0)
        
        let shadowTime = try await ShadowEvents.calculateShadowEvents(
            satellite: satellite,
            riseTime: riseTime,
            setTime: setTime,
            observer: observer
        )
        
        let expectedMin = dateFormatter.date(from: "2025-03-10T19:59:00")!
        let expectedMax = dateFormatter.date(from: "2025-03-10T20:00:00")!
        
        print("shadow time is \(shadowTime)", terminator: "\n")
        
        #expect(shadowTime.entry ?? .now >= expectedMin && shadowTime.exit ?? .now <= expectedMax)

    }

}
