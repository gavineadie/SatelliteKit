/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ThreeLineElementTests.swift                                                                      ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on May05/19     Copyright 2019-20 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import XCTest
@testable import SatelliteKit

#if canImport(XMLCoder)
import XMLCoder
#endif

class ThreeLineElementTests: XCTestCase {

    func testNullLine0() {

        do {
            let tle = try TLE("",
                              "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                              "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(Satellite(withTLE: tle).debugDescription())

            XCTAssertEqual(tle.t₀, 17533.000)                   // the TLE t=0 time (days from 1950)

            XCTAssertEqual(tle.e₀, 0.0)                         // TLE .. eccentricity
            XCTAssertEqual(tle.M₀, 0.0)                         // Mean anomaly (rad).
            XCTAssertEqual(tle.n₀, 0.0653602440158348,
                           accuracy: 1e-12)                     // Mean motion (rads/min)  << [un'Kozai'd]

            print("mean altitude    (Kms): \((tle.a₀ - 1.0) * EarthConstants.Rₑ)")

            XCTAssertEqual(tle.i₀, 0.0)                         // TLE .. inclination (rad).
            XCTAssertEqual(tle.ω₀, 0.0)                         // Argument of perigee (rad).
            XCTAssertEqual(tle.Ω₀, 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    func testIndexedLine0() {

        do {
            let tle = try TLE("0 ZERO OBJECT",
                              "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                              "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(Satellite(withTLE: tle).debugDescription())

            XCTAssertEqual(tle.t₀, 17533.000)                   // the TLE t=0 time (days from 1950)

            XCTAssertEqual(tle.e₀, 0.0)                         // TLE .. eccentricity
            XCTAssertEqual(tle.M₀, 0.0)                         // Mean anomaly (rad).
            XCTAssertEqual(tle.n₀, 0.0653602440158348,
                           accuracy: 1e-12)                     // Mean motion (rads/min)  << [un'Kozai'd]

            XCTAssertEqual(tle.i₀, 0.0)                         // TLE .. inclination (rad).
            XCTAssertEqual(tle.ω₀, 0.0)                         // Argument of perigee (rad).
            XCTAssertEqual(tle.Ω₀, 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    func testNoIndexTLE() {

        do {
            let tle = try TLE("ZERO OBJECT",
                              "1 00000  57001    98001.00000000  .00000000  00000-0  00000-0 0  0000",
                              "2 00000   0.0000   0.0000 0000000   0.0000   0.0000 15.00000000 00000")

            print(Satellite(withTLE: tle).debugDescription())

            XCTAssertEqual(tle.t₀, 17533.000)                   // the TLE t=0 time (days from 1950)

            XCTAssertEqual(tle.e₀, 0.0)                         // TLE .. eccentricity
            XCTAssertEqual(tle.M₀, 0.0)                         // Mean anomaly (rad).
            XCTAssertEqual(tle.n₀, 0.0653602440158348,
                           accuracy: 1e-12)                     // Mean motion (rads/min)  << [un'Kozai'd]

            XCTAssertEqual(tle.i₀, 0.0)                         // TLE .. inclination (rad).
            XCTAssertEqual(tle.ω₀, 0.0)                         // Argument of perigee (rad).
            XCTAssertEqual(tle.Ω₀, 0.0)                         // Right Ascension of the Ascending node (rad).

        } catch {
            print(error)
        }

    }

    func testSuccessFormatTLE() {

        XCTAssertTrue(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                               "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has no leading "1"                                                                        │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE1() {

        XCTAssertFalse(formatOK("X 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has no leading "1" (blank)                                                                │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE2() {

        XCTAssertFalse(formatOK("  25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has bad checksum                                                                          │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE3() {

        XCTAssertFalse(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9991",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has bad length                                                                            │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureFormatTLE4() {

        XCTAssertFalse(formatOK("1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0 9991",
                                "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531"))

    }

/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  │ line 1 has non-zero ephemeris type                                                               │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func testFailureNonZeroEphemType() {

        XCTAssertTrue(formatOK("1 44433U 19040B   19196.49919926  .00000000  00000-0  00000-0 2  5669",
                               "2 44433 052.6278 127.6338 9908875 004.4926 008.9324 00.01340565    01"))

        do {
            let tle = try TLE("Spektr-RG Booster",
                              "1 44433U 19040B   19196.49919926  .00000000  00000-0  00000-0 2  5669",
                              "2 44433 052.6278 127.6338 9908875 004.4926 008.9324 00.01340565    01")

            print(Satellite(withTLE: tle).debugDescription())
        } catch {
            print(error)
        }
    }
    
    func testTleAccess() {

        let sat = Satellite("ISS (ZARYA)",
                            "1 25544U 98067A   17108.89682041  .00002831  00000-0  50020-4 0  9990",
                            "2 25544  51.6438 333.8309 0007185  71.6711  62.5473 15.54124690 52531")
        
        print("Mean motion:", sat.tle.n₀)

    }

    func testJsonTLE() {
        let jsonData = """
            {"OBJECT_NAME":"XINGYUN-2 01",
            "OBJECT_ID":"2020-028A",
            "EPOCH":"2020-06-03T21:51:26.358336",
            "MEAN_MOTION":15.00667713,
            "ECCENTRICITY":0.0011896,
            "INCLINATION":97.5563,
            "RA_OF_ASC_NODE":186.395,
            "ARG_OF_PERICENTER":178.0873,
            "MEAN_ANOMALY":235.0112,
            "EPHEMERIS_TYPE":0,
            "CLASSIFICATION_TYPE":"U",
            "NORAD_CAT_ID":45602,
            "ELEMENT_SET_NO":999,
            "REV_AT_EPOCH":343,
            "BSTAR":7.4303e-5,
            "MEAN_MOTION_DOT":8.83e-6,
            "MEAN_MOTION_DDOT":0}
        """.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

        do {
            let tle = try jsonDecoder.decode(TLE.self, from: jsonData)
            print(Satellite(withTLE: tle).debugDescription())
        } catch {
            print(error)
        }
    }

    func testJsonTLEArray() {
        let jsonData = """
            [{
            "OBJECT_NAME": "ATLAS CENTAUR 2",
            "OBJECT_ID": "1963-047A",
            "EPOCH": "2020-06-05T19:21:58.044384",
            "MEAN_MOTION": 14.0260002,
            "ECCENTRICITY": 0.0585625,
            "INCLINATION": 30.3559,
            "RA_OF_ASC_NODE": 314.9437,
            "ARG_OF_PERICENTER": 85.6228,
            "MEAN_ANOMALY": 281.1015,
            "EPHEMERIS_TYPE": 0,
            "CLASSIFICATION_TYPE": "U",
            "NORAD_CAT_ID": 694,
            "ELEMENT_SET_NO": 999,
            "REV_AT_EPOCH": 83546,
            "BSTAR": 2.8454e-5,
            "MEAN_MOTION_DOT": 3.01e-6,
            "MEAN_MOTION_DDOT": 0
            },{
            "OBJECT_NAME": "THOR AGENA D R/B",
            "OBJECT_ID": "1964-002A",
            "EPOCH": "2020-06-05T17:39:55.010304",
            "MEAN_MOTION": 14.32395649,
            "ECCENTRICITY": 0.0032737,
            "INCLINATION": 99.0129,
            "RA_OF_ASC_NODE": 48.8284,
            "ARG_OF_PERICENTER": 266.0175,
            "MEAN_ANOMALY": 93.7265,
            "EPHEMERIS_TYPE": 0,
            "CLASSIFICATION_TYPE": "U",
            "NORAD_CAT_ID": 733,
            "ELEMENT_SET_NO": 999,
            "REV_AT_EPOCH": 93714,
            "BSTAR": 2.6247e-5,
            "MEAN_MOTION_DOT": 2.3e-7,
            "MEAN_MOTION_DDOT": 0
            },{
            "OBJECT_NAME": "SL-3 R/B",
            "OBJECT_ID": "1964-053B",
            "EPOCH": "2020-06-05T20:39:17.038368",
            "MEAN_MOTION": 14.59393422,
            "ECCENTRICITY": 0.0055713,
            "INCLINATION": 65.0789,
            "RA_OF_ASC_NODE": 2.8558,
            "ARG_OF_PERICENTER": 32.0461,
            "MEAN_ANOMALY": 328.4005,
            "EPHEMERIS_TYPE": 0,
            "CLASSIFICATION_TYPE": "U",
            "NORAD_CAT_ID": 877,
            "ELEMENT_SET_NO": 999,
            "REV_AT_EPOCH": 95980,
            "BSTAR": 7.6135e-6,
            "MEAN_MOTION_DOT": -8.4e-7,
            "MEAN_MOTION_DDOT": 0
        }]
        """.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

        do {
            let tleArray = try jsonDecoder.decode([TLE].self, from: jsonData)
            print(Satellite(withTLE: tleArray[0]).debugDescription())
            print(Satellite(withTLE: tleArray[1]).debugDescription())
            print(Satellite(withTLE: tleArray[2]).debugDescription())
        } catch {
            print(error)
        }
    }

#if canImport(XMLCoder)
    func testXmlTLEArray() {

        let xmlData = """
        <ndm xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance"
               xsi:noNamespaceSchemaLocation="https://sanaregistry.org/r/ndmxml/ndmxml-1.0-master.xsd">
            <omm>
                <header>
                    <CREATION_DATE/>
                    <ORIGINATOR/>
                </header>
                <body>
                    <segment>
                        <metadata>
                            <OBJECT_NAME>ATLAS CENTAUR 2</OBJECT_NAME>
                            <OBJECT_ID>1963-047A</OBJECT_ID>
                            <CENTER_NAME>EARTH</CENTER_NAME>
                            <REF_FRAME>TEME</REF_FRAME>
                            <TIME_SYSTEM>UTC</TIME_SYSTEM>
                            <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                        </metadata>
                        <data>
                            <meanElements>
                                <EPOCH>2020-06-06T10:44:23.559360</EPOCH>
                                <MEAN_MOTION>14.02600247</MEAN_MOTION>
                                <ECCENTRICITY>.0585615</ECCENTRICITY>
                                <INCLINATION>30.3558</INCLINATION>
                                <RA_OF_ASC_NODE>311.4167</RA_OF_ASC_NODE>
                                <ARG_OF_PERICENTER>91.1851</ARG_OF_PERICENTER>
                                <MEAN_ANOMALY>275.5862</MEAN_ANOMALY>
                            </meanElements>
                            <tleParameters>
                                <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                                <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                                <NORAD_CAT_ID>694</NORAD_CAT_ID>
                                <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                                <REV_AT_EPOCH>83555</REV_AT_EPOCH>
                                <BSTAR>.28591E-4</BSTAR>
                                <MEAN_MOTION_DOT>3.03E-6</MEAN_MOTION_DOT>
                                <MEAN_MOTION_DDOT>0</MEAN_MOTION_DDOT>
                            </tleParameters>
                        </data>
                    </segment>
                </body>
            </omm>

            <omm>
                <header>
                    <CREATION_DATE/>
                    <ORIGINATOR/>
                </header>
                <body>
                    <segment>
                        <metadata>
                            <OBJECT_NAME>THOR AGENA D R/B</OBJECT_NAME>
                            <OBJECT_ID>1964-002A</OBJECT_ID>
                            <CENTER_NAME>EARTH</CENTER_NAME>
                            <REF_FRAME>TEME</REF_FRAME>
                            <TIME_SYSTEM>UTC</TIME_SYSTEM>
                            <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                        </metadata>
                        <data>
                            <meanElements>
                                <EPOCH>2020-06-06T07:04:37.126560</EPOCH>
                                <MEAN_MOTION>14.32395701</MEAN_MOTION>
                                <ECCENTRICITY>.0032725</ECCENTRICITY>
                                <INCLINATION>99.0129</INCLINATION>
                                <RA_OF_ASC_NODE>49.4090</RA_OF_ASC_NODE>
                                <ARG_OF_PERICENTER>264.3266</ARG_OF_PERICENTER>
                                <MEAN_ANOMALY>95.4185</MEAN_ANOMALY>
                            </meanElements>
                            <tleParameters>
                                <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                                <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                                <NORAD_CAT_ID>733</NORAD_CAT_ID>
                                <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                                <REV_AT_EPOCH>93722</REV_AT_EPOCH>
                                <BSTAR>.25433E-4</BSTAR>
                                <MEAN_MOTION_DOT>2.1E-7</MEAN_MOTION_DOT>
                                <MEAN_MOTION_DDOT>0</MEAN_MOTION_DDOT>
                            </tleParameters>
                        </data>
                    </segment>
                </body>
            </omm>

            <omm>
                <header>
                    <CREATION_DATE/>
                    <ORIGINATOR/>
                </header>
                <body>
                    <segment>
                        <metadata>
                            <OBJECT_NAME>SL-3 R/B</OBJECT_NAME>
                            <OBJECT_ID>1964-053B</OBJECT_ID>
                            <CENTER_NAME>EARTH</CENTER_NAME>
                            <REF_FRAME>TEME</REF_FRAME>
                            <TIME_SYSTEM>UTC</TIME_SYSTEM>
                            <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                        </metadata>
                        <data>
                            <meanElements>
                                <EPOCH>2020-06-05T22:17:57.747840</EPOCH>
                                <MEAN_MOTION>14.59393420</MEAN_MOTION>
                                <ECCENTRICITY>.0055722</ECCENTRICITY>
                                <INCLINATION>65.0789</INCLINATION>
                                <RA_OF_ASC_NODE>2.6555</RA_OF_ASC_NODE>
                                <ARG_OF_PERICENTER>32.0150</ARG_OF_PERICENTER>
                                <MEAN_ANOMALY>328.4314</MEAN_ANOMALY>
                            </meanElements>
                            <tleParameters>
                                <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                                <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                                <NORAD_CAT_ID>877</NORAD_CAT_ID>
                                <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                                <REV_AT_EPOCH>95981</REV_AT_EPOCH>
                                <BSTAR>.75354E-5</BSTAR>
                                <MEAN_MOTION_DOT>-8.4E-7</MEAN_MOTION_DOT>
                                <MEAN_MOTION_DDOT>0</MEAN_MOTION_DDOT>
                            </tleParameters>
                        </data>
                    </segment>
                </body>
            </omm>
        </ndm>
        """.data(using: .utf8)!

        let result = NavigationDataMessage(from: xmlData)

        let tle = TLE(commonName: result.omms[0].body.segment.metadata.commonName,
                      noradIndex: result.omms[0].body.segment.data.tleParameters.noradIndex,
                      launchName: result.omms[0].body.segment.metadata.launchName,
                      t₀: result.omms[0].body.segment.data.meanElements.t₀,
                      e₀: result.omms[0].body.segment.data.meanElements.e₀,
                      i₀: result.omms[0].body.segment.data.meanElements.i₀,
                      ω₀: result.omms[0].body.segment.data.meanElements.ω₀,
                      Ω₀: result.omms[0].body.segment.data.meanElements.Ω₀,
                      M₀: result.omms[0].body.segment.data.meanElements.M₀,
                      n₀: result.omms[0].body.segment.data.meanElements.n₀,
                      ephemType:  result.omms[0].body.segment.data.tleParameters.ephemType,
                      tleClass: result.omms[0].body.segment.data.tleParameters.tleClass,
                      tleNumber:  result.omms[0].body.segment.data.tleParameters.tleNumber,
                      revNumber:  result.omms[0].body.segment.data.tleParameters.revNumber,
                      dragCoeff:  result.omms[0].body.segment.data.tleParameters.dragCoeff)

        print(Satellite(withTLE: tle.debugDescription()))

    }
#endif

    func testLongFile() {

        do {
            let contents = try String(contentsOfFile: "/Users/gavin/Development/sat_code/all_tle.txt")
            _ = preProcessTLEs(contents)
        } catch {
            print(error)
        }

    }

    func testBase34() {
        XCTAssert(base10ID(     "") == 0)

        XCTAssert(base34ID(    "5") == 5)
        XCTAssert(base34ID("10000") == 10000, "got \(base34ID("10000"))")

        // numerical checks

        XCTAssert(base34ID("A0000") == 100000, "got \(base34ID("A0000"))")
        XCTAssert(base34ID("H0000") == 170000, "got \(base34ID("H0000"))")
        XCTAssert(base34ID("J0000") == 180000, "got \(base34ID("J0000"))")
        XCTAssert(base34ID("N0000") == 220000, "got \(base34ID("N0000"))")
        XCTAssert(base34ID("P0000") == 230000, "got \(base34ID("P0000"))")
        XCTAssert(base34ID("Z0000") == 330000, "got \(base34ID("Z0000"))")
        XCTAssert(base34ID("Z9999") == 339999, "got \(base34ID("Z9999"))")

        // lowercase

        XCTAssert(base34ID("a5678") == 105678, "got \(base34ID("a5678"))")

        // failure modes

        XCTAssert(base34ID("!0000") == 0, "got \(base34ID("!9999"))")
        XCTAssert(base34ID("~0000") == 0, "got \(base34ID("~9999"))")
        XCTAssert(base34ID("AAAAA") == 0, "got \(base34ID("AAAAA"))")
    }

    func testBase10() {
        XCTAssert(base10ID("") == 0)

        XCTAssert(base10ID("5") == 5)
        XCTAssert(base10ID("10000") == 10000, "got \(base10ID("10000"))")
        XCTAssert(base10ID("99999") == 99999, "got \(base10ID("99999"))")
    }

//    func testPerformanceExample() {         // May06/19 = iOS sim average: 2.267
//
//        self.measure {
//            testLongFile()
//        }
//    }

}
