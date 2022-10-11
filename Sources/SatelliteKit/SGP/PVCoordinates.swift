/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ PVCoordinates.swift                                                                       SatKit ║
  ║ Created by Gavin Eadie on May26/17         Copyright © 2017-22 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

public struct PVCoordinates {

    public let position: Vector                 // position in meters
    public let velocity: Vector                 // velocity in m/sec

    init(position pos: Vector, velocity vel: Vector) {
        self.position = pos
        self.velocity = vel
    }

    public func debugDescription() -> String {
        return String(format: "%12.3f %12.3f %12.3f %11.6f %11.6f %11.6f",
                                position.x/1000.0, position.y/1000.0, position.z/1000.0,
                                velocity.x/1000.0, velocity.y/1000.0, velocity.z/1000.0)
    }
}
