//
//  ProjectParser.swift
//  ResourceKit
//
//  Created by kingkong999yhirose on 2016/05/03.
//  Copyright © 2016年 kingkong999yhirose. All rights reserved.
//

import Foundation


struct ProjectResourceParser {
    private var projectFile: XCProjectFile
    var paths: [NSURL] = []
    var resourcePaths: [NSURL] = []
    
    init() {
        self.init(xcodeURL: Environment.PROJECT_FILE_PATH.path, target: Environment.TARGET_NAME.element)
    }
    
    init(xcodeURL: NSURL, target: String) {
        guard let projectFile = try? XCProjectFile(xcodeprojURL: xcodeURL) else {
            fatalError("xcodeURL: \(xcodeURL) ")
        }
        let allTarget = projectFile.project.targets
        guard let target = allTarget.filter({ $0.name == target }).first else {
            fatalError("allTargetName: \(allTarget.flatMap { $0.name }.joinWithSeparator(", "))")
        }
        
        self.projectFile = projectFile
        self.paths = generateFileRefPaths(target).flatMap(Environment.pathFrom)
        self.resourcePaths = resourcePathsForTarget(target).flatMap(Environment.pathFrom)
        
        setupSuffixViewControllers()
    }
    
    func resourcePathsForTarget(target: PBXNativeTarget) -> [Path] {
        let resourcesFileRefs = target.buildPhases
            .flatMap { $0 as? PBXResourcesBuildPhase }
            .flatMap { $0.files }
            .map { $0.fileRef }
        
        let fileRefPaths = resourcesFileRefs
            .flatMap { $0 as? PBXFileReference }
            .map { $0.fullPath }
        
        let variantGroupPaths = resourcesFileRefs
            .flatMap { $0 as? PBXVariantGroup }
            .flatMap { $0.fileRefs }
            .map { $0.fullPath }
        
        return fileRefPaths + variantGroupPaths
    }
    
    private func generateFileRefPaths(target: PBXNativeTarget) -> [Path] {
        return target.buildPhases
            .flatMap { $0.files }
            .flatMap { $0.fileRef }
            .flatMap { $0 as? PBXFileReference }
            .flatMap { $0.fullPath }
    }
    
    private mutating func setupSuffixViewControllers() {
        let swiftViewControllerFiles = filterPaths(withExtension: "swift", suffixs: "ViewController")
        let ObjCViewControllerFiles = filterPaths(withExtension: "h", suffixs: "ViewController")
        
        let viewControllerFromSwiftFile = viewControllerInfoWith(
            swiftViewControllerFiles,
            suffix: "ViewController",
            pattern: ".*class\\s+.*ViewController\\s*:\\s*.*ViewController"
        )
        let viewControllerFromObjcFile = viewControllerInfoWith(
            ObjCViewControllerFiles,
            suffix: "ViewController",
            pattern: "\\s*@interface\\s+.*ViewController\\s*:\\s*.*ViewController"
        )
        
        let standards = ViewControllerResource.standards().flatMap { ViewController(className: $0.rawValue) }
        
        ProjectResource
            .sharedInstance
            .viewControllers
            .appendContentsOf(
                viewControllerFromSwiftFile + viewControllerFromObjcFile + standards
        )
    
    }
    
    private func viewControllerInfoWith(path: NSURL, suffix: String, pattern: String) -> ViewController? {
        let content = try! String(contentsOfURL: path)
        let regex = try! NSRegularExpression(pattern: pattern, options: .UseUnixLineSeparators)
        let results = regex.matchesInString(content, options: [], range: NSMakeRange(0, content.characters.count))
        
        return results.flatMap { (result) -> ViewController? in
            if result.range.location != NSNotFound {
                let matchingString = (content as NSString).substringWithRange(result.range) as String
                let classes = matchingString
                    .stringByReplacingOccurrencesOfString("\\s*@interface", withString: "", options: .RegularExpressionSearch, range: nil)
                    .stringByReplacingOccurrencesOfString(".*class", withString: "", options: .RegularExpressionSearch, range: nil)
                    .stringByReplacingOccurrencesOfString("{", withString: "")
                    .stringByReplacingOccurrencesOfString("}", withString: "")
                    .stringByReplacingOccurrencesOfString(" ", withString: "")
                    .stringByReplacingOccurrencesOfString(":", withString: " ")
                    .componentsSeparatedByString(" ")
                    .filter { $0.hasSuffix(suffix) }
                
                return ViewController (className: classes[0], superClassName: classes[1])
            }
            return nil }.first
    }
    
    private func viewControllerInfoWith(paths: [NSURL], suffix: String, pattern: String) -> [ViewController] {
        return paths.flatMap {
            viewControllerInfoWith($0, suffix: suffix, pattern: pattern)
        }
    }
    
    private mutating func filterPaths(withExtension ex: String, suffixs: String...) -> [NSURL] {
        return paths.filter { url in
            guard let pathExtension = url.pathExtension
                where pathExtension == ex
                else {
                    return false
            }
            guard let fileName = url.URLByDeletingPathExtension?.lastPathComponent
            where suffixs.contains({fileName.hasSuffix($0)})  else {
                    return false
            }
            
            return true
        }
    }
}
