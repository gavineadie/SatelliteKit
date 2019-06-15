import XCTest
@testable import SatelliteKit

final class SatelliteKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SatelliteKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
