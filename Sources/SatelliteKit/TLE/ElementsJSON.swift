/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ ElementsJSON.swift                                                                        SatKit ║
  ║ Created by Gavin Eadie on Oct10/22         Copyright © 2022-25 Gavin Eadie. All rights reserved. ║
  ║──────────────────────────────────────────────────────────────────────────────────────────────────║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

//MARK: - JSON initializer

public extension Elements {

/*┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  │ Decoding one, or more, Elements from JSON requires a little work before the init ..              │
  │                                                                                                  │
  │ First, we need to create a JSON decoder and teach it how to decode ISO times with milliseconds   │
  │                                                                                                  │
  │     let jsonDecoder = JSONDecoder()                                                              │
  │     jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Micros)                   │
  │                                                                                                  │
  │ Then, if JSON data in the form of a String, convert it to Data (catching any error)              │
  │                                                                                                  │
  │     guard let jsonData = jsonString.data(using: .utf8) else {                                    │
  │         throw Error("JSON failure converting String to Data ..")                                 │
  │     }                                                                                            │
  │                                                                                                  │
  │ Finally let the decoder do it's thing .. (again, catch errors if necessary)                      │
  │                                                                                                  │
  │     let elements = try jsonDecoder.decode(Elements.self, from: jsonData)                         │
  │                                                                                                  │
  │ or for an array of Elements                                                                      │
  │                                                                                                  │
  │     let elementsArray = try jsonDecoder.decode([Elements].self, from: jsonData)                  │
  │                                                                                                  │
  └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/

    private enum CodingKeys: String, CodingKey {
        case commonName = "OBJECT_NAME"
        case noradIndex = "NORAD_CAT_ID"
        case launchName = "OBJECT_ID"
        case t₀ = "EPOCH"
        case e₀ = "ECCENTRICITY"
        case i₀ = "INCLINATION"
        case ω₀ = "ARG_OF_PERICENTER"
        case Ω₀ = "RA_OF_ASC_NODE"
        case M₀ = "MEAN_ANOMALY"
        case n₀ = "MEAN_MOTION"
        case dragCoeff = "BSTAR"
        case ephemType = "EPHEMERIS_TYPE"
        case tleClass = "CLASSIFICATION_TYPE"
        case tleNumber = "ELEMENT_SET_NO"
        case revNumber = "REV_AT_EPOCH"

//                      "MEAN_MOTION_DOT"
//                      "MEAN_MOTION_DDOT"
//                      "RMS"
//                      "DATA_SOURCE"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.commonName = try container.decode(String.self, forKey: .commonName)
        
        do {
            self.noradIndex = UInt(try container.decode(Int.self, forKey: .noradIndex))     // UInt *OR* String
        } catch {
            self.noradIndex = UInt(String(try container.decode(String.self, forKey: .noradIndex)))!
        }
        
        self.launchName = try container.decode(String.self, forKey: .launchName)
        self.t₀ = try container.decode(Date.self, forKey: .t₀).daysSince1950
        
        do {
            self.e₀ = try container.decode(Double.self, forKey: .e₀)
        } catch {
            self.e₀ = Double(String(try container.decode(String.self, forKey: .e₀)))!
        }
        
        do {
            self.i₀ = try container.decode(Double.self, forKey: .i₀) * deg2rad
        } catch {
            self.i₀ = Double(String(try container.decode(String.self, forKey: .i₀)))! * deg2rad
        }
        
        do {
            self.ω₀ = try container.decode(Double.self, forKey: .ω₀) * deg2rad
        } catch {
            self.ω₀ = Double(String(try container.decode(String.self, forKey: .ω₀)))! * deg2rad
        }
        
        do {
            self.Ω₀ = try container.decode(Double.self, forKey: .Ω₀) * deg2rad
        } catch {
            self.Ω₀ = Double(String(try container.decode(String.self, forKey: .Ω₀)))! * deg2rad
        }
        
        do {
            self.M₀ = try container.decode(Double.self, forKey: .M₀) * deg2rad
        } catch {
            self.M₀ = Double(String(try container.decode(String.self, forKey: .M₀)))! * deg2rad
        }
        
        do {
            self.n₀ = try container.decode(Double.self, forKey: .n₀)
        } catch {
            self.n₀ = Double(String(try container.decode(String.self, forKey: .n₀)))!
        }
        
        do {
            self.dragCoeff = try container.decode(Double.self, forKey: .dragCoeff)
        } catch {
            self.dragCoeff = Double(String(try container.decode(String.self, forKey: .dragCoeff)))!
        }
        
        do {
            self.ephemType = try container.decode(Int.self, forKey: .ephemType)
        } catch {
            self.ephemType = Int(String(try container.decode(String.self, forKey: .ephemType)))!
        }
        self.tleClass = try container.decode(String.self, forKey: .tleClass)
        
        do {
            self.tleNumber = try container.decode(Int.self, forKey: .tleNumber)
        } catch {
            self.tleNumber = Int(String(try container.decode(String.self, forKey: .tleNumber)))!
        }
        
        do {
            self.revNumber = try container.decode(Int.self, forKey: .revNumber)
        } catch {
            self.revNumber = Int(String(try container.decode(String.self, forKey: .revNumber)))!
        }
        
        n₀ʹ = n₀                                                // capture pre-Kozai n₀ for export
        
        unKozai(self.n₀ * (π/720.0))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(commonName, forKey: .commonName)
        try container.encode(noradIndex, forKey: .noradIndex)
        try container.encode(launchName, forKey: .launchName)
        try container.encode(Date(ds1950: t₀), forKey: .t₀)
        try container.encode(e₀, forKey: .e₀)
        try container.encode(i₀ * rad2deg, forKey: .i₀)
        try container.encode(ω₀ * rad2deg, forKey: .ω₀)
        try container.encode(Ω₀ * rad2deg, forKey: .Ω₀)
        try container.encode(M₀ * rad2deg, forKey: .M₀)
        try container.encode(dragCoeff, forKey: .dragCoeff)
        try container.encode(ephemType, forKey: .ephemType)
        try container.encode(tleClass, forKey: .tleClass)
        try container.encode(tleNumber, forKey: .tleNumber)
        try container.encode(revNumber, forKey: .revNumber)
        try container.encode(self.n₀ʹ, forKey: .n₀)             // use the previously captured n₀ʹ
    }
}
