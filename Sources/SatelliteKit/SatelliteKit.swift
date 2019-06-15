/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SatelliteKit.swift                                                                  SatelliteKit ║
  ║ Created by Gavin Eadie on Aug05/17 ... Copyright 2016-19 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

public struct SatelliteKit {

    public static var version: String {
        guard let satelliteKitBundle = Bundle(identifier: "com.ramsaycons.SatelliteKit"),
              let plistDictionary = satelliteKitBundle.infoDictionary else {
                return "No 'SatelliteKit' Info.plist"
        }

        return String(format: "%@ v%@ (#%@) [%@ @ %@]",
                      plistDictionary["CFBundleName"] as? String ?? "Library",
                      plistDictionary["CFBundleShortVersionString"] as? String ?? "v0.0",
                      plistDictionary["CFBundleVersion"] as? String  ?? "0",
                      plistDictionary["AppBuildDate"] as? String ?? "BuildDate",
                      plistDictionary["AppBuildTime"] as? String ?? "BuildTime")
    }

}
