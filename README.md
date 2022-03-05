# SatelliteKit
___Satellite Prediction Library___

`SatelliteKit` is a library, written in Swift, implementing the SGP4/SDP4 earth-orbiting satellite
propagation algorithms first published in the
[SpaceTrack Report #3](https://celestrak.com/NORAD/documentation/)
and later refined by Vallado et al in
[Revisiting Spacetrack Report #3](https://celestrak.com/publications/AIAA/2006-6753/).

The code of this library is derived from [Orekit](https://www.orekit.org) which implements
the above published algorithms as a small part of it's extensive capabilities.
Test output from `SatelliteKit` agrees, to meaninglessly high precision, with Orekit
test output and the test output in the above published paper [1].

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
Lastest change: Version/Tag 1.1.2 -- 2022 Mar 05

### Elements

The `Elements` structure is initialized from the three lines of elements in a traditional TLE set.
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
it will not do so if the record checksum fails.  More complete correctness of the element record can
be verified by:

	public func formatOK(_ line1: String, _ line2: String) -> Bool

which will return `true` if the lines are 69 characters long, format is valid, and checksums are good.
Note that `line0` doesn't take part in the check so is omitted for this function, and that `formatOK` will
emit explicit errors into the log.

#### Other data formats

There has been concern for some time that the three line element sets will become limited,
not least of all because they only allow 5 digits for a object's unique NORAD numeric identifier.
It has been proposed to provide other, less constricted, data formats.
More information on this move will be found at
[A New Way to Obtain GP Data (aka TLEs)](https://celestrak.com/NORAD/documentation/gp-data-formats.php)

`SatelliteKit` has been changed to allow the ingestion of GP data in a JSON form .. for example, given JSON
data, this would decode an array of TLE structures (I'm not catching errors in the example, but you should):

    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

    let tleArray = try jsonDecoder.decode([TLE].self, from: jsonData)
    print(Satellite(withTLE: tleArray[0]).debugDescription())
    print(Satellite(withTLE: tleArray[1]).debugDescription())
    print(Satellite(withTLE: tleArray[2]).debugDescription())


The `Elements` structure also implements `debugDescription` which will generate this formatted `String`

    ┌─[elements :  0.66 days old]]──────────────────────────────────────────
    │  ISS (ZARYA)                 25544 = 1998-067A   rev#:09857 tle#:0999
    │     t₀:  2018-02-08 22:51:49 +0000    +24876.95265046 days after 1950
    │
    │    inc:  51.6426°     aop:  86.7895°    mot:  15.53899203 (rev/day)
    │   raan: 297.9871°    anom: 100.1959°    ecc:   0.0003401
    │                                        drag:  +3.2659e-05
    └───────────────────────────────────────────────────────────────────────

### Satellite

Having obtained the `Elements` for a satellite, it is used to initialize a `Satellite` struct which will
manage the propagation of the object's position and velocity as time is varied from the epochal
t=0 of the element set.  Whether the object requires the "deep space" propagator, or not, is
determined within the `Satellite` initialization.

The `Satellite` initializers are:

    public init(_: String, _: String, _: String)  	// three TLE lines ..
    public init(withTLE: TLE)                     	// an Elements struct ..
    public init(elements: Elements)             	// an Elements struct ..

The `Satellite` struct offers some public properties and some public functions.

The *properties* provide some naming information and a "grab bag" directory for whatever you want.

    public let tle: Elements                    	// make TLE accessible
    public let commonName: String
    public let noradIdent: String
    public let t₀Days1950: Double       		    // TLE t=0 (days since 1950)
    public var extraInfo: [String: AnyObject]

The *functions* accept a time argument, either minutes after the satellite's TLE epoch, or Julian Days,
and provide postion (Kilometers) and velocity (Kms/sec) state vectors as output.

    public func position(minsAfterEpoch: Double) -> Vector
    public func velocity(minsAfterEpoch: Double) -> Vector

    public func position(julianDays: Double) -> Vector
    public func velocity(julianDays: Double) -> Vector

### Sample Usage

This is a simple invocation of the above:

    do {
        let elements = try Elements("ISS (ZARYA)",
                                    "1 25544U 98067A   18039.95265046  .00001678  00000-0  32659-4 0  9999",
                                    "2 25544  51.6426 297.9871 0003401  86.7895 100.1959 15.54072469 98577")

        let sat = Satellite(elements)
        print(sat.debugDescription())
        let posInKms = sat.position(minsAfterEpoch: 10.0)

    } catch {
        print(error)
    }

### Dealing with TLE files

The most commonly available form of TLE data is a file containing multiple concatenated TLEs.  The `String`
content of such a file may be processed (records that are empty or start with "#" are dropped then
leading and trailing whitespace is stripped and non-breaking spaces are converted to regular spaces)
and checked for quality (line length is 69 characters and the checksum is good) within SatelliteKit with the function:

    public func preProcessTLEs(_: String) -> [(String, String, String)]

`preProcessTLEs` consumes a `String` of, presumably, TLE records, and returns an array of
`(String, String, String)` tuples, one per satellite.  The tuple items are the, mildly verified, zeroth, first
and second of one satellite's TLE lines. If the TLEs are the two-line variety, the first member of the
tuple is an empty `String`.

Thus, the contents of a TLE file would be mapped to an array of `Satellite` by:

    let satArray = preProcessTLEs(fileContents).map( { return Satellite($0.0, $0.1, $0.2) } )

A more rigorous quality check can be preformed using:

    public func formatOK(_: String, _: String) -> Bool

which checks the format of TLE lines "1" and "2" .. using a regex test, a time consuming action
that is not performed in `preProcessTLEs`.

### Inclusion

`SatelliteKit` can be added to your project using the Swift Package Manager (SwiftPM) by adding
the dependency:

    .package(url: "https://github.com/gavineadie/SatelliteKit.git", from: "1.0.0")

and using `import SatelliteKit` in code that needs it.

### Platforms

`SatelliteKit` has been used for applications on iOS devices (iPhone, iPad and TV),
and Macintosh computers (GUI and command line).  It has not yet been
exposed to the Unix Swift enviroment.

### Author

Translation from C++ and Java, testing and distribution by [Gavin Eadie](mailto:gavineadie.dev@icloud.com)

---
`version/tag 1.0.0 .. (2019 Jun 14)`

- First Swift Package Manager (SwiftPM) version.

`version/tag 1.0.8 .. (2019 Oct 03)`

- Corrects an error in the computation of azimuth-elevation-distance.

`version/tag 1.0.9 .. (2019 Oct 03)`

- move `debugDescription()` from the `TLE` structure to the `Satellite` structure

- remove public access to `dragCoeff` (it's never used)

`version/tag 1.0.16 .. (2020 Jan 27)`

- update copyright year to 2020

`version/tag 1.0.20 .. (2020 Feb 26)`

- correct and clarify the conversion of satellite position as seen by an observer after a bug in `eci2top(..)` was corrected.

`version/tag 1.0.21 .. (2020 Mar 09)`

- include the age of the TLE set in its `debugDescription(..)`.

`version/tag 1.0.22 .. (2020 Apr 25)`

- Package description specifies: `.macOS(.v10_12), .iOS(.v9)`

`version/tag 1.0.23 .. (2020 Jun 04)`

- Partial preparation for new NORAD General Perturbations (GP) Element Set formats which
accommodate NORAD catalog IDs that are more than 5 digits ..

`version/tag 1.0.24 .. (2020 Jun 04)`

- provide an (**EXPERIMENTAL**) TLE initializer that consumes a JSON version of the new NORAD GP Element Set.
- the TLE property `launchName` has been expanded from, for example: `98067A` to `1998-067A` .. since this property
is mostly decorative, with no semantic value, this is not treated as an API change

`version/tag 1.0.25 .. (2020 Jun 07)`

- clean up the JSON version of the TLE initializer.
- start work on an (**EXPERIMENTAL**) XML version of the TLE initializer.

`version/tag 1.0.26 .. (2020 Jun 30)`

- move "Satellite.swift" from "Astro" group to "SGP" group.

`version/tag 1.0.27 .. (2021 Jan 30)`

- make the TLE struct accessible from the Satellite struct.

`version/tag 1.0.27 .. (2021 Mar 05)`

- [SpaceTrack Alpha-5](https://www.space-track.org/documentation#tle-alpha5)
- TLEs with the new Space-Track Alpha-5 object numbers (`noradIndex`) are processed correctly.
- The tag has not changed because this feature has been present for some time.

`version/tag 1.0.28 .. (2021 May 14)`

- Alpha-5 NORAD numbers are decoded correctly (no functional change).

`version/tag 1.0.30 .. (2022 Feb 17)`

- SwiftPM: remove linkerSettings .. adjust copyright year "..-22"

`version/tag 1.0.31 .. (2022 Feb 19)`

- TLE initialization: factored out unKozai()
- moved XML parsing to own file
- revised the XML unit test

- NOTE: API CHANGES (minor version number changed .. backward compatible, for now)**

`version/tag 1.1.0 .. (2022 Feb 28)`

- `TLE` struct replaced with `Elements`
- `TLE` typealias'd to `Elements` (for backward compatibility)
- (for example) `debugDescription()` is now a method on `Element`
- `TLEPropagator` class replaced with `Propagator` .. (private anyway)
- `noradIndex` can't be negative so made `UInt`
- some time functions moved to `TimeUtility.swift`
- `TLE.n₀ʹ` removed from `public`

`version/tag 1.1.1 .. (2022 Mar 02)`

- JSON import much improved
- JSON export implemented
- `TLE` deprecated

`version/tag 1.1.2 .. (2022 Mar 05)`

- XML import much improved
- Objection to `tleClass == "U"` removed [Starlinks are "C"]

---
