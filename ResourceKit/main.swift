//
//  main.swift
//  ResourceKit
//
//  Created by Hirose.Yudai on 2016/01/27.
//  Copyright © 2016年 Hirose.Yudai. All rights reserved.
//

import Foundation
private let RESOURCE_FILENAME = "Resource.generated.swift"

private func extractGenerateDir() -> String? {
    return NSProcessInfo
        .processInfo()
        .arguments
        .flatMap { arg in
            guard let range = arg.rangeOfString("-p ") else {
                return nil
            }
            return arg.substringFromIndex(range.endIndex)
        }
        .last
}

do {
    try Environment.verifyUseEnvironment()
} catch {
    exit(1)
}

let outputPath = extractGenerateDir() ?? Environment.SRCROOT.element
let config: Config = Config()

do {
    try Environment.verifyUseEnvironment()
    
    let outputUrl = NSURL(fileURLWithPath: outputPath)
    var resourceValue: AnyObject?
    try outputUrl.getResourceValue(&resourceValue, forKey: NSURLIsDirectoryKey)
    
    let writeUrl: NSURL
    writeUrl = outputUrl.URLByAppendingPathComponent(RESOURCE_FILENAME, isDirectory: false)
    
    func imports() -> [String] {
        guard let content = try? String(contentsOfURL: writeUrl) else {
            return config.segue.addition ? ["import UIKit", "import SegueAddition"] : ["import UIKit"]
        }
        let pattern = "\\s*import\\s+.+"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .UseUnixLineSeparators) else {
            return ["import UIKit"]
        }
        let results = regex.matchesInString(content, options: [], range: NSMakeRange(0, content.characters.count))
        
        if results.isEmpty {
            return config.segue.addition ? ["import UIKit", "import SegueAddition"] : ["import UIKit"]
        }
        
        return results.flatMap { (result) -> String? in
            if result.range.location != NSNotFound {
                let matchingString = (content as NSString).substringWithRange(result.range) as String
                return matchingString
                    .stringByReplacingOccurrencesOfString("\n", withString: "")
            }
            return nil
        }
    }
    
    let parser = try ProjectResourceParser()
    let paths = parser.paths.filter { $0.pathExtension != nil }
    
    paths
        .filter { $0.pathExtension == "storyboard" }
        .forEach { let _ = try? StoryboardParser(url: $0) }
    
    paths
        .filter { $0.pathExtension == "xib" }
        .forEach { let _ = try? XibPerser(url: $0) }
    
    let importsContent = imports().joinWithSeparator(newLine)
    
    let xibProtocolContent = Protocol(
        name: "XibProtocol",
        getters: [
            Var(name: "name", type: "String")
        ],
        functions: [
            FunctionForProtocol(
                head: "",
                name: "nib",
                arguments: [],
                returnType: "UINib"
            )
        ]
        ).declaration + newLine
    
    let tableViewExtensionContent = Extension(
        type: "UITableView",
        functions: [
            Function(
                name: "registerNib",
                arguments: [
                    Argument(name: "nib", type: "XibProtocol")
                ],
                returnType: "Void",
                body: Body("registerNib(nib.nib(), forCellReuseIdentifier: nib.name)")
            )
            ,
            Function(
                name: "registerNibs",
                arguments: [
                    Argument(name: "nibs", type: "[XibProtocol]")
                ],
                returnType: "Void",
                body: Body("nibs.forEach(registerNib)")
            )
        ]
        ).declaration + newLine
    
    let collectionViewExtensionContent = Extension(
        type: "UICollectionView",
        functions: [
            Function(
                name: "registerNib",
                arguments: [
                    Argument(name: "nib", type: "XibProtocol")
                ],
                returnType: "Void",
                body: Body("registerNib(nib.nib(), forCellWithReuseIdentifier: nib.name)")
            )
            ,
            Function(
                name: "registerNibs",
                arguments: [
                    Argument(name: "nibs", type: "[XibProtocol]")
                ],
                returnType: "Void",
                body: Body("nibs.forEach(registerNib)")
            )
        ]
        ).declaration + newLine
    
    
    let viewControllerContent = ProjectResource.sharedInstance.viewControllers
        .flatMap { $0.generateExtensionIfNeeded() }
        .flatMap { $0.declaration }
        .joinWithSeparator(newLine)
    
    let tableViewCellContent: String
    let collectionViewCellContent: String
    
    if config.reusable.identifier {
        tableViewCellContent = ProjectResource.sharedInstance.tableViewCells
            .flatMap { $0.generateExtension() }
            .flatMap { $0.declaration }
            .joinWithSeparator(newLine)
        
        collectionViewCellContent = ProjectResource.sharedInstance.collectionViewCells
            .flatMap { $0.generateExtension() }
            .flatMap { $0.declaration }
            .joinWithSeparator(newLine)
        
    } else {
        tableViewCellContent = ""
        collectionViewCellContent = ""
    }
    
    let xibContent: String
    if config.nib.xib {
        xibContent = ProjectResource.sharedInstance.xibs
            .flatMap { $0.generateExtension() }
            .flatMap { $0.declaration }
            .joinWithSeparator(newLine)
    } else {
        xibContent = ""
    }
    
    let imageContent = Image(urls: paths).generate().declaration + newLine
    
    let stringContent: String
    if config.string.localized {
        stringContent = LocalizedString(urls: parser.localizablePaths).generate().declaration + newLine
    } else {
        stringContent = ""
    }
    
    let content = (
        Header
            + importsContent + newLine
            + xibProtocolContent
            + tableViewExtensionContent
            + collectionViewExtensionContent
            + viewControllerContent
            + tableViewCellContent
            + collectionViewCellContent
            + xibContent
            + imageContent
            + stringContent
    )
    
    func write(code: String, fileURL: NSURL) throws {
        try code.writeToURL(fileURL, atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    try write(content, fileURL: writeUrl)
} catch {
    if let e = error as? ResourceKitErrorType {
        print(e.description())
        
    } else {
        print(error)
    }
    
    exit(3)
}