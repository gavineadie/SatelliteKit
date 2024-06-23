/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ XMLTests.swift                                                                                   ║
  ║                                                                                                  ║
  ║ Created by Gavin Eadie on Nov09/22 ... Copyright 2017-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import XCTest
@testable import SatelliteKit

class XmlTests: XCTestCase {

    func testXmlTLEArray() {

        var xmlText = """
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
        """

        let ommRange = xmlText.range(of: "<omm>")      // find the first <omm>
        let newRange = xmlText.startIndex ... xmlText.index(ommRange!.lowerBound, offsetBy: -4)
        xmlText.removeSubrange(newRange)

        xmlText = xmlText.replacingOccurrences(of: "   ", with: "")
        xmlText = xmlText.replacingOccurrences(of: "</omm>", with: "</omm>###")
        let subStrings = xmlText.components(separatedBy: "###")

        for subString in subStrings.dropLast() {

            let tle = Elements(xmlData: subString.data(using: .ascii)!)
            print(tle.debugDescription())


        }

    }

    func testNewXmlTLEArray() {

        var xmlText = """
        <?xml version="1.0" encoding="utf-8"?>
        <ndm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://sanaregistry.org/r/ndmxml/ndmxml-1.0-master.xsd">
          <omm id="CCSDS_OMM_VERS" version="2.0">
            <header>
              <COMMENT>GENERATED VIA SPACE-TRACK.ORG API</COMMENT>
              <CREATION_DATE>2022-10-09T17:43:15</CREATION_DATE>
              <ORIGINATOR>18 SPCS</ORIGINATOR>
            </header>
            <body>
              <segment>
                <metadata>
                  <OBJECT_NAME>VANGUARD 1</OBJECT_NAME>
                  <OBJECT_ID>1958-002B</OBJECT_ID>
                  <CENTER_NAME>EARTH</CENTER_NAME>
                  <REF_FRAME>TEME</REF_FRAME>
                  <TIME_SYSTEM>UTC</TIME_SYSTEM>
                  <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                </metadata>
                <data>
                  <meanElements>
                    <EPOCH>2022-10-08T23:45:26.277408</EPOCH>
                    <MEAN_MOTION>10.85017843</MEAN_MOTION>
                    <ECCENTRICITY>0.18464490</ECCENTRICITY>
                    <INCLINATION>34.2463</INCLINATION>
                    <RA_OF_ASC_NODE>149.5009</RA_OF_ASC_NODE>
                    <ARG_OF_PERICENTER>188.6184</ARG_OF_PERICENTER>
                    <MEAN_ANOMALY>167.7916</MEAN_ANOMALY>
                  </meanElements>
                  <tleParameters>
                    <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                    <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                    <NORAD_CAT_ID>5</NORAD_CAT_ID>
                    <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                    <REV_AT_EPOCH>29687</REV_AT_EPOCH>
                    <BSTAR>0.00037162000000</BSTAR>
                    <MEAN_MOTION_DOT>0.00000306</MEAN_MOTION_DOT>
                    <MEAN_MOTION_DDOT>0.0000000000000</MEAN_MOTION_DDOT>
                  </tleParameters>
                  <userDefinedParameters>
                    <USER_DEFINED parameter="SEMIMAJOR_AXIS">8618.743</USER_DEFINED>
                    <USER_DEFINED parameter="PERIOD">132.717</USER_DEFINED>
                    <USER_DEFINED parameter="APOAPSIS">3832.015</USER_DEFINED>
                    <USER_DEFINED parameter="PERIAPSIS">649.201</USER_DEFINED>
                    <USER_DEFINED parameter="OBJECT_TYPE">PAYLOAD</USER_DEFINED>
                    <USER_DEFINED parameter="RCS_SIZE">SMALL</USER_DEFINED>
                    <USER_DEFINED parameter="COUNTRY_CODE">US</USER_DEFINED>
                    <USER_DEFINED parameter="LAUNCH_DATE">1958-03-17</USER_DEFINED>
                    <USER_DEFINED parameter="SITE">AFETR</USER_DEFINED>
                    <USER_DEFINED parameter="DECAY_DATE" />
                    <USER_DEFINED parameter="FILE">3597861</USER_DEFINED>
                    <USER_DEFINED parameter="GP_ID">214538277</USER_DEFINED>
                  </userDefinedParameters>
                </data>
              </segment>
            </body>
          </omm>
          <omm id="CCSDS_OMM_VERS" version="2.0">
            <header>
              <COMMENT>GENERATED VIA SPACE-TRACK.ORG API</COMMENT>
              <CREATION_DATE>2022-10-09T17:43:15</CREATION_DATE>
              <ORIGINATOR>18 SPCS</ORIGINATOR>
            </header>
            <body>
              <segment>
                <metadata>
                  <OBJECT_NAME>VANGUARD 2</OBJECT_NAME>
                  <OBJECT_ID>1959-001A</OBJECT_ID>
                  <CENTER_NAME>EARTH</CENTER_NAME>
                  <REF_FRAME>TEME</REF_FRAME>
                  <TIME_SYSTEM>UTC</TIME_SYSTEM>
                  <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                </metadata>
                <data>
                  <meanElements>
                    <EPOCH>2022-10-09T06:09:11.696832</EPOCH>
                    <MEAN_MOTION>11.86180859</MEAN_MOTION>
                    <ECCENTRICITY>0.14666100</ECCENTRICITY>
                    <INCLINATION>32.8703</INCLINATION>
                    <RA_OF_ASC_NODE>126.3852</RA_OF_ASC_NODE>
                    <ARG_OF_PERICENTER>336.4467</ARG_OF_PERICENTER>
                    <MEAN_ANOMALY>17.5091</MEAN_ANOMALY>
                  </meanElements>
                  <tleParameters>
                    <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                    <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                    <NORAD_CAT_ID>11</NORAD_CAT_ID>
                    <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                    <REV_AT_EPOCH>37517</REV_AT_EPOCH>
                    <BSTAR>0.00029442000000</BSTAR>
                    <MEAN_MOTION_DOT>0.00000569</MEAN_MOTION_DOT>
                    <MEAN_MOTION_DDOT>0.0000000000000</MEAN_MOTION_DDOT>
                  </tleParameters>
                  <userDefinedParameters>
                    <USER_DEFINED parameter="SEMIMAJOR_AXIS">8121.469</USER_DEFINED>
                    <USER_DEFINED parameter="PERIOD">121.398</USER_DEFINED>
                    <USER_DEFINED parameter="APOAPSIS">2934.436</USER_DEFINED>
                    <USER_DEFINED parameter="PERIAPSIS">552.231</USER_DEFINED>
                    <USER_DEFINED parameter="OBJECT_TYPE">PAYLOAD</USER_DEFINED>
                    <USER_DEFINED parameter="RCS_SIZE">MEDIUM</USER_DEFINED>
                    <USER_DEFINED parameter="COUNTRY_CODE">US</USER_DEFINED>
                    <USER_DEFINED parameter="LAUNCH_DATE">1959-02-17</USER_DEFINED>
                    <USER_DEFINED parameter="SITE">AFETR</USER_DEFINED>
                    <USER_DEFINED parameter="DECAY_DATE" />
                    <USER_DEFINED parameter="FILE">3597861</USER_DEFINED>
                    <USER_DEFINED parameter="GP_ID">214538777</USER_DEFINED>
                  </userDefinedParameters>
                </data>
              </segment>
            </body>
          </omm>
          <omm id="CCSDS_OMM_VERS" version="2.0">
            <header>
              <COMMENT>GENERATED VIA SPACE-TRACK.ORG API</COMMENT>
              <CREATION_DATE>2022-10-08T19:45:09</CREATION_DATE>
              <ORIGINATOR>18 SPCS</ORIGINATOR>
            </header>
            <body>
              <segment>
                <metadata>
                  <OBJECT_NAME>VANGUARD R/B</OBJECT_NAME>
                  <OBJECT_ID>1959-001B</OBJECT_ID>
                  <CENTER_NAME>EARTH</CENTER_NAME>
                  <REF_FRAME>TEME</REF_FRAME>
                  <TIME_SYSTEM>UTC</TIME_SYSTEM>
                  <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                </metadata>
                <data>
                  <meanElements>
                    <EPOCH>2022-10-08T09:13:47.947008</EPOCH>
                    <MEAN_MOTION>11.44703381</MEAN_MOTION>
                    <ECCENTRICITY>0.16650480</ECCENTRICITY>
                    <INCLINATION>32.9020</INCLINATION>
                    <RA_OF_ASC_NODE>280.9669</RA_OF_ASC_NODE>
                    <ARG_OF_PERICENTER>188.7747</ARG_OF_PERICENTER>
                    <MEAN_ANOMALY>167.9846</MEAN_ANOMALY>
                  </meanElements>
                  <tleParameters>
                    <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                    <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                    <NORAD_CAT_ID>12</NORAD_CAT_ID>
                    <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                    <REV_AT_EPOCH>37656</REV_AT_EPOCH>
                    <BSTAR>0.00022706000000</BSTAR>
                    <MEAN_MOTION_DOT>0.00000412</MEAN_MOTION_DOT>
                    <MEAN_MOTION_DDOT>0.0000000000000</MEAN_MOTION_DDOT>
                  </tleParameters>
                  <userDefinedParameters>
                    <USER_DEFINED parameter="SEMIMAJOR_AXIS">8316.486</USER_DEFINED>
                    <USER_DEFINED parameter="PERIOD">125.797</USER_DEFINED>
                    <USER_DEFINED parameter="APOAPSIS">3323.086</USER_DEFINED>
                    <USER_DEFINED parameter="PERIAPSIS">553.616</USER_DEFINED>
                    <USER_DEFINED parameter="OBJECT_TYPE">ROCKET BODY</USER_DEFINED>
                    <USER_DEFINED parameter="RCS_SIZE">MEDIUM</USER_DEFINED>
                    <USER_DEFINED parameter="COUNTRY_CODE">US</USER_DEFINED>
                    <USER_DEFINED parameter="LAUNCH_DATE">1959-02-17</USER_DEFINED>
                    <USER_DEFINED parameter="SITE">AFETR</USER_DEFINED>
                    <USER_DEFINED parameter="DECAY_DATE" />
                    <USER_DEFINED parameter="FILE">3596390</USER_DEFINED>
                    <USER_DEFINED parameter="GP_ID">214453027</USER_DEFINED>
                  </userDefinedParameters>
                </data>
              </segment>
            </body>
          </omm>
          <omm id="CCSDS_OMM_VERS" version="2.0">
            <header>
              <COMMENT>GENERATED VIA SPACE-TRACK.ORG API</COMMENT>
              <CREATION_DATE>2022-10-09T17:43:15</CREATION_DATE>
              <ORIGINATOR>18 SPCS</ORIGINATOR>
            </header>
            <body>
              <segment>
                <metadata>
                  <OBJECT_NAME>VANGUARD R/B</OBJECT_NAME>
                  <OBJECT_ID>1958-002A</OBJECT_ID>
                  <CENTER_NAME>EARTH</CENTER_NAME>
                  <REF_FRAME>TEME</REF_FRAME>
                  <TIME_SYSTEM>UTC</TIME_SYSTEM>
                  <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                </metadata>
                <data>
                  <meanElements>
                    <EPOCH>2022-10-09T07:00:10.145376</EPOCH>
                    <MEAN_MOTION>10.48815835</MEAN_MOTION>
                    <ECCENTRICITY>0.20276420</ECCENTRICITY>
                    <INCLINATION>34.2659</INCLINATION>
                    <RA_OF_ASC_NODE>237.9216</RA_OF_ASC_NODE>
                    <ARG_OF_PERICENTER>196.0203</ARG_OF_PERICENTER>
                    <MEAN_ANOMALY>156.5650</MEAN_ANOMALY>
                  </meanElements>
                  <tleParameters>
                    <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                    <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                    <NORAD_CAT_ID>16</NORAD_CAT_ID>
                    <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                    <REV_AT_EPOCH>54743</REV_AT_EPOCH>
                    <BSTAR>-0.00011101000000</BSTAR>
                    <MEAN_MOTION_DOT>-0.00000068</MEAN_MOTION_DOT>
                    <MEAN_MOTION_DDOT>0.0000000000000</MEAN_MOTION_DDOT>
                  </tleParameters>
                  <userDefinedParameters>
                    <USER_DEFINED parameter="SEMIMAJOR_AXIS">8815.948</USER_DEFINED>
                    <USER_DEFINED parameter="PERIOD">137.298</USER_DEFINED>
                    <USER_DEFINED parameter="APOAPSIS">4225.372</USER_DEFINED>
                    <USER_DEFINED parameter="PERIAPSIS">650.254</USER_DEFINED>
                    <USER_DEFINED parameter="OBJECT_TYPE">ROCKET BODY</USER_DEFINED>
                    <USER_DEFINED parameter="RCS_SIZE">MEDIUM</USER_DEFINED>
                    <USER_DEFINED parameter="COUNTRY_CODE">US</USER_DEFINED>
                    <USER_DEFINED parameter="LAUNCH_DATE">1958-03-17</USER_DEFINED>
                    <USER_DEFINED parameter="SITE">AFETR</USER_DEFINED>
                    <USER_DEFINED parameter="DECAY_DATE" />
                    <USER_DEFINED parameter="FILE">3597861</USER_DEFINED>
                    <USER_DEFINED parameter="GP_ID">214539279</USER_DEFINED>
                  </userDefinedParameters>
                </data>
              </segment>
            </body>
          </omm>
          <omm id="CCSDS_OMM_VERS" version="2.0">
            <header>
              <COMMENT>GENERATED VIA SPACE-TRACK.ORG API</COMMENT>
              <CREATION_DATE>2022-10-09T17:43:15</CREATION_DATE>
              <ORIGINATOR>18 SPCS</ORIGINATOR>
            </header>
            <body>
              <segment>
                <metadata>
                  <OBJECT_NAME>VANGUARD 3</OBJECT_NAME>
                  <OBJECT_ID>1959-007A</OBJECT_ID>
                  <CENTER_NAME>EARTH</CENTER_NAME>
                  <REF_FRAME>TEME</REF_FRAME>
                  <TIME_SYSTEM>UTC</TIME_SYSTEM>
                  <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                </metadata>
                <data>
                  <meanElements>
                    <EPOCH>2022-10-09T10:19:11.273376</EPOCH>
                    <MEAN_MOTION>11.56285245</MEAN_MOTION>
                    <ECCENTRICITY>0.16639110</ECCENTRICITY>
                    <INCLINATION>33.3440</INCLINATION>
                    <RA_OF_ASC_NODE>54.2609</RA_OF_ASC_NODE>
                    <ARG_OF_PERICENTER>65.3885</ARG_OF_PERICENTER>
                    <MEAN_ANOMALY>311.0741</MEAN_ANOMALY>
                  </meanElements>
                  <tleParameters>
                    <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                    <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                    <NORAD_CAT_ID>20</NORAD_CAT_ID>
                    <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                    <REV_AT_EPOCH>32828</REV_AT_EPOCH>
                    <BSTAR>0.00036984000000</BSTAR>
                    <MEAN_MOTION_DOT>0.00000888</MEAN_MOTION_DOT>
                    <MEAN_MOTION_DDOT>0.0000000000000</MEAN_MOTION_DDOT>
                  </tleParameters>
                  <userDefinedParameters>
                    <USER_DEFINED parameter="SEMIMAJOR_AXIS">8260.859</USER_DEFINED>
                    <USER_DEFINED parameter="PERIOD">124.537</USER_DEFINED>
                    <USER_DEFINED parameter="APOAPSIS">3257.257</USER_DEFINED>
                    <USER_DEFINED parameter="PERIAPSIS">508.190</USER_DEFINED>
                    <USER_DEFINED parameter="OBJECT_TYPE">PAYLOAD</USER_DEFINED>
                    <USER_DEFINED parameter="RCS_SIZE">MEDIUM</USER_DEFINED>
                    <USER_DEFINED parameter="COUNTRY_CODE">US</USER_DEFINED>
                    <USER_DEFINED parameter="LAUNCH_DATE">1959-09-18</USER_DEFINED>
                    <USER_DEFINED parameter="SITE">AFETR</USER_DEFINED>
                    <USER_DEFINED parameter="DECAY_DATE" />
                    <USER_DEFINED parameter="FILE">3597861</USER_DEFINED>
                    <USER_DEFINED parameter="GP_ID">214540029</USER_DEFINED>
                  </userDefinedParameters>
                </data>
              </segment>
            </body>
          </omm>
          <omm id="CCSDS_OMM_VERS" version="2.0">
            <header>
              <COMMENT>GENERATED VIA SPACE-TRACK.ORG API</COMMENT>
              <CREATION_DATE>2022-10-09T17:43:15</CREATION_DATE>
              <ORIGINATOR>18 SPCS</ORIGINATOR>
            </header>
            <body>
              <segment>
                <metadata>
                  <OBJECT_NAME>EXPLORER 7</OBJECT_NAME>
                  <OBJECT_ID>1959-009A</OBJECT_ID>
                  <CENTER_NAME>EARTH</CENTER_NAME>
                  <REF_FRAME>TEME</REF_FRAME>
                  <TIME_SYSTEM>UTC</TIME_SYSTEM>
                  <MEAN_ELEMENT_THEORY>SGP4</MEAN_ELEMENT_THEORY>
                </metadata>
                <data>
                  <meanElements>
                    <EPOCH>2022-10-09T11:20:49.081920</EPOCH>
                    <MEAN_MOTION>14.97571252</MEAN_MOTION>
                    <ECCENTRICITY>0.01334770</ECCENTRICITY>
                    <INCLINATION>50.2813</INCLINATION>
                    <RA_OF_ASC_NODE>97.1791</RA_OF_ASC_NODE>
                    <ARG_OF_PERICENTER>247.4370</ARG_OF_PERICENTER>
                    <MEAN_ANOMALY>111.2408</MEAN_ANOMALY>
                  </meanElements>
                  <tleParameters>
                    <EPHEMERIS_TYPE>0</EPHEMERIS_TYPE>
                    <CLASSIFICATION_TYPE>U</CLASSIFICATION_TYPE>
                    <NORAD_CAT_ID>22</NORAD_CAT_ID>
                    <ELEMENT_SET_NO>999</ELEMENT_SET_NO>
                    <REV_AT_EPOCH>59671</REV_AT_EPOCH>
                    <BSTAR>0.00045356000000</BSTAR>
                    <MEAN_MOTION_DOT>0.00006138</MEAN_MOTION_DOT>
                    <MEAN_MOTION_DDOT>0.0000000000000</MEAN_MOTION_DDOT>
                  </tleParameters>
                  <userDefinedParameters>
                    <USER_DEFINED parameter="SEMIMAJOR_AXIS">6952.540</USER_DEFINED>
                    <USER_DEFINED parameter=""></USER_DEFINED>
                  </userDefinedParameters>
                </data>
              </segment>
            </body>
          </omm>
        </ndm>
        """
        
        let ommRange = xmlText.range(of: "<omm ",options: .caseInsensitive)      // find the first <omm>
        let newRange = xmlText.startIndex ... xmlText.index(ommRange!.lowerBound, offsetBy: -4)
        xmlText.removeSubrange(newRange)

        xmlText = xmlText.replacingOccurrences(of: "   ", with: "")
        xmlText = xmlText.replacingOccurrences(of: "</omm>", with: "</omm>###")
        let subStrings = xmlText.components(separatedBy: "###")
            
        for subString in subStrings.dropLast() {

            let tle = Elements(xmlData: subString.data(using: .ascii)!)
            print(tle.debugDescription())
            
        }

    }
    
//    func testXMLMassiveArray() async {
//
//        do {
//            var xmlText = try String(contentsOf: URL(fileURLWithPath:
//                    "/Users/gavin/Development/Orbits/SatelliteKit/xml.xml"))
//
//            let ommRange = xmlText.range(of: "<omm ",options: .caseInsensitive)      // find the first <omm>
//            let newRange = xmlText.startIndex ... xmlText.index(ommRange!.lowerBound, offsetBy: -1)
//            xmlText.removeSubrange(newRange)
//
//            xmlText = xmlText.replacingOccurrences(of: "   ", with: "")
//            xmlText = xmlText.replacingOccurrences(of: "</omm>", with: "</omm>###")
//            let subStrings = xmlText.components(separatedBy: "###")
//                
//            for subString in subStrings.dropLast() {
//                let _ = Elements(xmlData: subString.data(using: .ascii)!)
//            }
//
//        } catch {
//            print(error)
//        }
//
//    }
}
