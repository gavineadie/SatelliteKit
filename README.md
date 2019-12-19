# SatelliteKit
___Satellite Prediction Library___

`SatelliteKit` is a library, written in Swift, implementing the SGP4/SDP4 earth-orbiting satellite
propagation algorithms first published in the
[SpaceTrack Report #3](https://celestrak.com/NORAD/documentation/)
and later refined by Vallado et al in
[Revisiting Spacetrack Report #3](https://celestrak.com/publications/AIAA/2006-6753/).

The code of this library is derived from [Orekit](https://www.orekit.org) which, in part,
implements the above published algorithms.  Test output from `SatelliteKit` agrees,
to meaninglessly high precision, with Orekit test output and the test output in
the above published paper [1].

[1] "Vallado, David A.; Paul Crawford; Richard Hujsak; T. S. Kelso,
(August 2006), Revisiting Spacetrack Report #3".


  _Some people will be surprised by some of my source code comment format; it is a style
  I inherited from a systems programming language I used long ago and it is really not
  appropriate for publicly released code in the modern age (especially since Swift has
  markup built in)._

  _Also note that there is extensive use
  of Unicode characters in property names and other places.  This attempts to match, as
  much as is reasonable, the mathematical notation and Greek characters usage in the
  original 1980 Spacetrack Report._


### Change Notes

At the end of the README.

### TLE

The `TLE` structure is initialized from the three lines of elements in a traditional TLE set.
Some sources of TLEs provide no first line (which would contain the object's informal name) and,
in that case, it is OK to pass a null `String` into the initializer.

	public init(_ line0: String, _ line1: String, _ line2: String) throws

The public properties that are exposed from the `TLE` structure are:

	public let commonName: String                       // line zero name (if any)
	public let noradIndex: Int                          // The satellite number.
	public let launchName: String                       // International designation
	public let t₀: Double                               // the TLE t=0 time (days from 1950)
	public let e₀: Double                               // TLE .. eccentricity
	public let i₀: Double                               // TLE .. inclination (rad).
	public let ω₀: Double                               // Argument of perigee (rad).
	public let Ω₀: Double                               // Right Ascension of the Ascending node (rad).
	public let M₀: Double                               // Mean anomaly (rad).
	public let n₀: Double                               // Mean motion (rads/min)  << [un'Kozai'd]
	public let a₀: Double                               // semi-major axis (Eᵣ)    << [un'Kozai'd]

Note that the operation to "un Kozai" the element data is performed inside the initialization because
both SGP4 and SDP4 need that adjustment.

The initializer will throw an exception if the numeric parsing of the element data fails, however,
it will not do so if the record checksum fails.  The general correctness of the element record can
be verified by:

	public func formatOK(_ line1: String, _ line2: String) -> Bool

which will return `true` if the lines are 69 characters long, format is valid, and checksums are good.
Note that `line0` doesn't take part in the check so is omitted for this function, and that `formatOK` will
emit more explicit errors into the log.

The `TLE` structure also implements `debugDescription` which will generate this formatted `String`

    ┌─[tle]─────────────────────────────────────────────────────────────────
    │  ISS (ZARYA)                 25544 = 98067A      rev#:09857 tle#:0999
    │     t₀:  2018-02-08 22:51:49 +0000    +24876.95265046 days after 1950
    │
    │    inc:  51.6426°     aop:  86.7895°    mot:  15.53899203 (rev/day)
    │   raan: 297.9871°    anom: 100.1959°    ecc:   0.0003401
    │                                        drag:  +3.2659e-05
    └───────────────────────────────────────────────────────────────────────

### TLEPropagator

Having obtained the `TLE` for a satellite, it is used to initialize a `TLEPropagator` class which will
manage the propagation of the object's position and velocity as time is varied from the epochal
t=0 of the element set.  Whether the object requires the "deep space" propagator, or not, is
determined within the `TLEPropagator` initialization.

The initializer is called internally by the static function:

    public func selectPropagator(tle: TLE) -> TLEPropagator

The `TLEPropagator` class offers no public properties and two public functions.  Both functions
accept a time argument and provide postion and velocity state vectors as output.

    public func getPVCoordinates(minsAfterEpoch: Double) throws -> PVCoordinates
    public func getPVCoordinates(_ date: Date) throws -> PVCoordinates

These functions will throw exceptions under circumstance when some anomaly in the object's elements
suggests various problems in the modeled physical world (perigee below the ground, etc).

### PVCoordinates

The `PVCoordinates` structure returned by the propagator encapsulates position and velocity vectors:

    public struct Vector {
        public var x: Double
        public var y: Double
        public var z: Double
    }

    public struct PVCoordinates {
        public var position: Vector                 // position in meters
        public var velocity: Vector                 // velocity in m/sec
    }

### Sample Usage

This is a simple invocation of the above:

    do {
        let tle = try TLE("ISS (ZARYA)",
                          "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
                          "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577")

        print(tle.debugDescription())

        let propagator = selectPropagator(tle: tle)

        let pv1 = try propagator.getPVCoordinates(minsAfterEpoch: 10.0)
        print(pv1.debugDescription())

    } catch {

        print(error)

    }

The `debugDescription` of the state vectors in `pv1` is (position in meters, velocity in meters/second):

    P:  x=-4888356.5, y=+2748335.4, z=-3825769.7
    V:  x= -339.3375, y=-6410.3714, z=-4178.6616

### Platforms

`SatelliteKit` has been used for applications on iOS devices (iPhone, iPad and TV),
and Macintosh computers (GUI and command line).  It has not yet been
exposed to the Unix Swift enviroment.

### Author

Translation from C++ and Java, testing and distribution by [Gavin Eadie](mailto:gavineadie.dev@icloud.com)

---
- `version/tag 1.0.0 .. (2019 Jun 14)`

  First Swift Package Manager (SwiftPM) version.

- `version/tag 1.0.8 .. (2019 Oct 03)`

  Corrects an error in the computation of azimuth-elevation-distance.

- `version/tag 1.0.9 .. (2019 Oct 03)`

move "debugDescription()" from "tle" to "sat"

remove public access to "dragCoeff"

---

