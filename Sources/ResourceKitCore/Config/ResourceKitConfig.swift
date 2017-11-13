//
//  ResourceKitConfig.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/10/14.
//

import Foundation
import XcodeProject

public struct ResourceKitConfig {
    public static let outputFileName = "Resource.generated.swift"
    public static var outputPath: String {
        let _path = Debug.outputPath ?? Environment.SRCROOT.element
        
        guard let path = _path else {
            fatalError("Can't find outputPath. Run time env: \(Environment.elements)")
        }
        return path
    }

    public struct Debug {
        public static let isDebug: Bool = ProcessInfo.processInfo.environment["DEBUG"] != nil
        public static let outputPath: String? = ProcessInfo.processInfo.environment["DEBUG_OUTPUT_PATH"]
        public static let projectTarget: String? = ProcessInfo.processInfo.environment["DEBUG_TARGET_NAME"]
        public static let projectFilePath: String? = ProcessInfo.processInfo.environment["DEBUG_PROJECT_FILE_PATH"]
    }
}
