/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SatParser.swift                                                                           SatKit ║
  ║ Created by Gavin Eadie on Feb19/22            Copyright © 2022 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

extension String {
    var isBlank: Bool { return allSatisfy({ $0.isWhitespace })}
}

extension Dictionary {
    var isNotEmpty: Bool { !self.isEmpty }
}


/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ This class will consume an XML data set in the form of NMD definitions of one or more satellite  ┃
  ┃ elements ..                                                                                      ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛*/
class TLEParser : NSObject, XMLParserDelegate {
    
    var satelliteInfo: [String : String] = [:]      // NMD key : NMD value (all text)
    var satInfoArray: [[String : String]] = []      // a collections (array) of the above
    var tleCollection: [TLE] = []                   // a TLE collection, mapped from the above
    
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
        if !string.isBlank { satelliteInfo[eName] = string }
    }
    
/*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    func parserDidEndDocument(_ parser: XMLParser) {
        if satelliteInfo.isNotEmpty { satInfoArray.append(satelliteInfo) }
    }
}
