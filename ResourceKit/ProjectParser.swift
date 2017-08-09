//
//  ProjectParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation


struct ProjectResourceParser {
    fileprivate var projectFile: XCProjectFile
    private(set) var paths: [URL] = []
    var localizablePaths: [URL] = []
    
    init(xcodeURL: URL, target: String) throws {
        guard let projectFile = try? XCProjectFile(xcodeprojURL: xcodeURL) else {
            throw ResourceKitErrorType.xcodeProjectError(xcodeURL: xcodeURL, target: target, errorInfo: ResourceKitErrorType.createErrorInfo())
        }
        
        let allTarget = projectFile.project.targets
        guard let _target = allTarget.filter({ $0.name == target }).first else {
            throw ResourceKitErrorType.xcodeProjectAllTargetError(xcodeURL: xcodeURL, target: target, allTargetName: "\(allTarget.flatMap { $0.name }.joined(separator: ", "))", errorInfo: ResourceKitErrorType.createErrorInfo())
        }
        
        self.projectFile = projectFile
        self.paths = generateFileRefPaths(_target).flatMap(Environment.pathFrom)
        self.localizablePaths = generateLocalizablePaths(_target).flatMap(Environment.pathFrom)
        
        setupSuffixViewControllers()
    }
    
    fileprivate func generateLocalizablePaths(_ target: PBXNativeTarget) -> [Path] {
        let resourcesFileRefs = target.buildPhases
            .flatMap { $0 as? PBXResourcesBuildPhase }
            .flatMap { $0.files }
            .map { $0.fileRef }
        
        let localizablePaths = resourcesFileRefs
            .flatMap { $0 as? PBXVariantGroup }
            .flatMap { $0.fileRefs }
            .map { $0.fullPath }
        
        return localizablePaths
    }
    
    fileprivate func generateFileRefPaths(_ target: PBXNativeTarget) -> [Path] {
        return target.buildPhases
            .flatMap { $0.files }
            .flatMap { $0.fileRef }
            .flatMap { $0 as? PBXFileReference }
            .flatMap { $0.fullPath }
    }
    
    fileprivate mutating func setupSuffixViewControllers() {
        func append(_ viewControllers: [ViewController]) {
            ProjectResource
                .sharedInstance
                .viewControllers
                .append(
                    contentsOf: viewControllers
            )
        }
        if config.viewController.instantiateStoryboardForSwift {
            append(
                viewControllerInfoWith(
                    filterPaths(withExtension: "swift", suffixs: "ViewController"),
                    suffix: "ViewController",
                    pattern: ".*class\\s+.*ViewController\\s*:\\s*.*ViewController"
                )
            )
        }
        if config.viewController.instantiateStoryboardForObjC {
            append(
                viewControllerInfoWith(
                    filterPaths(withExtension: "h", suffixs: "ViewController"),
                    suffix: "ViewController",
                    pattern: "\\s*@interface\\s+.*ViewController\\s*:\\s*.*ViewController"
                )
            )
            
        }
        if config.viewController.instantiateStoryboardAny {
            append(
                ViewControllerResource.standards().flatMap { try? ViewController(className: $0.rawValue) }
            )
        }
        
    }
    
    fileprivate func viewControllerInfoWith(_ path: URL, suffix: String, pattern: String) -> ViewController? {
        guard let content = try? String(contentsOf: path),
            let regex = try? NSRegularExpression(pattern: pattern, options: .useUnixLineSeparators) else {
                return nil
        }
        let results = regex.matches(in: content, options: [], range: NSMakeRange(0, content.characters.count))
        
        return results
            .flatMap { (result) -> ViewController? in
                if result.range.location != NSNotFound {
                    let matchingString = (content as NSString).substring(with: result.range) as String
                    let classes = matchingString
                        .replacingOccurrences(of: "\\s*@interface", with: "", options: .regularExpression, range: nil)
                        .replacingOccurrences(of: ".*class", with: "", options: .regularExpression, range: nil)
                        .replacingOccurrences(of: "{", with: "")
                        .replacingOccurrences(of: "}", with: "")
                        .replacingOccurrences(of: " ", with: "")
                        .replacingOccurrences(of: ":", with: " ")
                        .components(separatedBy: " ")
                        .filter { $0.hasSuffix(suffix) }
                    
                    
                    return try? ViewController (className: classes[0], superClassName: classes[1])
                }
                return nil
            }
            .first
    }
    
    fileprivate func viewControllerInfoWith(_ paths: [URL], suffix: String, pattern: String) -> [ViewController] {
        return paths.flatMap {
            viewControllerInfoWith($0, suffix: suffix, pattern: pattern)
        }
    }
    
    fileprivate func filterPaths(withExtension ex: String, suffixs: String...) -> [URL] {
        return paths.filter { url in
            guard url.pathExtension == ex
                else {
                    return false
            }
            guard let fileName = Optional(url.deletingPathExtension().lastPathComponent)
                , suffixs.contains(where: {fileName.hasSuffix($0)})  else {
                    return false
            }
            return true
        }
    }
}
