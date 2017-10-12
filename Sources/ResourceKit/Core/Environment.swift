//
//  Environment.swift
//  ResourceKit
//
//  Created by Yudai.Hirose on 2017/09/24.
//  Copyright © 2017年 kingkong999yhirose. All rights reserved.
//

import Foundation
import XcodeProject

extension Environment {
    var element: String {
        if debug {
            return ProcessInfo.processInfo.environment["DEBUG_" + self.rawValue]!
        }
        guard let element = ProcessInfo.processInfo.environment[self.rawValue] else {
            let message: String = [
                "Unexpected value for xcode environment when use Environment.element property.",
                "file: \(#file)",
                "line: \(#line)",
                "function: \(#function)",
                "rawValue: \(self.rawValue)",
                ].reduce("")
                { $0 + $1 + "\n" }
            fatalError("message: \(message) ")
        }
        return element
    }
    
    var path: URL {
        return URL(fileURLWithPath: element)
    }
    
    static func pathFrom(_ path: PathComponent) -> URL {
        switch path {
        case .simple(let absolutePath):
            return URL(fileURLWithPath: absolutePath)
        case .environmentPath(let environement, let relativePath):
            return environement
                .path
                .appendingPathComponent(relativePath)
        }
    }
    
    // TODO: remove
    // Tmp
    public static var elements: [Environment] {
        // all elements
        return [
            PROJECT_FILE_PATH,
            TARGET_NAME,
            BUILT_PRODUCTS_DIR,
            DEVELOPER_DIR,
            SDKROOT,
            SOURCE_ROOT,
            SRCROOT
        ]
    }
    
    static func verifyUseEnvironment() throws {
        if let empty = elements.filter ({ ProcessInfo.processInfo.environment[$0.rawValue] == nil }).first {
            throw ResourceKitErrorType.environmentError(environmentKey: empty.rawValue, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
    }
    
}
