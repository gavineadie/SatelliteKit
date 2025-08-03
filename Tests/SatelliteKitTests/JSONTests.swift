/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ JSONTests.swift                                                                                  ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Sep25/22     Copyright 2020-25 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Testing
import Foundation
@testable import SatelliteKit

struct JSONElementTests {
    
    @Test func JsonOneSmall() {
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
            let tle = try jsonDecoder.decode(Elements.self, from: jsonData)
            print(tle.debugDescription())
        } catch {
            print(error)
        }
    }
    
    @Test func JsonOneLarge() {
        let jsonData = """
        {
            "CCSDS_OMM_VERS":"2.0",
            "COMMENT":"GENERATED VIA SPACE-TRACK.ORG API",
            "CREATION_DATE":"2021-12-28T02:26:55",
            "ORIGINATOR":"18 SPCS",
            "OBJECT_NAME":"JWST",
            "OBJECT_ID":"2021-130A",
            "CENTER_NAME":"EARTH",
            "REF_FRAME":"TEME",
            "TIME_SYSTEM":"UTC",
            "MEAN_ELEMENT_THEORY":"SGP4",
            "EPOCH":"2021-12-28T00:00:00.000000",
            "MEAN_MOTION":"0.01958082",
            "ECCENTRICITY":"0.98849830",
            "INCLINATION":"4.6198",
            "RA_OF_ASC_NODE":"89.0659",
            "ARG_OF_PERICENTER":"192.3200",
            "MEAN_ANOMALY":"17.4027",
            "EPHEMERIS_TYPE":"0",
            "CLASSIFICATION_TYPE":"U",
            "NORAD_CAT_ID":"50463",
            "ELEMENT_SET_NO":"999",
            "REV_AT_EPOCH":"2",
            "BSTAR":"0.00000000000000",
            "MEAN_MOTION_DOT":"0.00000000",
            "MEAN_MOTION_DDOT":"0.0000000000000",
            "SEMIMAJOR_AXIS":"581452.967",
            "PERIOD":"73541.353",
            "APOAPSIS":"1149840.102",
            "PERIAPSIS":"309.563",
            "OBJECT_TYPE":"PAYLOAD",
            "RCS_SIZE":null,
            "COUNTRY_CODE":"ESA",
            "LAUNCH_DATE":"2021-12-25",
            "SITE":"FRGUI",
            "DECAY_DATE":null,
            "FILE":"3253114",
            "GP_ID":"192606073"
        }
        """.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

        do {
            let tle = try jsonDecoder.decode(Elements.self, from: jsonData)
            print(tle.debugDescription())
        } catch {
            print(error)
        }
    }

    @Test func JsonArray() {
        let jsonText = """
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
        """
            
        let jsonData = jsonText.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)

        do {
            let tleArray = try jsonDecoder.decode([Elements].self, from: jsonData)
            print(tleArray[0].debugDescription())
            print(tleArray[1].debugDescription())
            print(tleArray[2].debugDescription())
        } catch {
            print(error)
        }
    }
    
//    @Test func JsonMassiveArray() async {
//        
//        do {
//            let jsonData = try Data(contentsOf: URL(fileURLWithPath:
//                    "/Users/gavin/Development/Orbits/SatelliteKit/json.json"))
//            
//            let jsonDecoder = JSONDecoder()
//            jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)
//
//            let tleArray = try jsonDecoder.decode([Elements].self, from: jsonData)
//
//            print(tleArray[0].debugDescription())
//            print(tleArray[1].debugDescription())
//            print(tleArray[2].debugDescription())
//        } catch {
//            print(error)
//        }
//
//    }

}
