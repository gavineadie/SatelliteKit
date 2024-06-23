/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ElementsXML.swift                                                                         SatKit ║
  ║ Created by Gavin Eadie on Oct10/22         Copyright © 2022-24 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

//MARK: - XML initializer

public extension Elements {

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/

    init(xmlData: Data) {
        
        let parser = ElementsParser()
        parser.parseXML(xmlData)
        
        var satelliteInfo = parser.satInfoArray[0]

        if satelliteInfo.count < 10 {
            satelliteInfo = parser.satInfoArray[1]
        }
        
        self.init(commonName: satelliteInfo["OBJECT_NAME"]!,
                  noradIndex: UInt(satelliteInfo["NORAD_CAT_ID"]!)!,
                  launchName: satelliteInfo["OBJECT_ID"] ?? "",         // OBJECT_ID can be null
                  t₀: DateFormatter.iso8601Micros.date(from: satelliteInfo["EPOCH"]!)!,
                  e₀: Double(satelliteInfo["ECCENTRICITY"]!)!,
                  i₀: Double(satelliteInfo["INCLINATION"]!)!,
                  ω₀: Double(satelliteInfo["ARG_OF_PERICENTER"]!)!,
                  Ω₀: Double(satelliteInfo["RA_OF_ASC_NODE"]!)!,
                  M₀: Double(satelliteInfo["MEAN_ANOMALY"]!)!,
                  n₀: Double(satelliteInfo["MEAN_MOTION"]!)!,
                  ephemType: Int(satelliteInfo["EPHEMERIS_TYPE"]!)!,
                  tleClass: satelliteInfo["CLASSIFICATION_TYPE"]!,
                  tleNumber: Int(satelliteInfo["ELEMENT_SET_NO"]!)!,
                  revNumber: Int(satelliteInfo["REV_AT_EPOCH"]!)!,
                  dragCoeff: Double(satelliteInfo["BSTAR"]!)!)

//      n₀ʹ = 0.0

        unKozai(n₀ * (π/720.0))

    }
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ This class will consume an XML data set in the form of NDM definitions of one or more satellite  ┃
  ┃ elements ..                                                                                      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
class ElementsParser : NSObject, XMLParserDelegate {
    
    var satelliteInfo: [String : String] = [:]      // NDM key : NDM value (all text)
    var satInfoArray: [[String : String]] = []      // a collections (array) of the above
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func parseXML(_ data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if !parser.parse() { print("error \(parser.parserError!)") }
    }
    
    var eName: String = ""
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "segment" {
            if satelliteInfo.isNotEmpty { satInfoArray.append(satelliteInfo) }
        }
        
        eName = elementName                 // remember "elementName" for later ..
    }
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !string.isWhitespace { satelliteInfo[eName] = string }
    }
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func parserDidEndDocument(_ parser: XMLParser) {
        if satelliteInfo.isNotEmpty { satInfoArray.append(satelliteInfo) }
    }
}
