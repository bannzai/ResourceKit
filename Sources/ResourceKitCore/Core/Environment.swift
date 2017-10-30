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
    public var element: String {
        if ResourceKitConfig.Debug.isDebug {
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
    
    public var path: URL {
        return URL(fileURLWithPath: element)
    }
    
    public static func pathFrom(_ path: PathComponent) -> URL {
        switch path {
        case .simple(let absolutePath):
            return URL(fileURLWithPath: absolutePath)
        case .environmentPath(let environement, let relativePath):
            return environement
                .path
                .appendingPathComponent(relativePath)
        }
    }
    
    public static func verifyUseEnvironment() throws {
        if let empty = elements.filter ({ ProcessInfo.processInfo.environment[$0.rawValue] == nil }).first {
            throw ResourceKitErrorType.environmentError(environmentKey: empty.rawValue, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
    }
    
}
