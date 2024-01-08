/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
  ║ SatelliteKit.swift                                                                  SatelliteKit ║
  ║ Created by Gavin Eadie on Aug05/17 ... Copyright 2016-24 Ramsay Consulting. All rights reserved. ║
  ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

import Foundation

extension String {
    var isWhitespace: Bool { return allSatisfy( { $0.isWhitespace } ) }
}

extension Collection {
    var isNotEmpty: Bool { !self.isEmpty }
}


public struct SatelliteKit {

    var staticVersion = "~~VersionBuild~~"          // v1.1.0 (321)
    var staticLibDate = "~~AppBuildDate~~"          // Feb27/22
    var staticLibTime = "~~AppBuildTime~~"          // 20:15:10
    var staticLibInfo = "~~CopyrightText~~"         // Copyright 2016-24 Ramsay Consulting

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
