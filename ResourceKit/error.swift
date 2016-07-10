//
//  error.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/07/10.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation


enum ResourceKitErrorType: ErrorType {
    case spcifiedPathError(path: String, errorInfo: String)
    case environmentError(environmentKey: String, errorInfo: String)
    case configError(configType: String, errorInfo: String)
    case xcodeProjectError(xcodeURL: NSURL, target: String, errorInfo: String)
    case xcodeProjectAllTargetError(xcodeURL: NSURL, target: String, allTargetName: String, errorInfo: String)
    case regexError(errorInfo: String)
    case resourceParseError(name: String, errorInfo: String)
    case writeError(path: String, code: String, errorInfo: String)
    
    
    func description() -> String {
        switch self {
        case spcifiedPathError(let path, let errorInfo):
            return "path: \(path), errorInfo: \(errorInfo)"
        case environmentError(let environmentKey, let errorInfo):
            return "environmentKey: \(environmentKey), errorInfo: \(errorInfo)"
        case configError(let configType, let errorInfo):
            return "configType: \(configType), errorInfo: \(errorInfo)"
        case xcodeProjectError(let xcodeURL, let target, let errorInfo):
            return "xcodeURL: \(xcodeURL.absoluteString), target: \(target), errorInfo: \(errorInfo)"
        case xcodeProjectAllTargetError(let xcodeURL, let target, let allTargetName, let errorInfo):
            return "xcodeURL: \(xcodeURL.absoluteString), target: \(target), allTargetName: \(allTargetName),errorInfo: \(errorInfo)"
        case regexError(let errorInfo):
            return "errorInfo: \(errorInfo)"
        case resourceParseError(let name, let errorInfo):
            return "name: \(name), errorInfo:\(errorInfo)"
        case writeError(let path, let code, let errorInfo):
            return "path: \(path), code: \(code), errorInfo:\(errorInfo)"
        }
    }
    
    static func createErrorInfo(file: String = #file, line: Int = #line) -> String {
        return "file: \(file), line: \(line)"
    }
}