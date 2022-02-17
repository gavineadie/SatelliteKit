/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ MathUtility.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on Nov17/15 ... Copyright 2009-22 Ramsay Consulting. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

// swiftlint:disable identifier_name

//NOTE interesting: https://gist.github.com/kelvin13/03d1fd5da024f058b6fd38fdbce665a4

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║                                                                               C O N S T A N T S  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

public let π = 3.141_592_653_589_793_238_462_643_383_279_502_884_197_169_399_375_105_820_975

public let ⅓ = 1.0 / 3.0
public let ⅔ = 2.0 / 3.0

public let  deg2rad: Double = π/180.0
public let  rad2deg: Double = 180.0/π

public let  hrs2deg: Double = 15.0                  // not used in library
public let  deg2hrs: Double = 1.0/hrs2deg           // not used in library

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║                                                                               O P E R A T O R S  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

prefix operator √

prefix func √ <T: FloatingPoint>(float: T) -> T {
    float.squareRoot()
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ almostEqual (test for equality to one ULP) .. 10.0 ~~ 10.000000000000001                         ┃
  ┃                      unit of least precision (ULP) is the spacing between floating-point numbers ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func almostEqual(_ a: Double, _ b: Double) -> Bool {
    return a == b || a == b.nextUp || a == b.nextDown
}

extension Double {
    func roundTo3Places() -> Double {
        return (self*1_000.0).rounded(.toNearestOrEven) / 1_000
    }

    func roundTo6Places() -> Double {
        return (self*1_000_000.0).rounded(.toNearestOrEven) / 1_000_000
    }
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ V E C T O R S                                                                                    ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

public struct Vector {

    public var x: Double
    public var y: Double
    public var z: Double

    public init() {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
    }

    public init(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }

    public static prefix func - (v: Vector) -> Vector {
        return Vector(-v.x, -v.y, -v.z)
    }

    public static func + (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }

    public static func - (lhs: Vector, rhs: Vector) -> Vector {
        return Vector(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }

    public func magnitude() -> Double {
        return (self.x*self.x + self.y*self.y + self.z*self.z).squareRoot()
    }
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ magnitude                                                                           [3-D Vector] ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func magnitude(_ vector: Vector) -> Double {
    return (vector.x*vector.x + vector.y*vector.y + vector.z*vector.z).squareRoot()
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ normalize to unit vector [zero length Vector aborts]                                             ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func normalize(_ vector: Vector) -> Vector {
    let mag = magnitude(vector)
    guard mag > 0 else { preconditionFailure("normalize: empty vector") }
    return Vector(vector.x / mag, vector.y / mag, vector.z / mag)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ dot product                                                                                      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
infix operator •

public func dotProduct(_ vector1: Vector, _ vector2: Vector) -> Double {
    return (vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z)
}

func • (_ vector1: Vector, _ vector2: Vector) -> Double {
    return (vector1.x*vector2.x + vector1.y*vector2.y + vector1.z*vector2.z)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ angle between (degrees)                                                                          ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func separation(_ vector1: Vector, _ vector2: Vector) -> Double {
    return(acos((vector1 • vector2) / (magnitude(vector1)*magnitude(vector2))) * rad2deg)
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ cross product                                                                                    ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
infix operator ⨯

public func crossProduct(_ vector1: Vector, _ vector2: Vector) -> Vector {
    return Vector(vector1.y*vector2.z - vector1.z*vector2.y,
                  vector1.z*vector2.x - vector1.x*vector2.z,
                  vector1.x*vector2.y - vector1.y*vector2.x)
}

func ⨯ (_ vector1: Vector, _ vector2: Vector) -> Vector {
    return Vector(vector1.y*vector2.z - vector1.z*vector2.y,
                  vector1.z*vector2.x - vector1.x*vector2.z,
                  vector1.x*vector2.y - vector1.y*vector2.x)
}

/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║                                                                         T R I G O N O M E T R Y  ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ atan2pi returns angles in range (0-2π radians)                           PS: atan2() -> +π to -π ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func atan2pi(_ y: Double, _ x: Double) -> Double {
    var     result = 0.0

    if (x != 0.0) ||
       (y != 0.0) { result = fmod2pi_π(atan2(y, x)) }

    return result
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ acos2pi returns angles in range (0-π for x/y>0; π-2π if x/y<0)             PS: acos() -> 0 to +π ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func acos2pi(_ x: Double, _ y: Double) -> Double {
    var result = 0.0

    if y > 0.0 { result =     acos(x/y) }
    if y < 0.0 { result = π + acos(x/y) }

    return result
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ fmod2pi_0(radians) -- limits 'radians' to -π..π                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func fmod2pi_0(_ angle: Double) -> Double {
    return angle - (π*2) * floor((angle + π) / (π*2))
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ fmod2pi_π(radians) -- limits 'radians' to 0..2π                                                  ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func fmod2pi_π(_ radians: Double) -> Double {
    var     result = fmod(radians, (π*2))

    if result < 0.0 { result += (π*2) }

    return result
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ limit180(degrees) -- limits 'degrees' to -180°..+180°                                            ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func limit180 (_ value: Double) -> Double {
    var value = value
    while value > +180.0 { value -= 360.0 }
    while value < -180.0 { value += 360.0 }
    return value
}

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ limit360(degrees) -- limits 'degrees' to 0°..+360°                                               ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
public func limit360 (_ value: Double) -> Double {
    var value = value
    while value > +360.0 { value -= 360.0 }
    while value <    0.0 { value += 360.0 }
    return value
}
