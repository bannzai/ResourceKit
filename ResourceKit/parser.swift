//
//  parser.swift
//  o
//
//  Created by kingkong999yhirose on 2016/04/12.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation

protocol Parsable: NSXMLParserDelegate {
    init(url: NSURL)
}

struct ProjectResourceParser {
    private var projectFile: XCProjectFile
    var paths: [NSURL] = []
    
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
        
        setupSuffixViewControllers()
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


final class StoryboardParser: NSObject, Parsable {
    private var _name: String = ""
    private var _initialViewControllerIdentifier: String?
    private var _viewControllerInfos: [ViewControllerInfoOfStoryboard] = []
    private var _currentViewControllerInfo: ViewControllerInfoOfStoryboard?
    
    init(url: NSURL) {
        super.init()
        
        guard let ex = url.pathExtension where ex == "storyboard" else {
            fatalError()
        }
        guard let name = url.URLByDeletingPathExtension?.lastPathComponent else {
            fatalError()
        }
        
        
        _name = name
        if _name.containsString("~") { // TODO: chech ipad storyboard
            return
        }
        
        let parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "document" {
            _initialViewControllerIdentifier = attributeDict["initialViewController"]
            return
        }
        
        if ResourceType.isViewControllerStandardType(elementName) {
            generateViewControllerResource(attributeDict, elementName: elementName)
        }
        
        if ResourceType.isSegue(elementName) {
            extranctionForSegue(attributeDict, elementName: elementName)
        }
        
        if ResourceType.isTableViewCell(elementName) {
            generateTableViewCells(attributeDict, elementName: elementName)
        }
        
        if ResourceType.isCollectionViewCell(elementName) {
            generateCollectionViewCells(attributeDict, elementName: elementName)
        }
    }
    
    private func extranctionForSegue(attributes: [String: String], elementName: String) {
        guard let segueIdentifier = attributes["identifier"] else {
            return
        }
        _currentViewControllerInfo?.segues.append(segueIdentifier)
    }
    
    private func generateViewControllerResource(attributes: [String: String], elementName: String) {
        guard let viewControllerId = attributes["id"] else {
            return
        }
        
        let storyboardIdentifier = attributes["storyboardIdentifier"] ?? ""
        let viewControllerName = ResourceType(viewController: attributes["customClass"] ?? elementName).name
        
        _currentViewControllerInfo = ViewControllerInfoOfStoryboard (
            viewControllerId: viewControllerId,
            storyboardName: _name,
            initialViewControllerId: _initialViewControllerIdentifier,
            storyboardIdentifier: storyboardIdentifier
        )
        
        ProjectResource
            .sharedInstance
            .viewControllers
            .filter({ $0.name == viewControllerName })
            .first?
            .storyboardInfos
            .append(_currentViewControllerInfo!)
    }
    
    private func generateTableViewCells(attributes: [String: String], elementName: String) {
        guard let reusableIdentifier = attributes["reuseIdentifier"] else {
            return
        }
        
        let className = ResourceType(reusable: attributes["customClass"] ?? elementName).name
        ProjectResource
            .sharedInstance
            .appendTableViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
    
    private func generateCollectionViewCells(attributes: [String: String], elementName: String) {
        guard let reusableIdentifier = attributes["reuseIdentifier"] else {
            return
        }
        
        let className = ResourceType(reusable: attributes["customClass"] ?? elementName).name
        ProjectResource
            .sharedInstance
            .appendCollectionViewCell(
                className,
                reusableIdentifier: reusableIdentifier
        )
    }
}

final class XibPerser: NSObject, Parsable {
    private var _name: String = ""
    private var isOnce: Bool = false
    private let ignoreCase = [
        "UIResponder"
    ]
    
    init(url: NSURL) {
        super.init()
        
        guard let ex = url.pathExtension where ex == "xib" else {
            fatalError()
        }
        guard let name = url.URLByDeletingPathExtension?.lastPathComponent else {
            fatalError()
        }
        
        _name = name
        if _name.containsString("~") { // TODO: chech ipad storyboard??
            return
        }
        
        ProjectResource
            .sharedInstance
            .xibIdentifiers
            .append(_name)
        
        let parser = NSXMLParser(contentsOfURL: url)!
        parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        generateXibs(attributeDict, elementName: elementName)
    }
    
    private func generateXibs(attributes: [String: String], elementName: String) {
        if isOnce {
            return
        }
        
        guard let className = attributes["customClass"] else {
            return
        }
        if ignoreCase.contains(className) {
            return
        }
        
        let hasFilesOwner = attributes.flatMap ({ $1 }).contains("IBFilesOwner")
        if hasFilesOwner {
            return
        }
        
        isOnce = true
        ProjectResource
            .sharedInstance
            .appendXibForView(
            XibForView(
                name: _name,
                className: className,
                isFilesOwner: hasFilesOwner
            )
        )
    }
    
}
