//
//  ResourceKitConfig.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/10/14.
//

import Foundation

struct ResourceKitConfig {
    static let outputFileName = "Resource.generated.swift"
    
    struct Debug {
        static let isDebug: Bool = ProcessInfo.processInfo.environment["DEBUG"] != nil
        static let outputPath: String? = ProcessInfo.processInfo.environment["DEBUG_OUTPUT_PATH"]
        static let projectTarget: String? = ProcessInfo.processInfo.environment["DEBUG_TARGET_NAME"]
        static let projectFilePath: String? = ProcessInfo.processInfo.environment["DEBUG_PROJECT_FILE_PATH"]
    }
}
